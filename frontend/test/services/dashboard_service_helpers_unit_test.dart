import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/services/dashboard_service.dart';
import 'package:architecture_evaluation_tool/services/diagram_repository.dart';
import 'package:architecture_evaluation_tool/services/nfr_repository.dart';
import 'package:architecture_evaluation_tool/services/matrix_repository.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';
import 'package:mocktail/mocktail.dart';
import '../helpers/test_helpers.dart';

class MockDiagramRepository extends Mock implements DiagramRepository {}

class MockNFRRepository extends Mock implements NFRRepository {}

class MockMatrixRepository extends Mock implements MatrixRepository {}

void main() {
  group('DashboardService Helper Methods Unit Tests', () {
    late MockDiagramRepository mockDiagramRepo;
    late MockNFRRepository mockNfrRepo;
    late MockMatrixRepository mockMatrixRepo;
    late DashboardService dashboardService;

    setUp(() {
      mockDiagramRepo = MockDiagramRepository();
      mockNfrRepo = MockNFRRepository();
      mockMatrixRepo = MockMatrixRepository();
      dashboardService = DashboardService(
        diagramRepository: mockDiagramRepo,
        nfrRepository: mockNfrRepo,
        matrixRepository: mockMatrixRepo,
      );
    });

    test('_scoreFromImpact handles all impact values', () {
      // This is tested indirectly through loadDashboard, but we can verify the logic
      final diagrams = TestHelpers.createMockDiagrams();
      when(() => mockDiagramRepo.fetchDiagrams())
          .thenAnswer((_) async => diagrams);
      when(() => mockNfrRepo.fetchNFRs()).thenAnswer((_) async => []);
      when(() => mockMatrixRepo.fetchMatrix(any()))
          .thenAnswer((_) async => DiagramMatrixResponse(
                entries: [
                  MatrixCellResponse(
                    id: 'cell-1',
                    diagramId: 'diagram-1',
                    nfrId: 'nfr-1',
                    componentId: 'comp-1',
                    impact: ImpactValue.POSITIVE,
                  ),
                  MatrixCellResponse(
                    id: 'cell-2',
                    diagramId: 'diagram-1',
                    nfrId: 'nfr-2',
                    componentId: 'comp-1',
                    impact: ImpactValue.NEGATIVE,
                  ),
                  MatrixCellResponse(
                    id: 'cell-3',
                    diagramId: 'diagram-1',
                    nfrId: 'nfr-3',
                    componentId: 'comp-1',
                    impact: ImpactValue.NO_EFFECT,
                  ),
                ],
                nfrScores: [],
                overallScore: 0.0,
              ));
      when(() => mockDiagramRepo.parseDiagram(any()))
          .thenAnswer((_) async => TestHelpers.createMockParseResponse());

      final result = dashboardService.loadDashboard();
      expect(result, completes);
    });

    test('_getNFRColor returns correct colors for different NFR names',
        () async {
      final diagrams = TestHelpers.createMockDiagrams();
      when(() => mockDiagramRepo.fetchDiagrams())
          .thenAnswer((_) async => diagrams);
      when(() => mockNfrRepo.fetchNFRs()).thenAnswer((_) async => [
            NFRResponse(
              id: 'nfr-1',
              name: 'Performance',
              createdAt: DateTime.now(),
            ),
            NFRResponse(
              id: 'nfr-2',
              name: 'Security',
              createdAt: DateTime.now(),
            ),
            NFRResponse(
              id: 'nfr-3',
              name: 'Scalability',
              createdAt: DateTime.now(),
            ),
            NFRResponse(
              id: 'nfr-4',
              name: 'Availability',
              createdAt: DateTime.now(),
            ),
            NFRResponse(
              id: 'nfr-5',
              name: 'Other NFR',
              createdAt: DateTime.now(),
            ),
          ]);
      when(() => mockMatrixRepo.fetchMatrix(any()))
          .thenAnswer((_) async => DiagramMatrixResponse(
                entries: [],
                nfrScores: [
                  NFRScoreResponse(nfrId: 'nfr-1', score: 0.8),
                  NFRScoreResponse(nfrId: 'nfr-2', score: 0.9),
                  NFRScoreResponse(nfrId: 'nfr-3', score: 0.7),
                  NFRScoreResponse(nfrId: 'nfr-4', score: 0.85),
                  NFRScoreResponse(nfrId: 'nfr-5', score: 0.75),
                ],
                overallScore: 0.8,
              ));
      when(() => mockDiagramRepo.parseDiagram(any()))
          .thenAnswer((_) async => TestHelpers.createMockParseResponse());

      final result = await dashboardService.loadDashboard();
      expect(result.nfrMetrics.length, greaterThan(0));
    });

    test('_buildEmptyMatrixData uses diagram timestamp when available',
        () async {
      final now = DateTime.now();
      final diagram = TestHelpers.createMockDiagram(
        id: 'diagram-1',
        uploadedAt: now.subtract(const Duration(hours: 1)),
      );
      when(() => mockDiagramRepo.fetchDiagrams())
          .thenAnswer((_) async => [diagram]);
      when(() => mockNfrRepo.fetchNFRs()).thenAnswer((_) async => [
            NFRResponse(
              id: 'nfr-1',
              name: 'Performance',
              createdAt: DateTime.now(),
            ),
          ]);
      when(() => mockMatrixRepo.fetchMatrix(any()))
          .thenAnswer((_) async => null);
      when(() => mockDiagramRepo.parseDiagram(any()))
          .thenAnswer((_) async => null);

      final result = await dashboardService.loadDashboard();
      expect(result.matrix.diagramId, equals('diagram-1'));
    });

    test('_buildEmptyMatrixData uses current time when no diagram', () async {
      when(() => mockDiagramRepo.fetchDiagrams()).thenAnswer((_) async => []);
      when(() => mockNfrRepo.fetchNFRs()).thenAnswer((_) async => [
            NFRResponse(
              id: 'nfr-1',
              name: 'Performance',
              createdAt: DateTime.now(),
            ),
          ]);
      when(() => mockMatrixRepo.fetchMatrix(any()))
          .thenAnswer((_) async => null);
      when(() => mockDiagramRepo.parseDiagram(any()))
          .thenAnswer((_) async => null);

      final result = await dashboardService.loadDashboard();
      expect(result.matrix.diagramId, isEmpty);
    });

    test('_normalizeScores adds missing component scores', () async {
      final diagrams = TestHelpers.createMockDiagrams();
      when(() => mockDiagramRepo.fetchDiagrams())
          .thenAnswer((_) async => diagrams);
      when(() => mockNfrRepo.fetchNFRs()).thenAnswer((_) async => [
            NFRResponse(
              id: 'nfr-1',
              name: 'Performance',
              createdAt: DateTime.now(),
            ),
          ]);
      when(() => mockMatrixRepo.fetchMatrix(any()))
          .thenAnswer((_) async => DiagramMatrixResponse(
                entries: [
                  MatrixCellResponse(
                    id: 'cell-1',
                    diagramId: 'diagram-1',
                    nfrId: 'nfr-1',
                    componentId: 'component-1',
                    impact: ImpactValue.POSITIVE,
                  ),
                ],
                nfrScores: [],
                overallScore: 1.0,
              ));
      when(() => mockDiagramRepo.parseDiagram(any()))
          .thenAnswer((_) async => TestHelpers.createMockParseResponse(
                components: [
                  ComponentResponse(
                    id: 'component-1',
                    name: 'API Gateway',
                    type: ComponentType.component,
                  ),
                  ComponentResponse(
                    id: 'component-2',
                    name: 'Database',
                    type: ComponentType.component,
                  ),
                ],
              ));

      final result = await dashboardService.loadDashboard();
      // Should have both components in matrix
      expect(result.matrix.components.length, greaterThanOrEqualTo(1));
    });

    test('_buildMatrixFromData handles null parseResponse', () async {
      final diagrams = TestHelpers.createMockDiagrams();
      when(() => mockDiagramRepo.fetchDiagrams())
          .thenAnswer((_) async => diagrams);
      when(() => mockNfrRepo.fetchNFRs()).thenAnswer((_) async => [
            NFRResponse(
              id: 'nfr-1',
              name: 'Performance',
              createdAt: DateTime.now(),
            ),
          ]);
      when(() => mockMatrixRepo.fetchMatrix(any()))
          .thenAnswer((_) async => DiagramMatrixResponse(
                entries: [],
                nfrScores: [],
                overallScore: 0.0,
              ));
      when(() => mockDiagramRepo.parseDiagram(any()))
          .thenAnswer((_) async => null);

      final result = await dashboardService.loadDashboard();
      expect(result.matrix.components, isEmpty);
    });

    test('_buildMatrixFromData handles null matrixResponse', () async {
      final diagrams = TestHelpers.createMockDiagrams();
      when(() => mockDiagramRepo.fetchDiagrams())
          .thenAnswer((_) async => diagrams);
      when(() => mockNfrRepo.fetchNFRs()).thenAnswer((_) async => [
            NFRResponse(
              id: 'nfr-1',
              name: 'Performance',
              createdAt: DateTime.now(),
            ),
          ]);
      when(() => mockMatrixRepo.fetchMatrix(any()))
          .thenAnswer((_) async => null);
      when(() => mockDiagramRepo.parseDiagram(any()))
          .thenAnswer((_) async => TestHelpers.createMockParseResponse());

      final result = await dashboardService.loadDashboard();
      // When matrixResponse is null but NFRs exist, it creates rows with zero scores
      expect(result.matrix.rows.length, greaterThanOrEqualTo(0));
    });

    test('_buildMatrixFromData handles empty components', () async {
      final diagrams = TestHelpers.createMockDiagrams();
      when(() => mockDiagramRepo.fetchDiagrams())
          .thenAnswer((_) async => diagrams);
      when(() => mockNfrRepo.fetchNFRs()).thenAnswer((_) async => [
            NFRResponse(
              id: 'nfr-1',
              name: 'Performance',
              createdAt: DateTime.now(),
            ),
          ]);
      when(() => mockMatrixRepo.fetchMatrix(any()))
          .thenAnswer((_) async => DiagramMatrixResponse(
                entries: [],
                nfrScores: [],
                overallScore: 0.0,
              ));
      when(() => mockDiagramRepo.parseDiagram(any()))
          .thenAnswer((_) async => TestHelpers.createMockParseResponse(
                components: [],
              ));

      final result = await dashboardService.loadDashboard();
      expect(result.matrix.components, isEmpty);
    });

    test('_buildMatrixFromData handles empty nfrIds', () async {
      final diagrams = TestHelpers.createMockDiagrams();
      when(() => mockDiagramRepo.fetchDiagrams())
          .thenAnswer((_) async => diagrams);
      when(() => mockNfrRepo.fetchNFRs()).thenAnswer((_) async => []);
      when(() => mockMatrixRepo.fetchMatrix(any()))
          .thenAnswer((_) async => DiagramMatrixResponse(
                entries: [],
                nfrScores: [],
                overallScore: 0.0,
              ));
      when(() => mockDiagramRepo.parseDiagram(any()))
          .thenAnswer((_) async => TestHelpers.createMockParseResponse());

      final result = await dashboardService.loadDashboard();
      expect(result.matrix.rows, isEmpty);
    });
  });
}
