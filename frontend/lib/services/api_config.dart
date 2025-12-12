import 'package:flutter/foundation.dart' show kIsWeb;
import '../network/src/api.dart';

/// Centralized configuration for the OpenAPI generated client.
class ApiConfig {
  /// Allows overriding the API base URL at compile time using
  /// `--dart-define=API_BASE_URL=https://example.com`.
  ///
  /// For docker-compose/web, use empty string to use relative paths (nginx proxy).
  /// For local development, use 'http://localhost:8000'.
  static String _getDefaultBaseUrl() {
    const envBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (envBaseUrl.isNotEmpty) {
      return envBaseUrl;
    }

    // In web/browser, use relative path so nginx can proxy to backend
    // This works for both docker-compose and local development with nginx
    if (kIsWeb) {
      // Use empty string for relative paths (nginx will proxy /api to backend)
      return '';
    }

    // For non-web platforms, use localhost
    return 'http://localhost:8000';
  }

  /// Configure the shared [defaultApiClient] before any network calls.
  static void configure({String? baseUrl}) {
    final resolvedBaseUrl = baseUrl ?? _getDefaultBaseUrl();
    defaultApiClient = ApiClient(basePath: resolvedBaseUrl);
  }

  /// Convenient accessor for the `DiagramsApi`.
  static DiagramsApi diagramsApi() => DiagramsApi(defaultApiClient);

  /// Convenient accessor for the `HealthApi`.
  static HealthApi healthApi() => HealthApi(defaultApiClient);

  /// Convenient accessor for the `NfrApi`.
  static NfrApi nfrApi() => NfrApi(defaultApiClient);

  /// Convenient accessor for the `AuthApi`.
  static AuthApi authApi() => AuthApi(defaultApiClient);
}
