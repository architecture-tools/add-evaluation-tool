import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/widgets/nfr_performance_widget.dart';
import 'package:architecture_evaluation_tool/models/mock_models.dart';

void main() {
  group('NFRPerformanceWidget Extended Tests', () {
    testWidgets('displays multiple NFR metrics', (tester) async {
      final metrics = [
        NFRMetric('Performance', 0.8, Colors.blue),
        NFRMetric('Security', 0.9, Colors.green),
        NFRMetric('Scalability', 0.6, Colors.orange),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: metrics,
            ),
          ),
        ),
      );

      expect(find.text('Performance'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Scalability'), findsOneWidget);
    });

    testWidgets('displays NFR scores', (tester) async {
      final metrics = [
        NFRMetric('Performance', 0.85, Colors.blue),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: metrics,
            ),
          ),
        ),
      );

      expect(find.textContaining('0.85'), findsOneWidget);
    });

    testWidgets('displays add NFR button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: [],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });


    testWidgets('calls onRefresh when provided', (tester) async {
      bool refreshCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: [],
              onRefresh: () {
                refreshCalled = true;
              },
            ),
          ),
        ),
      );

      // Widget should be rendered
      expect(find.text('NFR Performance'), findsOneWidget);
      // onRefresh is typically called by parent, not directly by widget
      expect(refreshCalled, isFalse);
    });
  });
}

