import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/widgets/diagram_diff_widget.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';

void main() {
  group('DiagramDiffWidget Tests', () {
    testWidgets('displays no differences message when diff is empty',
        (tester) async {
      final diff = DiagramDiffResponse(
        baseDiagramId: 'base-1',
        targetDiagramId: 'target-1',
        components: [],
        relationships: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiagramDiffWidget(
              diff: diff,
              baseDiagramName: 'Base',
              targetDiagramName: 'Target',
            ),
          ),
        ),
      );

      expect(find.text('No differences found between these diagrams.'),
          findsOneWidget);
    });

    testWidgets('displays component differences', (tester) async {
      final diff = DiagramDiffResponse(
        baseDiagramId: 'base-1',
        targetDiagramId: 'target-1',
        components: [
          ComponentDiffResponse(
            name: 'New Component',
            changeType: ComponentDiffResponseChangeTypeEnum.added,
          ),
        ],
        relationships: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiagramDiffWidget(
              diff: diff,
              baseDiagramName: 'Base Diagram',
              targetDiagramName: 'Target Diagram',
            ),
          ),
        ),
      );

      expect(find.text('Components'), findsOneWidget);
      expect(find.text('New Component'), findsOneWidget);
      expect(find.text('Base Diagram'), findsOneWidget);
      expect(find.text('Target Diagram'), findsOneWidget);
    });

    testWidgets('displays relationship differences', (tester) async {
      final diff = DiagramDiffResponse(
        baseDiagramId: 'base-1',
        targetDiagramId: 'target-1',
        components: [],
        relationships: [
          RelationshipDiffResponse(
            source_: 'Component A',
            target: 'Component B',
            changeType: RelationshipDiffResponseChangeTypeEnum.added,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiagramDiffWidget(
              diff: diff,
              baseDiagramName: 'Base',
              targetDiagramName: 'Target',
            ),
          ),
        ),
      );

      expect(find.text('Relationships'), findsOneWidget);
      expect(find.textContaining('Component A'), findsWidgets);
      expect(find.textContaining('Component B'), findsWidgets);
    });

    testWidgets('displays both components and relationships', (tester) async {
      final diff = DiagramDiffResponse(
        baseDiagramId: 'base-1',
        targetDiagramId: 'target-1',
        components: [
          ComponentDiffResponse(
            name: 'Component 1',
            changeType: ComponentDiffResponseChangeTypeEnum.removed,
          ),
        ],
        relationships: [
          RelationshipDiffResponse(
            source_: 'A',
            target: 'B',
            changeType: RelationshipDiffResponseChangeTypeEnum.modified,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiagramDiffWidget(
              diff: diff,
              baseDiagramName: 'Base',
              targetDiagramName: 'Target',
            ),
          ),
        ),
      );

      expect(find.text('Components'), findsOneWidget);
      expect(find.text('Relationships'), findsOneWidget);
      expect(find.text('Component 1'), findsOneWidget);
    });
  });
}
