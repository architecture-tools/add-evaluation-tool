import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/services/matrix_repository.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'matrix_repository_test.mocks.dart';

@GenerateMocks([DiagramsApi])
void main() {
  group('MatrixRepository Tests', () {
    late MatrixRepository repository;
    late MockDiagramsApi mockApi;

    setUp(() {
      mockApi = MockDiagramsApi();
      repository = MatrixRepository(api: mockApi);
    });

    test('fetchMatrix returns matrix response', () async {
      final expectedResponse = DiagramMatrixResponse(
        entries: [],
        nfrScores: [],
      );
      when(mockApi.getMatrixApiV1DiagramsDiagramIdMatrixGet('test-id'))
          .thenAnswer((_) async => expectedResponse);

      final result = await repository.fetchMatrix('test-id');

      expect(result, equals(expectedResponse));
      verify(mockApi.getMatrixApiV1DiagramsDiagramIdMatrixGet('test-id'))
          .called(1);
    });

    test('updateCell returns updated response', () async {
      final request = UpdateMatrixCellRequest(
        nfrId: 'nfr-1',
        componentId: 'comp-1',
        impact: ImpactValue.POSITIVE,
      );
      final expectedResponse = MatrixCellUpdateResponse(
        entry: MatrixCellResponse(
          id: 'id',
          diagramId: 'diagram-1',
          nfrId: 'nfr-1',
          componentId: 'comp-1',
          impact: ImpactValue.POSITIVE,
        ),
        nfrScore: NFRScoreResponse(
          nfrId: 'nfr-1',
          score: 1.0,
        ),
      );

      when(mockApi.updateMatrixCellApiV1DiagramsDiagramIdMatrixPut(
        'diagram-1',
        request,
      )).thenAnswer((_) async => expectedResponse);

      final result = await repository.updateCell(
        diagramId: 'diagram-1',
        nfrId: 'nfr-1',
        componentId: 'comp-1',
        impact: ImpactValue.POSITIVE,
      );

      expect(result, equals(expectedResponse));
    });

    test('updateCell throws exception when response is null', () async {
      final request = UpdateMatrixCellRequest(
        nfrId: 'nfr-1',
        componentId: 'comp-1',
        impact: ImpactValue.POSITIVE,
      );

      when(mockApi.updateMatrixCellApiV1DiagramsDiagramIdMatrixPut(
        'diagram-1',
        request,
      )).thenAnswer((_) async => null);

      expect(
        () => repository.updateCell(
          diagramId: 'diagram-1',
          nfrId: 'nfr-1',
          componentId: 'comp-1',
          impact: ImpactValue.POSITIVE,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('updateCell throws exception when API call fails', () async {
      final request = UpdateMatrixCellRequest(
        nfrId: 'nfr-1',
        componentId: 'comp-1',
        impact: ImpactValue.POSITIVE,
      );

      when(mockApi.updateMatrixCellApiV1DiagramsDiagramIdMatrixPut(
        'diagram-1',
        request,
      )).thenThrow(Exception('Network error'));

      expect(
        () => repository.updateCell(
          diagramId: 'diagram-1',
          nfrId: 'nfr-1',
          componentId: 'comp-1',
          impact: ImpactValue.POSITIVE,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
