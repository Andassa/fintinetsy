import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        _memory = null;

  TokenStorage.memory()
      : _storage = null,
        _memory = <String, String>{};

  final FlutterSecureStorage? _storage;
  final Map<String, String>? _memory;

  static const _accessKey = 'uplift_access_token';
  static const _refreshKey = 'uplift_refresh_token';

  Future<String?> readAccessToken() async {
    if (_memory != null) return _memory[_accessKey];
    return _storage!.read(key: _accessKey);
  }

  Future<String?> readRefreshToken() async {
    if (_memory != null) return _memory[_refreshKey];
    return _storage!.read(key: _refreshKey);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (_memory != null) {
      _memory[_accessKey] = accessToken;
      _memory[_refreshKey] = refreshToken;
      return;
    }
    await _storage!.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<void> clear() async {
    if (_memory != null) {
      _memory.clear();
      return;
    }
    await _storage!.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
