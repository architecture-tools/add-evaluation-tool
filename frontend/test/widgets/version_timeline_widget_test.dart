import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/widgets/version_timeline_widget.dart';
import 'package:architecture_evaluation_tool/models/mock_models.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('VersionTimelineWidget Tests', () {
    testWidgets('displays empty state when timeline is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionTimelineWidget(
              timeline: [],
            ),
          ),
        ),
      );

      expect(
        find.text('Timeline will appear after the first diagram is processed.'),
        findsOneWidget,
      );
    });

    testWidgets('displays timeline items', (tester) async {
      final timeline = [
        VersionInfo(
          version: '1.0',
          timeAgo: '2h ago',
          description: 'Initial version',
          changes: '5 changes',
          score: 0.8,
          trend: VersionTrend.up,
        ),
        VersionInfo(
          version: '2.0',
          timeAgo: '1h ago',
          description: 'Updated version',
          changes: '3 changes',
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

      expect(find.text('Version Timeline'), findsOneWidget);
      expect(find.text('1.0'), findsOneWidget);
      expect(find.text('2.0'), findsOneWidget);
    });
  });
}
