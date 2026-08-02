import 'dart:convert';

import 'package:dio/dio.dart';

import '../offline/offline_cache.dart';
import '../offline/offline_status.dart';
import 'api_config.dart';
import 'api_exception.dart';
import 'token_refresh_service.dart';
import 'token_storage.dart';

typedef OnUnauthorized = void Function();

/// Authenticated HTTP client with:
/// - Bearer JWT injection
/// - **Refresh-token rotation** on HTTP 401 ([TokenRefreshService])
/// - **Hive offline cache** + ETag revalidation ([OfflineCache])
class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    required OfflineCache offlineCache,
    TokenRefreshService? tokenRefreshService,
    this.offlineStatus,
    this.onUnauthorized,
    Dio? dio,
    Dio? refreshDio,
    Dio? retryDio,
  })  : _tokens = tokenStorage,
        _cache = offlineCache,
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
    final refreshClient = refreshDio ?? Dio(plain);
    _retryDio = retryDio ?? Dio(plain);
    _refresher = tokenRefreshService ??
        TokenRefreshService(
          tokenStorage: tokenStorage,
          refreshDio: refreshClient,
        );

    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  final Dio _dio;
  late final Dio _retryDio;
  late final TokenRefreshService _refresher;
  final TokenStorage _tokens;
  final OfflineCache _cache;
  final OfflineStatus? offlineStatus;
  final OnUnauthorized? onUnauthorized;

  Dio get raw => _dio;
  TokenRefreshService get tokenRefreshService => _refresher;
  OfflineCache get offlineCache => _cache;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final access = await _tokens.readAccessToken();
    if (access != null && access.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $access';
    }
    if (options.method.toUpperCase() == 'GET') {
      final etag = _cache.etagFor(options.path);
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
      await _cache.saveResponse(path: path, body: body, etag: etag);
      offlineStatus?.markOnline();
    }
    if (response.statusCode == 304) {
      final cached = _cache.bodyFor(path);
      if (cached != null) {
        response = Response(
          requestOptions: response.requestOptions,
          statusCode: 200,
          data: jsonDecode(cached),
          headers: response.headers,
          extra: {'from_cache': true, 'etag_304': true},
        );
        offlineStatus?.markFromCache('Not modified — served from Hive cache.');
      }
    }
    handler.next(response);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Offline mode: serve last Hive body for GET requests.
    if (_isConnectionIssue(err) &&
        err.requestOptions.method.toUpperCase() == 'GET') {
      final cached = _cache.bodyFor(err.requestOptions.path);
      if (cached != null) {
        offlineStatus?.markFromCache();
        return handler.resolve(
          Response(
            requestOptions: err.requestOptions,
            statusCode: 200,
            data: jsonDecode(cached),
            extra: {'from_cache': true, 'offline': true},
          ),
        );
      }
    }

    // Access token expired → rotate refresh token, then retry once.
    if (err.response?.statusCode == 401) {
      final refreshed = await _refresher.rotateTokens();
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
}
