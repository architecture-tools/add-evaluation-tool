import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/widgets/diagram_diff_widget.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';

void main() {
  group('DiagramDiffWidget Extended Tests', () {
    testWidgets('displays component with added change type', (tester) async {
      final diff = DiagramDiffResponse(
        baseDiagramId: 'base-1',
        targetDiagramId: 'target-1',
        components: [
          ComponentDiffResponse(
            name: 'New Component',
            changeType: ComponentDiffResponseChangeTypeEnum.added,
            newType: ComponentType.component,
          ),
        ],
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

      expect(find.text('New Component'), findsOneWidget);
      expect(find.text('Added'), findsOneWidget);
    });

    testWidgets('displays component with removed change type', (tester) async {
      final diff = DiagramDiffResponse(
        baseDiagramId: 'base-1',
        targetDiagramId: 'target-1',
        components: [
          ComponentDiffResponse(
            name: 'Old Component',
            changeType: ComponentDiffResponseChangeTypeEnum.removed,
            previousType: ComponentType.component,
          ),
        ],
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

      expect(find.text('Old Component'), findsOneWidget);
      expect(find.text('Removed'), findsOneWidget);
    });

    testWidgets('displays component with modified change type', (tester) async {
      final diff = DiagramDiffResponse(
        baseDiagramId: 'base-1',
        targetDiagramId: 'target-1',
        components: [
          ComponentDiffResponse(
            name: 'Updated Component',
            changeType: ComponentDiffResponseChangeTypeEnum.modified,
            previousType: ComponentType.component,
            newType: ComponentType.database,
          ),
        ],
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

      expect(find.text('Updated Component'), findsOneWidget);
      expect(find.text('Modified'), findsOneWidget);
    });

    testWidgets('displays relationship with added change type', (tester) async {
      final diff = DiagramDiffResponse(
        baseDiagramId: 'base-1',
        targetDiagramId: 'target-1',
        components: [],
        relationships: [
          RelationshipDiffResponse(
            source_: 'A',
            target: 'B',
            changeType: RelationshipDiffResponseChangeTypeEnum.added,
            newLabel: 'calls',
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

      expect(find.textContaining('A'), findsWidgets);
      expect(find.textContaining('B'), findsWidgets);
      expect(find.text('Added'), findsOneWidget);
    });

    testWidgets('displays relationship with removed change type', (tester) async {
      final diff = DiagramDiffResponse(
        baseDiagramId: 'base-1',
        targetDiagramId: 'target-1',
        components: [],
        relationships: [
          RelationshipDiffResponse(
            source_: 'X',
            target: 'Y',
            changeType: RelationshipDiffResponseChangeTypeEnum.removed,
            previousLabel: 'uses',
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

      expect(find.textContaining('X'), findsWidgets);
      expect(find.textContaining('Y'), findsWidgets);
      expect(find.text('Removed'), findsOneWidget);
    });

    testWidgets('displays relationship with modified change type', (tester) async {
      final diff = DiagramDiffResponse(
        baseDiagramId: 'base-1',
        targetDiagramId: 'target-1',
        components: [],
        relationships: [
          RelationshipDiffResponse(
            source_: 'Source',
            target: 'Target',
            changeType: RelationshipDiffResponseChangeTypeEnum.modified,
            previousLabel: 'old',
            newLabel: 'new',
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

      expect(find.textContaining('Source'), findsWidgets);
      expect(find.textContaining('Target'), findsWidgets);
      expect(find.text('Modified'), findsOneWidget);
    });

    testWidgets('displays section titles with counts', (tester) async {
      final diff = DiagramDiffResponse(
        baseDiagramId: 'base-1',
        targetDiagramId: 'target-1',
        components: [
          ComponentDiffResponse(
            name: 'Comp 1',
            changeType: ComponentDiffResponseChangeTypeEnum.added,
          ),
          ComponentDiffResponse(
            name: 'Comp 2',
            changeType: ComponentDiffResponseChangeTypeEnum.removed,
          ),
        ],
        relationships: [
          RelationshipDiffResponse(
            source_: 'A',
            target: 'B',
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

      expect(find.text('Components'), findsOneWidget);
      expect(find.text('Relationships'), findsOneWidget);
      expect(find.text('2'), findsWidgets); // Component count
      expect(find.text('1'), findsWidgets); // Relationship count
    });
  });
}

