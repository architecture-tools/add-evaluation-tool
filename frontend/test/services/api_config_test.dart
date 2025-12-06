import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/services/api_config.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';

void main() {
  group('ApiConfig Tests', () {
    tearDown(() {
      // Reset to default after each test
      ApiConfig.configure();
    });

    test('configure sets baseUrl when provided', () {
      ApiConfig.configure(baseUrl: 'https://test.example.com');
      expect(defaultApiClient.basePath, equals('https://test.example.com'));
    });

    test('configure uses default baseUrl when not provided', () {
      ApiConfig.configure();
      // Should not throw
      expect(defaultApiClient, isNotNull);
    });

    test('diagramsApi returns DiagramsApi instance', () {
      final api = ApiConfig.diagramsApi();
      expect(api, isA<DiagramsApi>());
    });

    test('healthApi returns HealthApi instance', () {
      final api = ApiConfig.healthApi();
      expect(api, isA<HealthApi>());
    });

    test('nfrApi returns NfrApi instance', () {
      final api = ApiConfig.nfrApi();
      expect(api, isA<NfrApi>());
    });
  });
}
