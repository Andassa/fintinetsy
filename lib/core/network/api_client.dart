import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';
import 'etag_cache.dart';
import 'token_storage.dart';

typedef OnUnauthorized = void Function();

class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    required EtagCache etagCache,
    OnUnauthorized? onUnauthorized,
    Dio? dio,
  })  : _tokens = tokenStorage,
        _etag = etagCache,
        _onUnauthorized = onUnauthorized,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 20),
                headers: {'Content-Type': 'application/json'},
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokens;
  final EtagCache _etag;
  final OnUnauthorized? _onUnauthorized;
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
    final etag = response.headers.value('etag');
    if (response.statusCode == 200 && etag != null) {
      await _etag.save(
        path: path,
        etag: etag.replaceAll('"', ''),
        body: response.data is String
            ? response.data as String
            : jsonEncode(response.data),
      );
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
    if (err.response?.statusCode == 401 && !_refreshing) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        try {
          final retry = await _dio.fetch<dynamic>(err.requestOptions);
          return handler.resolve(retry);
        } catch (e) {
          return handler.next(err);
        }
      }
      await _tokens.clear();
      _onUnauthorized?.call();
    }
    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    final refresh = await _tokens.readRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;
    _refreshing = true;
    try {
      final response = await Dio(
        BaseOptions(baseUrl: ApiConfig.baseUrl),
      ).post<Map<String, dynamic>>(
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
