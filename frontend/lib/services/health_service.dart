import '../network/src/api.dart';
import 'api_config.dart';

class HealthService {
  HealthService({HealthApi? api}) : _api = api ?? ApiConfig.healthApi();

  final HealthApi _api;

  /// Check backend health status
  Future<HealthStatus> checkHealth() async {
    try {
      final response = await _api.healthCheckApiV1HealthGet();
      return HealthStatus(
        isHealthy: true,
        message: response?.toString() ?? 'OK',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return HealthStatus(
        isHealthy: false,
        message: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }
}

class HealthStatus {
  HealthStatus({
    required this.isHealthy,
    required this.message,
    required this.timestamp,
  });

  final bool isHealthy;
  final String message;
  final DateTime timestamp;
}
