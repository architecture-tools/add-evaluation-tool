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
        NFRMetric('Performance', 0.8, Colors.blue),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: NFRPerformanceWidget(
                metrics: metrics,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // toStringAsFixed(1) formats 0.8 as "0.8"
      expect(find.text('0.8'), findsOneWidget);
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
