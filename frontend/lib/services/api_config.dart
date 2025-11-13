import '../network/src/api.dart';

/// Centralized configuration for the OpenAPI generated client.
class ApiConfig {
  /// Allows overriding the API base URL at compile time using
  /// `--dart-define=API_BASE_URL=https://example.com`.
  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// Configure the shared [defaultApiClient] before any network calls.
  static void configure({String? baseUrl}) {
    final resolvedBaseUrl = baseUrl ?? _defaultBaseUrl;
    defaultApiClient = ApiClient(basePath: resolvedBaseUrl);
  }

  /// Convenient accessor for the `DiagramsApi`.
  static DiagramsApi diagramsApi() => DiagramsApi(defaultApiClient);

  /// Convenient accessor for the `HealthApi`.
  static HealthApi healthApi() => HealthApi(defaultApiClient);
}
