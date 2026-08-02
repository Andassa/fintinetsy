/// Remote API flags.
/// Example:
/// flutter run --dart-define=USE_REMOTE_API=true
abstract final class ApiConfig {
  static const bool useRemoteApi = bool.fromEnvironment(
    'USE_REMOTE_API',
    defaultValue: false,
  );

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );
}
