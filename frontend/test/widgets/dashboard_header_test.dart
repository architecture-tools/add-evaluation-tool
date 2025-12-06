import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/widgets/dashboard_header.dart';

void main() {
  group('DashboardHeader Widget Tests', () {
    testWidgets('displays title and logo', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardHeader(
              onUpload: (context) async {},
            ),
          ),
        ),
      );

      expect(find.text('Architecture Dashboard'), findsOneWidget);
      expect(find.text('Architecture Evaluator'), findsOneWidget);
      expect(find.byIcon(Icons.architecture), findsOneWidget);

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('displays upload button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardHeader(
              onUpload: (context) async {},
            ),
          ),
        ),
      );

      expect(find.text('Upload New'), findsOneWidget);
      expect(find.byIcon(Icons.upload), findsOneWidget);

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('calls onUpload when upload button is tapped', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));

      bool uploadCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardHeader(
              onUpload: (context) async {
                uploadCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Upload New'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(uploadCalled, isTrue);

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('displays health status indicator', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardHeader(
              onUpload: (context) async {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Health status should be displayed (Online or Offline)
      final onlineFinder = find.textContaining('Online');
      final offlineFinder = find.textContaining('Offline');
      final hasOnline = tester.widgetList(onlineFinder).isNotEmpty;
      final hasOffline = tester.widgetList(offlineFinder).isNotEmpty;
      expect(hasOnline || hasOffline, isTrue);

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });
  });
}
