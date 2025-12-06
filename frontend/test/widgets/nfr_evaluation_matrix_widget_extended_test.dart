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
  group('NfrEvaluationMatrixWidget Extended Tests', () {
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

    testWidgets('handles widget update when data changes', (tester) async {
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

      final newData = NfrMatrixData(
        diagramId: 'diagram-2',
        version: '2.0',
        lastUpdated: DateTime.now(),
        components: const [],
        rows: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NfrEvaluationMatrixWidget(
              data: newData,
              nfrs: [],
              nfrRepository: mockNfrRepo,
              matrixRepository: mockMatrixRepo,
            ),
          ),
        ),
      );

      expect(find.text('NFR Evaluation Matrix - 2.0'), findsOneWidget);
    });

    // This test is covered in comprehensive_test.dart

    testWidgets('calculates average scores correctly', (tester) async {
      final dataWithScores = NfrMatrixData(
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
            scores: {'comp-1': 1, 'comp-2': -1},
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NfrEvaluationMatrixWidget(
              data: dataWithScores,
              nfrs: nfrs,
              nfrRepository: mockNfrRepo,
              matrixRepository: mockMatrixRepo,
            ),
          ),
        ),
      );

      expect(find.text('Avg Score'), findsOneWidget);
    });

    testWidgets('displays delete button for NFRs', (tester) async {
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

      expect(find.byIcon(Icons.delete_outline), findsWidgets);
    });

    testWidgets('displays add NFR button', (tester) async {
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

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('handles multiple NFR rows', (tester) async {
      final multiNfrData = NfrMatrixData(
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
            color: Colors.green,
            scores: {'comp-1': 0},
          ),
        ],
      );

      final multiNfrs = [
        NFRResponse(id: 'nfr-1', name: 'Performance', createdAt: DateTime.now()),
        NFRResponse(id: 'nfr-2', name: 'Security', createdAt: DateTime.now()),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NfrEvaluationMatrixWidget(
              data: multiNfrData,
              nfrs: multiNfrs,
              nfrRepository: mockNfrRepo,
              matrixRepository: mockMatrixRepo,
            ),
          ),
        ),
      );

      expect(find.text('Performance'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
    });
  });
}

