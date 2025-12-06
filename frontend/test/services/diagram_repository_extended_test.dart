import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/services/diagram_repository.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'diagram_repository_extended_test.mocks.dart';

@GenerateMocks([DiagramsApi])
void main() {
  group('DiagramRepository Extended Tests', () {
    late DiagramRepository repository;
    late MockDiagramsApi mockApi;

    setUp(() {
      mockApi = MockDiagramsApi();
      repository = DiagramRepository(api: mockApi);
    });

    test('diffDiagrams calls API with correct parameters', () async {
      final expectedDiff = DiagramDiffResponse(
        baseDiagramId: 'base-1',
        targetDiagramId: 'target-1',
        components: [],
        relationships: [],
      );

      when(mockApi.diffDiagramsApiV1DiagramsBaseDiagramIdDiffTargetDiagramIdGet(
        'base-1',
        'target-1',
      )).thenAnswer((_) async => expectedDiff);

      final result = await repository.diffDiagrams('base-1', 'target-1');

      expect(result, equals(expectedDiff));
      verify(mockApi.diffDiagramsApiV1DiagramsBaseDiagramIdDiffTargetDiagramIdGet(
        'base-1',
        'target-1',
      )).called(1);
    });

    test('diffDiagrams returns null when API returns null', () async {
      when(mockApi.diffDiagramsApiV1DiagramsBaseDiagramIdDiffTargetDiagramIdGet(
        any,
        any,
      )).thenAnswer((_) async => null);

      final result = await repository.diffDiagrams('base-1', 'target-1');

      expect(result, isNull);
    });
  });
}

