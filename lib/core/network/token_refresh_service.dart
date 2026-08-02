import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'token_storage.dart';

/// Rotates JWT access/refresh tokens via `POST /auth/refresh`.
///
/// Used by [ApiClient] when a request returns HTTP 401. The refresh call uses a
/// dedicated Dio instance (no auth interceptor) to avoid recursive 401 loops.
class TokenRefreshService {
  TokenRefreshService({
    required TokenStorage tokenStorage,
    required Dio refreshDio,
  })  : _tokens = tokenStorage,
        _dio = refreshDio;

  final TokenStorage _tokens;
  final Dio _dio;
  bool _inFlight = false;

  /// Exchanges the stored refresh token for a new access + refresh pair.
  /// Returns `true` when [TokenStorage] was updated successfully.
  Future<bool> rotateTokens() async {
    if (_inFlight) return false;
    final refresh = await _tokens.readRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      debugPrint('TokenRefreshService: no refresh token available');
      return false;
    }

    _inFlight = true;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refresh},
      );
      final data = response.data;
      if (data == null) return false;

      final access = data['access_token'] as String?;
      final nextRefresh = data['refresh_token'] as String?;
      if (access == null ||
          access.isEmpty ||
          nextRefresh == null ||
          nextRefresh.isEmpty) {
        return false;
      }

      await _tokens.saveTokens(
        accessToken: access,
        refreshToken: nextRefresh,
      );
      debugPrint('TokenRefreshService: tokens rotated successfully');
      return true;
    } catch (e, st) {
      debugPrint('TokenRefreshService: rotation failed: $e\n$st');
      return false;
    } finally {
      _inFlight = false;
    }
  }
}
