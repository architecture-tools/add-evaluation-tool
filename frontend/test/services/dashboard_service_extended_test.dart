import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/services/dashboard_service.dart';
import 'package:architecture_evaluation_tool/services/diagram_repository.dart';
import 'package:architecture_evaluation_tool/services/nfr_repository.dart';
import 'package:architecture_evaluation_tool/services/matrix_repository.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../helpers/test_helpers.dart';
import 'dashboard_service_extended_test.mocks.dart';

@GenerateMocks([DiagramRepository, NFRRepository, MatrixRepository])
void main() {
  group('DashboardService Extended Tests', () {
    late DashboardService service;
    late MockDiagramRepository mockDiagramRepo;
    late MockNFRRepository mockNfrRepo;
    late MockMatrixRepository mockMatrixRepo;

    setUp(() {
      mockDiagramRepo = MockDiagramRepository();
      mockNfrRepo = MockNFRRepository();
      mockMatrixRepo = MockMatrixRepository();
      service = DashboardService(
        diagramRepository: mockDiagramRepo,
        nfrRepository: mockNfrRepo,
        matrixRepository: mockMatrixRepo,
      );
    });

    test('loadDashboard handles diagram fetch error gracefully', () async {
      when(mockDiagramRepo.fetchDiagrams())
          .thenThrow(Exception('Network error'));
      when(mockNfrRepo.fetchNFRs()).thenAnswer((_) async => []);

      final result = await service.loadDashboard();

      expect(result.diagrams, isEmpty);
      expect(result.nfrs, isEmpty);
    });

    test('loadDashboard handles NFR fetch error gracefully', () async {
      when(mockDiagramRepo.fetchDiagrams())
          .thenAnswer((_) async => TestHelpers.createMockDiagrams());
      when(mockNfrRepo.fetchNFRs()).thenThrow(Exception('Network error'));

      final result = await service.loadDashboard();

      expect(result.diagrams, isNotEmpty);
      expect(result.nfrs, isEmpty);
    });

    test('loadDashboard handles matrix fetch error gracefully', () async {
      final diagrams = TestHelpers.createMockDiagrams();
      when(mockDiagramRepo.fetchDiagrams())
          .thenAnswer((_) async => diagrams);
      when(mockNfrRepo.fetchNFRs()).thenAnswer((_) async => []);
      when(mockDiagramRepo.parseDiagram(any))
          .thenAnswer((_) async => TestHelpers.createMockParseResponse());
      when(mockMatrixRepo.fetchMatrix(any))
          .thenThrow(Exception('Matrix error'));

      final result = await service.loadDashboard();

      expect(result.matrix, isNotNull);
    });

    test('loadDashboard handles parse error gracefully', () async {
      final diagrams = TestHelpers.createMockDiagrams();
      when(mockDiagramRepo.fetchDiagrams())
          .thenAnswer((_) async => diagrams);
      when(mockNfrRepo.fetchNFRs()).thenAnswer((_) async => []);
      when(mockMatrixRepo.fetchMatrix(any))
          .thenAnswer((_) async => DiagramMatrixResponse(entries: [], nfrScores: []));
      when(mockDiagramRepo.parseDiagram(any))
          .thenThrow(Exception('Parse error'));

      final result = await service.loadDashboard();

      expect(result.matrix, isNotNull);
    });

    test('reprocessDiagram calls repository', () async {
      when(mockDiagramRepo.parseDiagram('diagram-1'))
          .thenAnswer((_) async => TestHelpers.createMockParseResponse());

      await service.reprocessDiagram('diagram-1');

      verify(mockDiagramRepo.parseDiagram('diagram-1')).called(1);
    });
  });
}

