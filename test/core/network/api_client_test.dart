import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:fintinetsy/core/network/api_client.dart';
import 'package:fintinetsy/core/network/token_refresh_service.dart';
import 'package:fintinetsy/core/network/token_storage.dart';
import 'package:fintinetsy/core/offline/offline_cache.dart';
import 'package:fintinetsy/core/offline/offline_status.dart';

void main() {
  test('TokenRefreshService rotates access and refresh tokens', () async {
    final tokens = TokenStorage.memory();
    await tokens.saveTokens(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
    );
    final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
    DioAdapter(dio: dio).onPost(
      '/auth/refresh',
      (server) => server.reply(200, {
        'access_token': 'new-access',
        'refresh_token': 'new-refresh',
        'token_type': 'bearer',
        'user': {
          'id': '00000000-0000-0000-0000-000000000001',
          'email': 'a@b.com',
          'name': 'A',
          'avatar_url': null,
          'membership': 'basic',
        },
      }),
      data: Matchers.any,
    );

    final ok = await TokenRefreshService(
      tokenStorage: tokens,
      refreshDio: dio,
    ).rotateTokens();

    expect(ok, isTrue);
    expect(await tokens.readAccessToken(), 'new-access');
    expect(await tokens.readRefreshToken(), 'new-refresh');
  });

  test('ApiClient refreshes access token on 401 then retries', () async {
    final tokens = TokenStorage.memory();
    await tokens.saveTokens(
      accessToken: 'expired',
      refreshToken: 'refresh-ok',
    );

    const base = 'http://test/api/v1';
    final dio = Dio(BaseOptions(baseUrl: base));
    final refreshDio = Dio(BaseOptions(baseUrl: base));
    final retryDio = Dio(BaseOptions(baseUrl: base));

    DioAdapter(dio: dio).onGet(
      '/home/dashboard',
      (server) => server.reply(401, {
        'code': 'unauthorized',
        'message': 'Token expired',
      }),
    );
    DioAdapter(dio: refreshDio).onPost(
      '/auth/refresh',
      (server) => server.reply(200, {
        'access_token': 'new-access',
        'refresh_token': 'new-refresh',
        'token_type': 'bearer',
        'user': {
          'id': '00000000-0000-0000-0000-000000000001',
          'email': 'a@b.com',
          'name': 'A',
          'avatar_url': null,
          'membership': 'basic',
        },
      }),
      data: Matchers.any,
    );
    DioAdapter(dio: retryDio).onGet(
      '/home/dashboard',
      (server) => server.reply(200, {'ok': true}),
    );

    final api = ApiClient(
      tokenStorage: tokens,
      offlineCache: OfflineCache.memory(),
      dio: dio,
      refreshDio: refreshDio,
      retryDio: retryDio,
    );

    final response = await api.raw.get<Map<String, dynamic>>('/home/dashboard');
    expect(response.data?['ok'], isTrue);
    expect(await tokens.readAccessToken(), 'new-access');
  });

  test('OfflineCache stores GET payloads in Hive-compatible store', () async {
    final cache = OfflineCache.memory();
    await cache.saveResponse(
      path: '/workouts/browse',
      body: '{"title":"Browse"}',
      etag: 'v1',
    );
    expect(cache.hasBody('/workouts/browse'), isTrue);
    expect(cache.etagFor('/workouts/browse'), 'v1');
    expect(cache.jsonFor('/workouts/browse')?['title'], 'Browse');
  });

  test('ApiClient serves Hive cache when offline', () async {
    final cache = OfflineCache.memory();
    await cache.saveResponse(
      path: '/workouts/browse',
      body: '{"title":"Cached Browse"}',
      etag: 'v1',
    );
    final status = OfflineStatus();
    final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
    DioAdapter(dio: dio).onGet(
      '/workouts/browse',
      (server) => server.throws(
        500,
        DioException(
          requestOptions: RequestOptions(path: '/workouts/browse'),
          type: DioExceptionType.connectionError,
          error: 'offline',
        ),
      ),
    );

    final api = ApiClient(
      tokenStorage: TokenStorage.memory(),
      offlineCache: cache,
      offlineStatus: status,
      dio: dio,
    );

    final response =
        await api.raw.get<Map<String, dynamic>>('/workouts/browse');
    expect(response.data?['title'], 'Cached Browse');
    expect(response.extra['from_cache'], isTrue);
    expect(status.servingFromCache, isTrue);
  });
}
