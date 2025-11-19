import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/services/diagram_repository.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../helpers/test_helpers.dart';

// Mock DiagramsApi using mocktail
class MockDiagramsApi extends Mock implements DiagramsApi {}

void main() {
  setUpAll(() {
    // Register fallback value for MultipartFile
    registerFallbackValue(
      http.MultipartFile.fromBytes(
        'test',
        Uint8List.fromList([1, 2, 3]),
        filename: 'test.txt',
      ),
    );
  });

  group('DiagramRepository', () {
    late DiagramRepository repository;
    late MockDiagramsApi mockApi;

    setUp(() {
      mockApi = MockDiagramsApi();
      repository = DiagramRepository(api: mockApi);
    });

    test('fetchDiagrams returns sorted list of diagrams', () async {
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
        TestHelpers.createMockDiagram(
          id: '3',
          uploadedAt: now,
        ),
      ];
      when(() => mockApi.listDiagramsApiV1DiagramsGet())
          .thenAnswer((_) async => diagrams);
      repository = DiagramRepository(api: mockApi);

      final result = await repository.fetchDiagrams();

      expect(result.length, equals(3));
      // Should be sorted by uploadedAt descending (most recent first)
      expect(result.first.id, equals('3'));
      expect(result.last.id, equals('1'));
    });

    test('fetchDiagrams returns empty list when API returns null', () async {
      when(() => mockApi.listDiagramsApiV1DiagramsGet())
          .thenAnswer((_) async => null);
      repository = DiagramRepository(api: mockApi);

      final result = await repository.fetchDiagrams();

      expect(result, isEmpty);
    });

    test('uploadDiagram uploads file and returns DiagramResponse', () async {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final filename = 'test.puml';
      final displayName = 'Test Diagram';
      final mockResponse = TestHelpers.createMockDiagram(
        id: 'new-diagram',
        name: displayName,
        status: DiagramStatus.uploaded,
      );

      when(() => mockApi.uploadDiagramApiV1DiagramsPost(
            any(),
            name: any(named: 'name'),
          )).thenAnswer((_) async => mockResponse);

      final result = await repository.uploadDiagram(
        bytes: bytes,
        filename: filename,
        displayName: displayName,
      );

      expect(result, isA<DiagramResponse>());
      expect(result.name, equals(displayName));
      expect(result.status, equals(DiagramStatus.uploaded));
    });

    test('uploadDiagram throws exception when upload fails', () async {
      when(() => mockApi.uploadDiagramApiV1DiagramsPost(
            any(),
            name: any(named: 'name'),
          )).thenThrow(Exception('Upload failed'));

      final bytes = Uint8List.fromList([1, 2, 3]);
      final filename = 'test.puml';

      expect(
        () => repository.uploadDiagram(
          bytes: bytes,
          filename: filename,
        ),
        throwsException,
      );
    });

    test('uploadDiagram throws exception when response is null', () async {
      when(() => mockApi.uploadDiagramApiV1DiagramsPost(
            any(),
            name: any(named: 'name'),
          )).thenAnswer((_) async => null);

      final bytes = Uint8List.fromList([1, 2, 3]);
      final filename = 'test.puml';

      expect(
        () => repository.uploadDiagram(
          bytes: bytes,
          filename: filename,
        ),
        throwsException,
      );
    });

    test('parseDiagram calls API and returns ParseDiagramResponse', () async {
      final diagramId = 'test-diagram-1';
      final mockResponse = ParseDiagramResponse(
        diagram: TestHelpers.createMockDiagram(
          id: diagramId,
          status: DiagramStatus.parsed,
        ),
        components: [],
        relationships: [],
      );

      when(() => mockApi.parseDiagramApiV1DiagramsDiagramIdParsePost(diagramId))
          .thenAnswer((_) async => mockResponse);

      final result = await repository.parseDiagram(diagramId);

      expect(result, isA<ParseDiagramResponse>());
      expect(result?.diagram.id, equals(diagramId));
      expect(result?.diagram.status, equals(DiagramStatus.parsed));
    });

    test('parseDiagram handles API errors gracefully', () async {
      final diagramId = 'test-diagram-1';
      when(() => mockApi.parseDiagramApiV1DiagramsDiagramIdParsePost(diagramId))
          .thenThrow(Exception('Parse failed'));

      expect(
        () => repository.parseDiagram(diagramId),
        throwsException,
      );
    });

    test('getDiagram retrieves diagram by ID', () async {
      final diagram = TestHelpers.createMockDiagram(
        id: 'test-id',
        name: 'Test Diagram',
      );
      when(() => mockApi.getDiagramApiV1DiagramsDiagramIdGet('test-id'))
          .thenAnswer((_) async => diagram);

      final result = await repository.getDiagram('test-id');

      expect(result, isNotNull);
      expect(result?.id, equals('test-id'));
      expect(result?.name, equals('Test Diagram'));
    });
  });
}

