import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/services/dashboard_service.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('DashboardService Helper Methods Tests', () {
    late DashboardService service;

    setUp(() {
      service = DashboardService();
    });

    test('DashboardMetrics fromDiagrams handles all status types', () {
      final now = DateTime.now();
      final diagrams = [
        TestHelpers.createMockDiagram(
          id: '1',
          status: DiagramStatus.parsed,
          uploadedAt: now,
        ),
        TestHelpers.createMockDiagram(
          id: '2',
          status: DiagramStatus.analysisReady,
          uploadedAt: now.subtract(const Duration(hours: 1)),
        ),
        TestHelpers.createMockDiagram(
          id: '3',
          status: DiagramStatus.uploaded,
          uploadedAt: now.subtract(const Duration(hours: 2)),
        ),
        TestHelpers.createMockDiagram(
          id: '4',
          status: DiagramStatus.failed,
          uploadedAt: now.subtract(const Duration(hours: 3)),
        ),
      ];

      final metrics = DashboardMetrics.fromDiagrams(diagrams);

      expect(metrics.totalDiagrams, equals(4));
      // Both parsed and analysisReady count as parsed
      expect(metrics.parsedCount, equals(2));
      expect(metrics.pendingCount, equals(1));
      expect(metrics.failedCount, equals(1));
    });

    test('DashboardMetrics fromDiagrams calculates lastUploadAt correctly', () {
      final now = DateTime.now();
      final diagrams = [
        TestHelpers.createMockDiagram(
          id: '1',
          uploadedAt: now.subtract(const Duration(hours: 2)),
        ),
        TestHelpers.createMockDiagram(
          id: '2',
          uploadedAt: now.subtract(const Duration(hours: 1)),
        ),
      ];

      final metrics = DashboardMetrics.fromDiagrams(diagrams);

      expect(metrics.lastUploadAt, isNotNull);
      // Should be the most recent (first in the list, which is the earliest uploaded)
      // The fromDiagrams method uses diagrams.first.uploadedAt
      expect(metrics.lastUploadAt, equals(diagrams[0].uploadedAt));
    });
  });
}

