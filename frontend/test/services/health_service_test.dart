import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/services/health_service.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'health_service_test.mocks.dart';

@GenerateMocks([HealthApi])
void main() {
  group('HealthService Tests', () {
    late HealthService healthService;
    late MockHealthApi mockApi;

    setUp(() {
      mockApi = MockHealthApi();
      healthService = HealthService(api: mockApi);
    });

    test('returns healthy status when API call succeeds', () async {
      when(mockApi.healthCheckApiV1HealthGet())
          .thenAnswer((_) async => {'status': 'OK'});

      final status = await healthService.checkHealth();

      expect(status.isHealthy, isTrue);
      expect(status.message, contains('OK'));
      expect(status.timestamp, isA<DateTime>());
    });

    test('returns unhealthy status when API call fails', () async {
      when(mockApi.healthCheckApiV1HealthGet())
          .thenThrow(Exception('Connection failed'));

      final status = await healthService.checkHealth();

      expect(status.isHealthy, isFalse);
      expect(status.message, contains('Connection failed'));
      expect(status.timestamp, isA<DateTime>());
    });

    test('handles null response from API', () async {
      when(mockApi.healthCheckApiV1HealthGet()).thenAnswer((_) async => null);

      final status = await healthService.checkHealth();

      expect(status.isHealthy, isTrue);
      expect(status.message, 'OK');
    });
  });
}
