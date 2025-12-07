import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/widgets/version_timeline_widget.dart';
import 'package:architecture_evaluation_tool/models/mock_models.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('VersionTimelineWidget Compare Tests', () {
    testWidgets('displays compare button when canCompare is true',
        (tester) async {
      final timeline = [
        VersionInfo(
          version: '1.0',
          timeAgo: '2h ago',
          description: 'Initial',
          changes: '1 change',
          score: 0.5,
        ),
        VersionInfo(
          version: '2.0',
          timeAgo: '1h ago',
          description: 'Updated',
          changes: '2 changes',
          score: 0.6,
        ),
      ];

      final diagrams = [
        TestHelpers.createMockDiagram(id: 'diagram-1', name: 'Diagram 1'),
        TestHelpers.createMockDiagram(id: 'diagram-2', name: 'Diagram 2'),
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

      // Second item should have compare button (index > 0)
      expect(find.byIcon(Icons.compare_arrows), findsWidgets);
    });

    testWidgets('does not display compare button for first item',
        (tester) async {
      final timeline = [
        VersionInfo(
          version: '1.0',
          timeAgo: '1h ago',
          description: 'First',
          changes: '1 change',
          score: 0.5,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionTimelineWidget(
              timeline: timeline,
            ),
          ),
        ),
      );

      // First item should not have compare button
      expect(find.byIcon(Icons.compare_arrows), findsNothing);
    });

    testWidgets('displays version score with trend', (tester) async {
      final timeline = [
        VersionInfo(
          version: '1.0',
          timeAgo: '1h ago',
          description: 'Version',
          changes: '1 change',
          score: 0.85,
          trend: VersionTrend.up,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionTimelineWidget(
              timeline: timeline,
            ),
          ),
        ),
      );

      expect(find.textContaining('0.85'), findsOneWidget);
    });

    testWidgets('displays version with down trend', (tester) async {
      final timeline = [
        VersionInfo(
          version: '1.0',
          timeAgo: '1h ago',
          description: 'Version',
          changes: '1 change',
          score: 0.5,
          trend: VersionTrend.down,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionTimelineWidget(
              timeline: timeline,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('displays version with up trend', (tester) async {
      final timeline = [
        VersionInfo(
          version: '1.0',
          timeAgo: '1h ago',
          description: 'Version',
          changes: '1 change',
          score: 0.5,
          trend: VersionTrend.up,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionTimelineWidget(
              timeline: timeline,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('displays version with neutral trend', (tester) async {
      final timeline = [
        VersionInfo(
          version: '1.0',
          timeAgo: '1h ago',
          description: 'Version',
          changes: '1 change',
          score: 0.5,
          trend: VersionTrend.neutral,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionTimelineWidget(
              timeline: timeline,
            ),
          ),
        ),
      );

      // Should still display, just without specific trend icon
      expect(find.text('1.0'), findsOneWidget);
    });
  });
}
