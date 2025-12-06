import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/widgets/nfr_evaluation_matrix_widget.dart';
import 'package:architecture_evaluation_tool/models/nfr_matrix.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';
import 'package:architecture_evaluation_tool/services/nfr_repository.dart';
import 'package:architecture_evaluation_tool/services/matrix_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockNFRRepository extends Mock implements NFRRepository {}
class MockMatrixRepository extends Mock implements MatrixRepository {}

void main() {
  group('NfrEvaluationMatrixWidget Tests', () {
    late NfrMatrixData matrixData;
    late List<NFRResponse> nfrs;
    late MockNFRRepository mockNfrRepo;
    late MockMatrixRepository mockMatrixRepo;

    setUp(() {
      mockNfrRepo = MockNFRRepository();
      mockMatrixRepo = MockMatrixRepository();
      matrixData = NfrMatrixData(
        diagramId: 'diagram-1',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [
          ComponentColumn(id: 'comp-1', label: 'Component 1'),
          ComponentColumn(id: 'comp-2', label: 'Component 2'),
        ],
        rows: [
          NfrMatrixRow(
            nfrId: 'nfr-1',
            nfr: 'Performance',
            color: Colors.blue,
            scores: {'comp-1': 1, 'comp-2': 0},
          ),
        ],
      );

      nfrs = [
        NFRResponse(
          id: 'nfr-1',
          name: 'Performance',
          createdAt: DateTime.now(),
        ),
      ];
    });

    testWidgets('displays matrix with data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NfrEvaluationMatrixWidget(
              data: matrixData,
              nfrs: nfrs,
              nfrRepository: mockNfrRepo,
              matrixRepository: mockMatrixRepo,
            ),
          ),
        ),
      );

      expect(find.text('NFR Evaluation Matrix - 1.0'), findsOneWidget);
      expect(find.text('Performance'), findsOneWidget);
      expect(find.text('Component 1'), findsOneWidget);
      expect(find.text('Component 2'), findsOneWidget);
    });

    testWidgets('displays empty state when no data', (tester) async {
      final emptyData = NfrMatrixData(
        diagramId: '',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [],
        rows: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NfrEvaluationMatrixWidget(
              data: emptyData,
              nfrs: [],
              nfrRepository: mockNfrRepo,
              matrixRepository: mockMatrixRepo,
            ),
          ),
        ),
      );

      expect(
        find.text('Matrix data will appear once a diagram is parsed and NFRs are defined.'),
        findsOneWidget,
      );
    });

    testWidgets('displays legend', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NfrEvaluationMatrixWidget(
              data: matrixData,
              nfrs: nfrs,
              nfrRepository: mockNfrRepo,
              matrixRepository: mockMatrixRepo,
            ),
          ),
        ),
      );

      expect(find.text('+1 Positive impact'), findsOneWidget);
      expect(find.text('0 Neutral'), findsOneWidget);
      expect(find.text('-1 Negative impact'), findsOneWidget);
    });

    // These tests are covered in comprehensive_test.dart

    testWidgets('displays last updated time', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NfrEvaluationMatrixWidget(
              data: matrixData,
              nfrs: nfrs,
              nfrRepository: mockNfrRepo,
              matrixRepository: mockMatrixRepo,
            ),
          ),
        ),
      );

      expect(find.textContaining('Last updated:'), findsOneWidget);
    });

    testWidgets('displays average scores', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NfrEvaluationMatrixWidget(
              data: matrixData,
              nfrs: nfrs,
              nfrRepository: mockNfrRepo,
              matrixRepository: mockMatrixRepo,
            ),
          ),
        ),
      );

      expect(find.text('Avg Score'), findsOneWidget);
    });
  });
}

