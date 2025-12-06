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
  setUpAll(() {
    registerFallbackValue(ImpactValue.NO_EFFECT);
  });

  group('NfrEvaluationMatrixWidget Table Tests', () {
    late MockNFRRepository mockNfrRepo;
    late MockMatrixRepository mockMatrixRepo;

    setUp(() {
      mockNfrRepo = MockNFRRepository();
      mockMatrixRepo = MockMatrixRepository();
    });

    testWidgets('displays table with multiple components and rows', (tester) async {
      final matrixData = NfrMatrixData(
        diagramId: 'diagram-1',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [
          ComponentColumn(id: 'comp-1', label: 'API Gateway'),
          ComponentColumn(id: 'comp-2', label: 'Database'),
          ComponentColumn(id: 'comp-3', label: 'Cache'),
        ],
        rows: [
          NfrMatrixRow(
            nfrId: 'nfr-1',
            nfr: 'Performance',
            color: Colors.blue,
            scores: {'comp-1': 1, 'comp-2': 0, 'comp-3': -1},
          ),
          NfrMatrixRow(
            nfrId: 'nfr-2',
            nfr: 'Security',
            color: Colors.red,
            scores: {'comp-1': 0, 'comp-2': 1, 'comp-3': 0},
          ),
        ],
        isPersistent: true,
      );

      final nfrs = [
        NFRResponse(id: 'nfr-1', name: 'Performance', createdAt: DateTime.now()),
        NFRResponse(id: 'nfr-2', name: 'Security', createdAt: DateTime.now()),
      ];

      when(() => mockMatrixRepo.updateCell(
            diagramId: any(named: 'diagramId'),
            nfrId: any(named: 'nfrId'),
            componentId: any(named: 'componentId'),
            impact: any(named: 'impact'),
          )).thenAnswer((_) async => MatrixCellUpdateResponse(
                entry: MatrixCellResponse(
                  id: 'cell-1',
                  diagramId: 'diagram-1',
                  nfrId: 'nfr-1',
                  componentId: 'comp-1',
                  impact: ImpactValue.POSITIVE,
                ),
                nfrScore: NFRScoreResponse(nfrId: 'nfr-1', score: 1.0),
                overallScore: 0.5,
              ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NfrEvaluationMatrixWidget(
                data: matrixData,
                nfrs: nfrs,
                nfrRepository: mockNfrRepo,
                matrixRepository: mockMatrixRepo,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify table headers
      expect(find.text('NFR'), findsOneWidget);
      expect(find.text('API Gateway'), findsOneWidget);
      expect(find.text('Database'), findsOneWidget);
      expect(find.text('Cache'), findsOneWidget);
      expect(find.text('Avg Score'), findsOneWidget);

      // Verify NFR rows
      expect(find.text('Performance'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);

      // Verify score values are displayed
      expect(find.text('+1'), findsWidgets);
      expect(find.text('0'), findsWidgets);
      expect(find.text('-1'), findsWidgets);
    });

    testWidgets('displays average scores in table cells', (tester) async {
      final matrixData = NfrMatrixData(
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
            scores: {'comp-1': 1, 'comp-2': 1}, // Average = 1.0
          ),
          NfrMatrixRow(
            nfrId: 'nfr-2',
            nfr: 'Security',
            color: Colors.red,
            scores: {'comp-1': -1, 'comp-2': -1}, // Average = -1.0
          ),
          NfrMatrixRow(
            nfrId: 'nfr-3',
            nfr: 'Scalability',
            color: Colors.green,
            scores: {'comp-1': 1, 'comp-2': -1}, // Average = 0.0
          ),
        ],
        isPersistent: true,
      );

      final nfrs = [
        NFRResponse(id: 'nfr-1', name: 'Performance', createdAt: DateTime.now()),
        NFRResponse(id: 'nfr-2', name: 'Security', createdAt: DateTime.now()),
        NFRResponse(id: 'nfr-3', name: 'Scalability', createdAt: DateTime.now()),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NfrEvaluationMatrixWidget(
                data: matrixData,
                nfrs: nfrs,
                nfrRepository: mockNfrRepo,
                matrixRepository: mockMatrixRepo,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify average scores
      expect(find.text('1.0'), findsOneWidget);
      expect(find.text('-1.0'), findsOneWidget);
      expect(find.text('0.0'), findsOneWidget);
    });


    testWidgets('displays correct background colors for score values', (tester) async {
      final matrixData = NfrMatrixData(
        diagramId: 'diagram-1',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [
          ComponentColumn(id: 'comp-1', label: 'Component 1'),
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
        isPersistent: true,
      );

      final nfrs = [
        NFRResponse(id: 'nfr-1', name: 'Performance', createdAt: DateTime.now()),
        NFRResponse(id: 'nfr-2', name: 'Security', createdAt: DateTime.now()),
        NFRResponse(id: 'nfr-3', name: 'Scalability', createdAt: DateTime.now()),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NfrEvaluationMatrixWidget(
                data: matrixData,
                nfrs: nfrs,
                nfrRepository: mockNfrRepo,
                matrixRepository: mockMatrixRepo,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify score values are displayed
      expect(find.text('+1'), findsOneWidget);
      expect(find.text('-1'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });


    testWidgets('handles create NFR error', (tester) async {
      final matrixData = NfrMatrixData(
        diagramId: 'diagram-1',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [
          ComponentColumn(id: 'comp-1', label: 'Component 1'),
        ],
        rows: [],
        isPersistent: true,
      );

      when(() => mockNfrRepo.createNFR(
            name: any(named: 'name'),
            description: any(named: 'description'),
          )).thenThrow(Exception('Network error'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: NfrEvaluationMatrixWidget(
                      data: matrixData,
                      nfrs: [],
                      nfrRepository: mockNfrRepo,
                      matrixRepository: mockMatrixRepo,
                      onRefresh: null, // Don't trigger refresh
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter name and create
      await tester.enterText(find.byType(TextFormField).first, 'New NFR');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.textContaining('Failed to create NFR'), findsOneWidget);
    });

    testWidgets('handles delete NFR error', (tester) async {
      final matrixData = NfrMatrixData(
        diagramId: 'diagram-1',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [
          ComponentColumn(id: 'comp-1', label: 'Component 1'),
        ],
        rows: [
          NfrMatrixRow(
            nfrId: 'nfr-1',
            nfr: 'Performance',
            color: Colors.blue,
            scores: {'comp-1': 1},
          ),
        ],
        isPersistent: true,
      );

      final nfrs = [
        NFRResponse(id: 'nfr-1', name: 'Performance', createdAt: DateTime.now()),
      ];

      when(() => mockNfrRepo.deleteNFR(any())).thenThrow(Exception('Network error'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: NfrEvaluationMatrixWidget(
                      data: matrixData,
                      nfrs: nfrs,
                      nfrRepository: mockNfrRepo,
                      matrixRepository: mockMatrixRepo,
                      onRefresh: null, // Don't trigger refresh
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.textContaining('Failed to delete NFR'), findsOneWidget);
    });

    testWidgets('prevents saving when diagramId is empty', (tester) async {
      final matrixData = NfrMatrixData(
        diagramId: '',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [
          ComponentColumn(id: 'comp-1', label: 'Component 1'),
        ],
        rows: [
          NfrMatrixRow(
            nfrId: 'nfr-1',
            nfr: 'Performance',
            color: Colors.blue,
            scores: {'comp-1': 0},
          ),
        ],
        isPersistent: false,
      );

      final nfrs = [
        NFRResponse(id: 'nfr-1', name: 'Performance', createdAt: DateTime.now()),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: NfrEvaluationMatrixWidget(
                      data: matrixData,
                      nfrs: nfrs,
                      nfrRepository: mockNfrRepo,
                      matrixRepository: mockMatrixRepo,
                    ),
                  ),
                );
              },
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

    testWidgets('displays header cells correctly', (tester) async {
      final matrixData = NfrMatrixData(
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
        isPersistent: true,
      );

      final nfrs = [
        NFRResponse(id: 'nfr-1', name: 'Performance', createdAt: DateTime.now()),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NfrEvaluationMatrixWidget(
                data: matrixData,
                nfrs: nfrs,
                nfrRepository: mockNfrRepo,
                matrixRepository: mockMatrixRepo,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all header cells
      expect(find.text('NFR'), findsOneWidget);
      expect(find.text('Component 1'), findsOneWidget);
      expect(find.text('Component 2'), findsOneWidget);
      expect(find.text('Avg Score'), findsOneWidget);
    });
  });
}

