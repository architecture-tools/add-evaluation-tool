import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/widgets/nfr_performance_widget.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';
import 'package:architecture_evaluation_tool/models/mock_models.dart';

void main() {
  group('NFRPerformanceWidget Tests', () {
    testWidgets('displays empty state when no metrics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: [],
            ),
          ),
        ),
      );

      expect(find.text('No NFR metrics available yet.'), findsOneWidget);
    });

    testWidgets('displays NFR metrics', (tester) async {
      final metrics = [
        NFRMetric(
          'Performance',
          0.8,
          Colors.blue,
        ),
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

      expect(find.text('NFR Performance'), findsOneWidget);
      expect(find.text('Performance'), findsOneWidget);
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
  });
}
