import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/widgets/version_timeline_widget.dart';
import 'package:architecture_evaluation_tool/models/mock_models.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('VersionTimelineWidget Extended Tests', () {
    testWidgets('displays multiple timeline items', (tester) async {
      final timeline = [
        VersionInfo(
          version: '1.0',
          timeAgo: '3h ago',
          description: 'Initial version',
          changes: '5 changes',
          score: 0.7,
          trend: VersionTrend.up,
        ),
        VersionInfo(
          version: '2.0',
          timeAgo: '2h ago',
          description: 'Added components',
          changes: '3 changes',
          score: 0.8,
          trend: VersionTrend.up,
        ),
        VersionInfo(
          version: '3.0',
          timeAgo: '1h ago',
          description: 'Updated relationships',
          changes: '2 changes',
          score: 0.9,
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

      expect(find.text('1.0'), findsOneWidget);
      expect(find.text('2.0'), findsOneWidget);
      expect(find.text('3.0'), findsOneWidget);
      expect(find.text('Initial version'), findsOneWidget);
      expect(find.text('Added components'), findsOneWidget);
    });

    testWidgets('displays version descriptions', (tester) async {
      final timeline = [
        VersionInfo(
          version: '1.0',
          timeAgo: '1h ago',
          description: 'Test description',
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

      expect(find.text('Test description'), findsOneWidget);
    });

    testWidgets('displays version scores', (tester) async {
      final timeline = [
        VersionInfo(
          version: '1.0',
          timeAgo: '1h ago',
          description: 'Version',
          changes: '1 change',
          score: 0.85,
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

    testWidgets('displays changes count', (tester) async {
      final timeline = [
        VersionInfo(
          version: '1.0',
          timeAgo: '1h ago',
          description: 'Version',
          changes: '5 changes',
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

      expect(find.textContaining('5 changes'), findsOneWidget);
    });

    testWidgets('displays time ago', (tester) async {
      final timeline = [
        VersionInfo(
          version: '1.0',
          timeAgo: '2h ago',
          description: 'Version',
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

      expect(find.textContaining('2h ago'), findsOneWidget);
    });
  });
}

