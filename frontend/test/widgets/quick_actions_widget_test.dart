import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/widgets/quick_actions_widget.dart';

void main() {
  group('QuickActionsWidget Widget Tests', () {
    testWidgets('displays title and description', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionsWidget(),
          ),
        ),
      );

      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Common tasks'), findsOneWidget);
    });

    testWidgets('displays all action buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionsWidget(),
          ),
        ),
      );

      expect(find.text('Upload Diagram'), findsOneWidget);
      expect(find.text('Evaluate Matrix'), findsOneWidget);
      expect(find.text('Compare Versions'), findsOneWidget);
      expect(find.text('Export Report'), findsOneWidget);
      expect(find.text('AI Insights (Beta)'), findsOneWidget);
    });

    testWidgets('calls onUpload when upload button is tapped', (tester) async {
      bool uploadCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionsWidget(
              onUpload: () {
                uploadCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Upload Diagram'));
      await tester.pumpAndSettle();

      expect(uploadCalled, isTrue);
    });

    testWidgets('calls onEvaluateMatrix when evaluate button is tapped',
        (tester) async {
      bool evaluateCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionsWidget(
              onEvaluateMatrix: () {
                evaluateCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Evaluate Matrix'));
      await tester.pumpAndSettle();

      expect(evaluateCalled, isTrue);
    });

    testWidgets('shows snackbar when callback is not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionsWidget(),
          ),
        ),
      );

      await tester.tap(find.text('Upload Diagram'));
      await tester.pumpAndSettle();

      expect(
        find.text('This action will be available soon.'),
        findsOneWidget,
      );
    });

    testWidgets('displays action descriptions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionsWidget(),
          ),
        ),
      );

      expect(find.text('Add new PlantUML file'), findsOneWidget);
      expect(find.text('Score components'), findsOneWidget);
      expect(find.text('View differences'), findsOneWidget);
      expect(find.text('Generate PDF/Excel'), findsOneWidget);
    });

    testWidgets('displays icons for each action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionsWidget(),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_upload), findsOneWidget);
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
      expect(find.byIcon(Icons.compare_arrows), findsOneWidget);
      expect(find.byIcon(Icons.description), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });
  });
}
