import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:fintinetsy/core/auth/auth_session.dart';
import 'package:fintinetsy/core/network/api_client.dart';
import 'package:fintinetsy/core/network/etag_cache.dart';
import 'package:fintinetsy/core/network/token_storage.dart';
import 'package:fintinetsy/features/auth/data/repositories/http_auth_repository.dart';
import 'package:fintinetsy/features/auth/domain/entities/auth_credentials.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late TokenStorage tokens;
  late AuthSession session;
  late HttpAuthRepository repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
    adapter = DioAdapter(dio: dio);
    tokens = TokenStorage.memory();
    session = AuthSession(tokens);
    final api = ApiClient(
      tokenStorage: tokens,
      etagCache: EtagCache.memory(),
      dio: dio,
    );
    repository = HttpAuthRepository(
      api: api,
      tokens: tokens,
      session: session,
    );
  });

  test('signIn persists JWT tokens and returns user', () async {
    adapter.onPost(
      '/auth/login',
      (server) => server.reply(200, {
        'access_token': 'access-abc',
        'refresh_token': 'refresh-xyz',
        'token_type': 'bearer',
        'user': {
          'id': 'u1',
          'email': 'demo@uplift.ai',
          'name': 'Demo',
          'avatar_url': null,
        },
      }),
      data: Matchers.any,
    );

    final user = await repository.signIn(
      const AuthCredentials(email: 'demo@uplift.ai', password: 'secret123'),
    );

    expect(user.email, 'demo@uplift.ai');
    expect(user.name, 'Demo');
    expect(await tokens.readAccessToken(), 'access-abc');
    expect(await tokens.readRefreshToken(), 'refresh-xyz');
    expect(session.isAuthenticated, isTrue);
  });

  test('signOut clears local session', () async {
    await tokens.saveTokens(accessToken: 'a', refreshToken: 'r');
    await session.markAuthenticated();

    adapter.onPost(
      '/auth/logout',
      (server) => server.reply(204, null),
      data: Matchers.any,
    );

    await repository.signOut();
    expect(await tokens.readAccessToken(), isNull);
    expect(session.isAuthenticated, isFalse);
  });
}
