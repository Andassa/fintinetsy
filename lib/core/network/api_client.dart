import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';
import 'api_exception.dart';
import 'etag_cache.dart';
import 'token_storage.dart';

typedef OnUnauthorized = void Function();

class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    required EtagCache etagCache,
    this.onUnauthorized,
    Dio? dio,
    Dio? refreshDio,
    Dio? retryDio,
  })  : _tokens = tokenStorage,
        _etag = etagCache,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 20),
                headers: {'Content-Type': 'application/json'},
              ),
            ) {
    final base = _dio.options.baseUrl.isNotEmpty
        ? _dio.options.baseUrl
        : ApiConfig.baseUrl;
    final plain = BaseOptions(
      baseUrl: base,
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 20),
    );
    _refreshDio = refreshDio ?? Dio(plain);
    // No interceptors — used only to replay a request after token refresh.
    _retryDio = retryDio ?? Dio(plain);

    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  final Dio _dio;
  late final Dio _refreshDio;
  late final Dio _retryDio;
  final TokenStorage _tokens;
  final EtagCache _etag;
  final OnUnauthorized? onUnauthorized;
  bool _refreshing = false;

  Dio get raw => _dio;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final access = await _tokens.readAccessToken();
    if (access != null && access.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $access';
    }
    if (options.method.toUpperCase() == 'GET') {
      final etag = _etag.etagFor(options.path);
      if (etag != null) {
        options.headers['If-None-Match'] = etag;
      }
    }
    handler.next(options);
  }

  Future<void> _onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final path = response.requestOptions.path;
    if (response.statusCode == 200 && response.data != null) {
      final etag = response.headers.value('etag')?.replaceAll('"', '');
      final body = response.data is String
          ? response.data as String
          : jsonEncode(response.data);
      await _etag.save(path: path, etag: etag ?? 'local', body: body);
    }
    if (response.statusCode == 304) {
      final cached = _etag.bodyFor(path);
      if (cached != null) {
        response = Response(
          requestOptions: response.requestOptions,
          statusCode: 200,
          data: jsonDecode(cached),
          headers: response.headers,
        );
      }
    }
    handler.next(response);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_isConnectionIssue(err) &&
        err.requestOptions.method.toUpperCase() == 'GET') {
      final cached = _etag.bodyFor(err.requestOptions.path);
      if (cached != null) {
        return handler.resolve(
          Response(
            requestOptions: err.requestOptions,
            statusCode: 200,
            data: jsonDecode(cached),
            extra: {'from_cache': true},
          ),
        );
      }
    }

    if (err.response?.statusCode == 401 && !_refreshing) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        try {
          final access = await _tokens.readAccessToken();
          final opts = err.requestOptions;
          if (access != null) {
            opts.headers['Authorization'] = 'Bearer $access';
          }
          final retry = await _retryDio.fetch<dynamic>(opts);
          return handler.resolve(retry);
        } catch (_) {
          await _tokens.clear();
          onUnauthorized?.call();
          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: ApiException('Session expired. Please sign in again.'),
              type: DioExceptionType.badResponse,
              response: err.response,
            ),
          );
        }
      }
      await _tokens.clear();
      onUnauthorized?.call();
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: ApiException.fromDio(err),
        type: err.type,
        response: err.response,
      ),
    );
  }

  bool _isConnectionIssue(DioException err) {
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout;
  }

  Future<bool> _tryRefresh() async {
    final refresh = await _tokens.readRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;
    _refreshing = true;
    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refresh},
      );
      final data = response.data;
      if (data == null) return false;
      await _tokens.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
      return true;
    } catch (e, st) {
      debugPrint('Token refresh failed: $e\n$st');
      return false;
    } finally {
      _refreshing = false;
    }
  }
}
