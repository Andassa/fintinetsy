import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:fintinetsy/core/network/api_client.dart';
import 'package:fintinetsy/core/network/etag_cache.dart';
import 'package:fintinetsy/core/network/token_storage.dart';

void main() {
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
      }),
      data: Matchers.any,
    );
    DioAdapter(dio: retryDio).onGet(
      '/home/dashboard',
      (server) => server.reply(200, {'ok': true}),
    );

    final api = ApiClient(
      tokenStorage: tokens,
      etagCache: EtagCache.memory(),
      dio: dio,
      refreshDio: refreshDio,
      retryDio: retryDio,
    );

    final response = await api.raw.get<Map<String, dynamic>>('/home/dashboard');
    expect(response.data?['ok'], isTrue);
    expect(await tokens.readAccessToken(), 'new-access');
    expect(await tokens.readRefreshToken(), 'new-refresh');
  });

  test('GET responses are stored for offline ETag cache', () async {
    final etag = EtagCache.memory();
    final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
    final adapter = DioAdapter(dio: dio);
    final api = ApiClient(
      tokenStorage: TokenStorage.memory(),
      etagCache: etag,
      dio: dio,
    );

    adapter.onGet(
      '/workouts/browse',
      (server) => server.reply(
        200,
        {'title': 'Browse'},
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          'etag': ['"v1"'],
        },
      ),
    );

    await api.raw.get<Map<String, dynamic>>('/workouts/browse');
    expect(etag.etagFor('/workouts/browse'), 'v1');
    expect(etag.bodyFor('/workouts/browse'), contains('Browse'));
  });
}
