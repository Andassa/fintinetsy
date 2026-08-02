/// API configuration.
///
/// Remote API is ON by default. To force local fakes:
/// flutter run --dart-define=USE_FAKE_DATA=true
abstract final class ApiConfig {
  static const bool useFakeData = bool.fromEnvironment(
    'USE_FAKE_DATA',
    defaultValue: false,
  );

  static bool get useRemoteApi => !useFakeData;

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );
}
