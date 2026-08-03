import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// API configuration for the connected FastAPI backend.
abstract final class ApiConfig {
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Override with `--dart-define=API_BASE_URL=...` when needed.
  ///
  /// Defaults:
  /// - Android emulator → `http://10.0.2.2:8000/api/v1` (host loopback)
  /// - iOS / desktop / others → `http://127.0.0.1:8000/api/v1`
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  /// Always true — the app is a full-stack connected client.
  static const bool useRemoteApi = true;
}
