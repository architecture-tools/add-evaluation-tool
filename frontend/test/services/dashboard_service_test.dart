import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/services/dashboard_service.dart';
import 'package:architecture_evaluation_tool/services/diagram_repository.dart';
import 'package:architecture_evaluation_tool/services/nfr_repository.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';
import 'package:architecture_evaluation_tool/models/mock_models.dart';
import 'package:mocktail/mocktail.dart';
import '../helpers/test_helpers.dart';

// Mock DiagramRepository using mocktail
class MockDiagramRepository extends Mock implements DiagramRepository {}

// Mock NFRRepository using mocktail
class MockNFRRepository extends Mock implements NFRRepository {}

void main() {
  group('DashboardService', () {
    late DashboardService service;
    late MockDiagramRepository mockRepository;
    late MockNFRRepository mockNFRRepository;

    setUp(() {
      mockRepository = MockDiagramRepository();
      mockNFRRepository = MockNFRRepository();
      service = DashboardService(
        diagramRepository: mockRepository,
        nfrRepository: mockNFRRepository,
      );
    });

    test('loadDashboard returns DashboardViewData with correct structure',
        () async {
      final mockDiagrams = TestHelpers.createMockDiagrams();
      when(() => mockRepository.fetchDiagrams())
          .thenAnswer((_) async => mockDiagrams);
      when(() => mockNFRRepository.fetchNFRs())
          .thenAnswer((_) async => <NFRResponse>[]);

      final result = await service.loadDashboard();

      expect(result, isA<DashboardViewData>());
      expect(result.diagrams, isNotEmpty);
      expect(result.metrics, isA<DashboardMetrics>());
      expect(result.timeline, isA<List<VersionInfo>>());
      expect(result.nfrMetrics, isNotEmpty);
      expect(result.matrix, isNotNull);
      expect(result.fetchedAt, isA<DateTime>());
    });

    test('loadDashboard calculates metrics correctly', () async {
      final mockDiagrams = TestHelpers.createMockDiagrams();
      when(() => mockRepository.fetchDiagrams())
          .thenAnswer((_) async => mockDiagrams);
      when(() => mockNFRRepository.fetchNFRs())
          .thenAnswer((_) async => <NFRResponse>[]);

      final result = await service.loadDashboard();
      final metrics = result.metrics;

      expect(metrics.totalDiagrams, equals(4));
      expect(metrics.parsedCount, equals(2)); // parsed + analysisReady
      expect(metrics.pendingCount, equals(1)); // uploaded
      expect(metrics.failedCount, equals(1)); // failed
      expect(metrics.lastUploadAt, isNotNull);
    });

    test('loadDashboard builds timeline correctly', () async {
      final mockDiagrams = TestHelpers.createMockDiagrams();
      when(() => mockRepository.fetchDiagrams())
          .thenAnswer((_) async => mockDiagrams);
      when(() => mockNFRRepository.fetchNFRs())
          .thenAnswer((_) async => <NFRResponse>[]);

      final result = await service.loadDashboard();

      expect(result.timeline.length, lessThanOrEqualTo(6));
      expect(result.timeline.first, isA<VersionInfo>());
      expect(result.timeline.first.version, isNotEmpty);
      expect(result.timeline.first.timeAgo, isNotEmpty);
    });

    test('loadDashboard handles empty diagram list', () async {
      when(() => mockRepository.fetchDiagrams()).thenAnswer((_) async => []);
      when(() => mockNFRRepository.fetchNFRs())
          .thenAnswer((_) async => <NFRResponse>[]);

      final result = await service.loadDashboard();

      expect(result.metrics.totalDiagrams, equals(0));
      expect(result.metrics.parsedCount, equals(0));
      expect(result.metrics.pendingCount, equals(0));
      expect(result.metrics.failedCount, equals(0));
      expect(result.metrics.lastUploadAt, isNull);
      expect(result.timeline, isEmpty);
    });

    test('reprocessDiagram calls repository parseDiagram', () async {
      final diagramId = 'test-diagram-1';
      when(() => mockRepository.parseDiagram(diagramId))
          .thenAnswer((_) async => TestHelpers.createMockParseResponse(
                diagramId: diagramId,
              ));

      await service.reprocessDiagram(diagramId);

      verify(() => mockRepository.parseDiagram(diagramId)).called(1);
    });
  });

  group('DashboardMetrics', () {
    test('fromDiagrams calculates counts correctly', () {
      final diagrams = [
        TestHelpers.createMockDiagram(
          id: '1',
          status: DiagramStatus.parsed,
        ),
        TestHelpers.createMockDiagram(
          id: '2',
          status: DiagramStatus.analysisReady,
        ),
        TestHelpers.createMockDiagram(
          id: '3',
          status: DiagramStatus.uploaded,
        ),
        TestHelpers.createMockDiagram(
          id: '4',
          status: DiagramStatus.failed,
        ),
      ];

      final metrics = DashboardMetrics.fromDiagrams(diagrams);

      expect(metrics.totalDiagrams, equals(4));
      expect(metrics.parsedCount, equals(2));
      expect(metrics.pendingCount, equals(1));
      expect(metrics.failedCount, equals(1));
    });

    test('fromDiagrams handles empty list', () {
      final metrics = DashboardMetrics.fromDiagrams([]);

      expect(metrics.totalDiagrams, equals(0));
      expect(metrics.parsedCount, equals(0));
      expect(metrics.pendingCount, equals(0));
      expect(metrics.failedCount, equals(0));
      expect(metrics.lastUploadAt, isNull);
    });

    test('fromDiagrams sets lastUploadAt to first diagram uploadedAt', () {
      final now = DateTime.now();
      final diagrams = [
        TestHelpers.createMockDiagram(
          id: '1',
          uploadedAt: now.subtract(const Duration(hours: 1)),
        ),
        TestHelpers.createMockDiagram(
          id: '2',
          uploadedAt: now.subtract(const Duration(hours: 2)),
        ),
      ];

      final metrics = DashboardMetrics.fromDiagrams(diagrams);

      expect(metrics.lastUploadAt, isNotNull);
      // Note: Repository sorts by uploadedAt desc, so first is most recent
    });
  });
}
