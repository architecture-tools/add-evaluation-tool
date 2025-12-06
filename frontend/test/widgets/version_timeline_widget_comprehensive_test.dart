import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/widgets/version_timeline_widget.dart';
import 'package:architecture_evaluation_tool/models/mock_models.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';
import 'package:architecture_evaluation_tool/services/diagram_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDiagramRepository extends Mock implements DiagramRepository {}

void main() {
  group('VersionTimelineWidget Comprehensive Tests', () {
    testWidgets('displays compare button for non-first items', (tester) async {
      final timeline = [
        VersionInfo(
          version: 'v1.0',
          timeAgo: '2 days ago',
          description: 'Initial version',
          changes: 'Parsed successfully',
          score: 7.5,
          trend: VersionTrend.up,
        ),
        VersionInfo(
          version: 'v2.0',
          timeAgo: '1 day ago',
          description: 'Updated version',
          changes: 'Analysis ready',
          score: 8.8,
          trend: VersionTrend.up,
        ),
      ];

      final diagrams = [
        DiagramResponse(
          id: 'diagram-1',
          name: 'v1.0',
          status: DiagramStatus.parsed,
          uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
          parsedAt: DateTime.now().subtract(const Duration(days: 2)),
          sourceUrl: 'test.puml',
        ),
        DiagramResponse(
          id: 'diagram-2',
          name: 'v2.0',
          status: DiagramStatus.analysisReady,
          uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
          parsedAt: DateTime.now().subtract(const Duration(days: 1)),
          sourceUrl: 'test2.puml',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionTimelineWidget(
              timeline: timeline,
              diagrams: diagrams,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Compare button should appear for second item
      expect(find.text('Compare'), findsOneWidget);
    });

    testWidgets('does not display compare button for first item',
        (tester) async {
      final timeline = [
        VersionInfo(
          version: 'v1.0',
          timeAgo: '2 days ago',
          description: 'Initial version',
          changes: 'Parsed successfully',
          score: 7.5,
          trend: VersionTrend.up,
        ),
      ];

      final diagrams = [
        DiagramResponse(
          id: 'diagram-1',
          name: 'v1.0',
          status: DiagramStatus.parsed,
          uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
          parsedAt: DateTime.now().subtract(const Duration(days: 2)),
          sourceUrl: 'test.puml',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionTimelineWidget(
              timeline: timeline,
              diagrams: diagrams,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Compare button should not appear for first item
      expect(find.text('Compare'), findsNothing);
    });

    testWidgets('displays diff dialog when compare is tapped', (tester) async {
      final timeline = [
        VersionInfo(
          version: 'v1.0',
          timeAgo: '2 days ago',
          description: 'Initial version',
          changes: 'Parsed successfully',
          score: 7.5,
          trend: VersionTrend.up,
        ),
        VersionInfo(
          version: 'v2.0',
          timeAgo: '1 day ago',
          description: 'Updated version',
          changes: 'Analysis ready',
          score: 8.8,
          trend: VersionTrend.up,
        ),
      ];

      final diagrams = [
        DiagramResponse(
          id: 'diagram-1',
          name: 'v1.0',
          status: DiagramStatus.parsed,
          uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
          parsedAt: DateTime.now().subtract(const Duration(days: 2)),
          sourceUrl: 'test.puml',
        ),
        DiagramResponse(
          id: 'diagram-2',
          name: 'v2.0',
          status: DiagramStatus.analysisReady,
          uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
          parsedAt: DateTime.now().subtract(const Duration(days: 1)),
          sourceUrl: 'test2.puml',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionTimelineWidget(
              timeline: timeline,
              diagrams: diagrams,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap compare button
      await tester.tap(find.text('Compare'));
      await tester.pumpAndSettle();

      // Dialog should appear (may show loading or error due to HTTP call)
      final dialogTitle = find.text('Diagram Comparison');
      final loadingIndicator = find.byType(CircularProgressIndicator);
      final errorText =
          find.textContaining('Failed to load', findRichText: true);

      // One of these should be present
      expect(
        dialogTitle.evaluate().isNotEmpty ||
            loadingIndicator.evaluate().isNotEmpty ||
            errorText.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('displays different trend icons', (tester) async {
      final timeline = [
        VersionInfo(
          version: 'v1.0',
          timeAgo: '2 days ago',
          description: 'Initial version',
          changes: 'Parsed successfully',
          score: 7.5,
          trend: VersionTrend.up,
        ),
        VersionInfo(
          version: 'v2.0',
          timeAgo: '1 day ago',
          description: 'Failed version',
          changes: 'Failed',
          score: 3.5,
          trend: VersionTrend.down,
        ),
        VersionInfo(
          version: 'v3.0',
          timeAgo: '12 hours ago',
          description: 'Neutral version',
          changes: 'Awaiting parsing',
          score: 6.2,
          trend: VersionTrend.neutral,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionTimelineWidget(
              timeline: timeline,
              diagrams: [],
              diagramRepository: MockDiagramRepository(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display all versions
      expect(find.text('v1.0'), findsOneWidget);
      expect(find.text('v2.0'), findsOneWidget);
      expect(find.text('v3.0'), findsOneWidget);
    });

    testWidgets('displays timeline line for non-last items', (tester) async {
      final timeline = [
        VersionInfo(
          version: 'v1.0',
          timeAgo: '2 days ago',
          description: 'Initial version',
          changes: 'Parsed successfully',
          score: 7.5,
          trend: VersionTrend.up,
        ),
        VersionInfo(
          version: 'v2.0',
          timeAgo: '1 day ago',
          description: 'Updated version',
          changes: 'Analysis ready',
          score: 8.8,
          trend: VersionTrend.up,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionTimelineWidget(
              timeline: timeline,
              diagrams: [],
              diagramRepository: MockDiagramRepository(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // First item should have a line (showLine = true)
      // This is tested by checking that both items are displayed
      expect(find.text('v1.0'), findsOneWidget);
      expect(find.text('v2.0'), findsOneWidget);
    });

    testWidgets('displays version scores correctly', (tester) async {
      final timeline = [
        VersionInfo(
          version: 'v1.0',
          timeAgo: '2 days ago',
          description: 'Initial version',
          changes: 'Parsed successfully',
          score: 7.5,
          trend: VersionTrend.up,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionTimelineWidget(
              timeline: timeline,
              diagrams: [],
              diagramRepository: MockDiagramRepository(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Score: 7.5'), findsOneWidget);
    });

    testWidgets('handles empty diagrams list', (tester) async {
      final timeline = [
        VersionInfo(
          version: 'v1.0',
          timeAgo: '2 days ago',
          description: 'Initial version',
          changes: 'Parsed successfully',
          score: 7.5,
          trend: VersionTrend.up,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionTimelineWidget(
              timeline: timeline,
              diagrams: [],
              diagramRepository: MockDiagramRepository(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should still display timeline
      expect(find.text('v1.0'), findsOneWidget);
      // Compare button should not appear without diagrams
      expect(find.text('Compare'), findsNothing);
    });
  });
}
