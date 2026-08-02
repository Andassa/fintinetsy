import 'package:dio/dio.dart';

import '../../../../core/auth/auth_session.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/token_storage.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/entities/password_sent_result.dart';
import '../../domain/entities/reset_method_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository({
    required ApiClient api,
    required TokenStorage tokens,
    required AuthSession session,
  })  : _api = api,
        _tokens = tokens,
        _session = session;

  final ApiClient _api;
  final TokenStorage _tokens;
  final AuthSession _session;

  @override
  Future<UserEntity> signIn(AuthCredentials credentials) async {
    try {
      final response = await _api.raw.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': credentials.email,
          'password': credentials.password,
        },
      );
      return _persistAuth(response.data!);
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _api.raw.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );
      return _persistAuth(response.data!);
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<UserEntity> _persistAuth(Map<String, dynamic> data) async {
    await _tokens.saveTokens(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
    await _session.markAuthenticated();
    final user = data['user'] as Map<String, dynamic>;
    return UserEntity(
      id: user['id'].toString(),
      name: user['name'] as String? ?? '',
      email: user['email'] as String,
      avatarUrl: user['avatar_url'] as String?,
    );
  }

  @override
  Future<List<ResetMethodEntity>> getResetMethods() async {
    try {
      final response = await _api.raw.get<List<dynamic>>('/auth/reset-methods');
      return (response.data ?? []).map((raw) {
        final m = raw as Map<String, dynamic>;
        return ResetMethodEntity(
          id: m['id'] as String,
          type: _mapType(m['type'] as String?),
          title: m['title'] as String,
          description: m['description'] as String,
          iconColorHex: m['icon_color_hex'] as String,
          iconKey: m['icon_key'] as String,
        );
      }).toList();
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  ResetMethodType _mapType(String? raw) {
    switch (raw) {
      case 'two_factor':
        return ResetMethodType.twoFactor;
      case 'google_auth':
        return ResetMethodType.googleAuth;
      default:
        return ResetMethodType.email;
    }
  }

  @override
  Future<PasswordSentResult> requestPasswordReset({
    required String methodId,
    required String email,
  }) async {
    try {
      final response = await _api.raw.post<Map<String, dynamic>>(
        '/auth/password-reset',
        data: {'email': email, 'method': methodId},
      );
      final data = response.data!;
      return PasswordSentResult(
        email: data['email'] as String,
        sentAt: DateTime.parse(data['sent_at'] as String),
        canResend: data['can_resend'] as bool? ?? true,
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<PasswordSentResult> resendPassword({required String email}) async {
    try {
      final response = await _api.raw.post<Map<String, dynamic>>(
        '/auth/password-reset/resend',
        data: {'email': email},
      );
      final data = response.data!;
      return PasswordSentResult(
        email: data['email'] as String,
        sentAt: DateTime.parse(data['sent_at'] as String),
        canResend: data['can_resend'] as bool? ?? true,
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _api.raw.post<void>('/auth/logout');
    } on DioException {
      // Clear local session even if the network call fails.
    }
    await _session.clear();
  }

  @override
  Future<bool> hasValidSession() => Future.value(_session.isAuthenticated);

  Exception _map(DioException e) {
    return e.error is ApiException
        ? e.error as ApiException
        : ApiException.fromDio(e);
  }
}
