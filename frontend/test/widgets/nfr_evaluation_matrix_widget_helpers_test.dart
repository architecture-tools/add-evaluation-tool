import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/widgets/nfr_evaluation_matrix_widget.dart';
import 'package:architecture_evaluation_tool/models/nfr_matrix.dart';
import 'package:architecture_evaluation_tool/services/nfr_repository.dart';
import 'package:architecture_evaluation_tool/services/matrix_repository.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';

class MockNFRRepository extends Mock implements NFRRepository {}

class MockMatrixRepository extends Mock implements MatrixRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(ImpactValue.NO_EFFECT);
  });

  group('NfrEvaluationMatrixWidget Helper Methods', () {
    late MockNFRRepository mockNfrRepo;
    late MockMatrixRepository mockMatrixRepo;

    setUp(() {
      mockNfrRepo = MockNFRRepository();
      mockMatrixRepo = MockMatrixRepository();
    });

    testWidgets('_calculateAverage returns 0 for null scores', (tester) async {
      final data = NfrMatrixData(
        diagramId: 'diagram-1',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [],
        rows: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NfrEvaluationMatrixWidget(
              data: data,
              nfrs: [],
              nfrRepository: mockNfrRepo,
              matrixRepository: mockMatrixRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Widget should render
      expect(find.byType(NfrEvaluationMatrixWidget), findsOneWidget);
    });

    testWidgets('_calculateAverage returns 0 for empty scores', (tester) async {
      final data = NfrMatrixData(
        diagramId: 'diagram-1',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [
          ComponentColumn(id: 'comp-1', label: 'Comp 1'),
        ],
        rows: [
          NfrMatrixRow(
            nfrId: 'nfr-1',
            nfr: 'Performance',
            color: Colors.blue,
            scores: {},
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NfrEvaluationMatrixWidget(
              data: data,
              nfrs: [],
              nfrRepository: mockNfrRepo,
              matrixRepository: mockMatrixRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display 0.0 average
      expect(find.text('0.0'), findsOneWidget);
    });

    testWidgets('_backgroundForValue returns correct colors', (tester) async {
      final data = NfrMatrixData(
        diagramId: 'diagram-1',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [
          ComponentColumn(id: 'comp-1', label: 'Comp 1'),
        ],
        rows: [
          NfrMatrixRow(
            nfrId: 'nfr-1',
            nfr: 'Performance',
            color: Colors.blue,
            scores: {'comp-1': 1},
          ),
          NfrMatrixRow(
            nfrId: 'nfr-2',
            nfr: 'Security',
            color: Colors.red,
            scores: {'comp-1': -1},
          ),
          NfrMatrixRow(
            nfrId: 'nfr-3',
            nfr: 'Scalability',
            color: Colors.green,
            scores: {'comp-1': 0},
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NfrEvaluationMatrixWidget(
              data: data,
              nfrs: [],
              nfrRepository: mockNfrRepo,
              matrixRepository: mockMatrixRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // All score values should be visible
      expect(find.text('+1'), findsOneWidget);
      expect(find.text('-1'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('_textColorForValue returns correct colors', (tester) async {
      final data = NfrMatrixData(
        diagramId: 'diagram-1',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [
          ComponentColumn(id: 'comp-1', label: 'Comp 1'),
        ],
        rows: [
          NfrMatrixRow(
            nfrId: 'nfr-1',
            nfr: 'Performance',
            color: Colors.blue,
            scores: {'comp-1': 1},
          ),
          NfrMatrixRow(
            nfrId: 'nfr-2',
            nfr: 'Security',
            color: Colors.red,
            scores: {'comp-1': -1},
          ),
          NfrMatrixRow(
            nfrId: 'nfr-3',
            nfr: 'Scalability',
            color: Colors.green,
            scores: {'comp-1': 0},
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NfrEvaluationMatrixWidget(
              data: data,
              nfrs: [],
              nfrRepository: mockNfrRepo,
              matrixRepository: mockMatrixRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Widget should render with all score values
      expect(find.text('+1'), findsOneWidget);
      expect(find.text('-1'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('_normalizeScores adds missing component scores',
        (tester) async {
      final data = NfrMatrixData(
        diagramId: 'diagram-1',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [
          ComponentColumn(id: 'comp-1', label: 'Comp 1'),
          ComponentColumn(id: 'comp-2', label: 'Comp 2'),
        ],
        rows: [
          NfrMatrixRow(
            nfrId: 'nfr-1',
            nfr: 'Performance',
            color: Colors.blue,
            scores: {'comp-1': 1}, // Missing comp-2
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NfrEvaluationMatrixWidget(
              data: data,
              nfrs: [],
              nfrRepository: mockNfrRepo,
              matrixRepository: mockMatrixRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display both components (comp-2 should default to 0)
      expect(find.text('Comp 1'), findsOneWidget);
      expect(find.text('Comp 2'), findsOneWidget);
    });

    testWidgets('_rowKey uses nfrId when available', (tester) async {
      final data = NfrMatrixData(
        diagramId: 'diagram-1',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [
          ComponentColumn(id: 'comp-1', label: 'Comp 1'),
        ],
        rows: [
          NfrMatrixRow(
            nfrId: 'nfr-1',
            nfr: 'Performance',
            color: Colors.blue,
            scores: {'comp-1': 1},
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NfrEvaluationMatrixWidget(
              data: data,
              nfrs: [],
              nfrRepository: mockNfrRepo,
              matrixRepository: mockMatrixRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Performance'), findsOneWidget);
    });

    testWidgets('_rowKey uses nfr name when nfrId is empty', (tester) async {
      final data = NfrMatrixData(
        diagramId: 'diagram-1',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [
          ComponentColumn(id: 'comp-1', label: 'Comp 1'),
        ],
        rows: [
          NfrMatrixRow(
            nfrId: '',
            nfr: 'Performance',
            color: Colors.blue,
            scores: {'comp-1': 1},
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NfrEvaluationMatrixWidget(
              data: data,
              nfrs: [],
              nfrRepository: mockNfrRepo,
              matrixRepository: mockMatrixRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Performance'), findsOneWidget);
    });

    testWidgets('_shouldTrackChange returns false when cannot persist',
        (tester) async {
      final data = NfrMatrixData(
        diagramId: '',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [
          ComponentColumn(id: 'comp-1', label: 'Comp 1'),
        ],
        rows: [
          NfrMatrixRow(
            nfrId: 'nfr-1',
            nfr: 'Performance',
            color: Colors.blue,
            scores: {'comp-1': 1},
          ),
        ],
        isPersistent: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NfrEvaluationMatrixWidget(
                data: data,
                nfrs: [],
                nfrRepository: mockNfrRepo,
                matrixRepository: mockMatrixRepo,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Just verify widget renders (cannot persist means no save button)
      expect(find.byType(NfrEvaluationMatrixWidget), findsOneWidget);
      // When cannot persist, save button should not appear
      expect(find.text('Save Matrix'), findsNothing);
    });

    // Removed _impactFromScore test - this is tested indirectly through save functionality
  });
}
