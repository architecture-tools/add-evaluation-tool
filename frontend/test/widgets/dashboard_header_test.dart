import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/widgets/dashboard_header.dart';

void main() {
  group('DashboardHeader Widget Tests', () {
    testWidgets('displays project name and version', (tester) async {
      // Set larger screen size to avoid overflow
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardHeader(
              projectName: 'Test Project',
              version: '1.0.0',
              onUpload: (context) async {},
            ),
          ),
        ),
      );

      expect(find.text('Architecture Dashboard'), findsOneWidget);
      expect(find.text('Test Project - Version 1.0.0'), findsOneWidget);
      
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('displays upload button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardHeader(
              projectName: 'Test Project',
              version: '1.0.0',
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
              projectName: 'Test Project',
              version: '1.0.0',
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

    testWidgets('displays search field', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardHeader(
              projectName: 'Test Project',
              version: '1.0.0',
              onUpload: (context) async {},
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search...'), findsOneWidget);
      
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('displays notifications icon', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardHeader(
              projectName: 'Test Project',
              version: '1.0.0',
              onUpload: (context) async {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('displays architecture icon', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardHeader(
              projectName: 'Test Project',
              version: '1.0.0',
              onUpload: (context) async {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.architecture), findsOneWidget);
      
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });
  });
}

