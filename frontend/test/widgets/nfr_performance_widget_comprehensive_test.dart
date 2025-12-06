import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/widgets/nfr_performance_widget.dart';
import 'package:architecture_evaluation_tool/models/mock_models.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';
import 'package:architecture_evaluation_tool/services/nfr_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockNFRRepository extends Mock implements NFRRepository {}

void main() {
  group('NFRPerformanceWidget Comprehensive Tests', () {
    late MockNFRRepository mockNfrRepo;

    setUp(() {
      mockNfrRepo = MockNFRRepository();
    });

    testWidgets('displays create NFR dialog when add button is tapped', (tester) async {
      when(() => mockNfrRepo.createNFR(name: any(named: 'name'), description: any(named: 'description')))
          .thenAnswer((_) async => NFRResponse(
                id: 'nfr-1',
                name: 'Test NFR',
                createdAt: DateTime.now(),
              ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: [],
              nfrRepository: mockNfrRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Create Non-Functional Requirement'), findsOneWidget);
      expect(find.text('Name *'), findsOneWidget);
    });

    testWidgets('validates NFR name in create dialog', (tester) async {
      when(() => mockNfrRepo.createNFR(name: any(named: 'name'), description: any(named: 'description')))
          .thenAnswer((_) async => NFRResponse(
                id: 'nfr-1',
                name: 'Test NFR',
                createdAt: DateTime.now(),
              ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: [],
              nfrRepository: mockNfrRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Try to submit without name
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('validates NFR name length in create dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: [],
              nfrRepository: mockNfrRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter name longer than 255 characters
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'A' * 256);
      await tester.pumpAndSettle();

      // Try to submit
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Name must be 255 characters or less'), findsOneWidget);
    });

    testWidgets('displays delete NFR dialog when delete button is tapped', (tester) async {
      when(() => mockNfrRepo.deleteNFR(any())).thenAnswer((_) async => {});

      final metrics = [
        NFRMetric('Performance', 0.8, Colors.blue),
      ];

      final nfrs = [
        NFRResponse(
          id: 'nfr-1',
          name: 'Performance',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: metrics,
              nfrs: nfrs,
              nfrRepository: mockNfrRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap delete button
      final deleteButtons = find.byIcon(Icons.delete_outline);
      expect(deleteButtons, findsOneWidget);
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Delete NFR'), findsOneWidget);
      expect(find.textContaining('Are you sure you want to delete'), findsOneWidget);
    });

    testWidgets('cancels delete NFR dialog', (tester) async {
      final metrics = [
        NFRMetric('Performance', 0.8, Colors.blue),
      ];

      final nfrs = [
        NFRResponse(
          id: 'nfr-1',
          name: 'Performance',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: metrics,
              nfrs: nfrs,
              nfrRepository: mockNfrRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open delete dialog
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Delete NFR'), findsNothing);
    });

    testWidgets('displays metrics with correct scores', (tester) async {
      final metrics = [
        NFRMetric('Performance', 0.7, Colors.blue),
        NFRMetric('Security', 0.8, Colors.red),
        NFRMetric('Scalability', 0.4, Colors.green),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: metrics,
              nfrRepository: mockNfrRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Performance'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Scalability'), findsOneWidget);
      expect(find.text('0.7'), findsOneWidget);
      expect(find.text('0.8'), findsOneWidget);
      expect(find.text('0.4'), findsOneWidget);
    });

    testWidgets('handles metrics without matching NFRResponse', (tester) async {
      final metrics = [
        NFRMetric('Unknown NFR', 5.0, Colors.blue),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: metrics,
              nfrs: [],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display the metric
      expect(find.text('Unknown NFR'), findsOneWidget);
      // Should not show delete button
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('cancels create NFR dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: [],
              nfrRepository: mockNfrRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Create Non-Functional Requirement'), findsNothing);
    });

    testWidgets('displays description field in create dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: [],
              nfrRepository: mockNfrRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Description field should be present
      expect(find.text('Description (optional)'), findsOneWidget);
    });

    testWidgets('successfully deletes NFR', (tester) async {
      when(() => mockNfrRepo.deleteNFR(any())).thenAnswer((_) async => {});

      final metrics = [
        NFRMetric('Performance', 0.8, Colors.blue),
      ];

      final nfrs = [
        NFRResponse(
          id: 'nfr-1',
          name: 'Performance',
          createdAt: DateTime.now(),
        ),
      ];

      bool refreshCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: metrics,
              nfrs: nfrs,
              nfrRepository: mockNfrRepo,
              onRefresh: () {
                refreshCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open delete dialog
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.textContaining('deleted successfully'), findsOneWidget);
      expect(refreshCalled, isTrue);
    });

    testWidgets('handles delete NFR error', (tester) async {
      when(() => mockNfrRepo.deleteNFR(any())).thenThrow(Exception('Network error'));

      final metrics = [
        NFRMetric('Performance', 0.8, Colors.blue),
      ];

      final nfrs = [
        NFRResponse(
          id: 'nfr-1',
          name: 'Performance',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: metrics,
              nfrs: nfrs,
              nfrRepository: mockNfrRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open delete dialog
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.textContaining('Failed to delete NFR'), findsOneWidget);
    });

    testWidgets('successfully creates NFR', (tester) async {
      when(() => mockNfrRepo.createNFR(name: any(named: 'name'), description: any(named: 'description')))
          .thenAnswer((_) async => NFRResponse(
                id: 'nfr-1',
                name: 'New NFR',
                createdAt: DateTime.now(),
              ));

      bool refreshCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: [],
              nfrRepository: mockNfrRepo,
              onRefresh: () {
                refreshCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(find.byType(TextFormField).first, 'New NFR');
      await tester.pumpAndSettle();

      // Create
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.textContaining('created successfully'), findsOneWidget);
      expect(refreshCalled, isTrue);
    });

    testWidgets('handles create NFR error', (tester) async {
      when(() => mockNfrRepo.createNFR(name: any(named: 'name'), description: any(named: 'description')))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: [],
              nfrRepository: mockNfrRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(find.byType(TextFormField).first, 'New NFR');
      await tester.pumpAndSettle();

      // Create
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.textContaining('Failed to create NFR'), findsOneWidget);
    });

    testWidgets('creates NFR with description', (tester) async {
      when(() => mockNfrRepo.createNFR(name: any(named: 'name'), description: any(named: 'description')))
          .thenAnswer((_) async => NFRResponse(
                id: 'nfr-1',
                name: 'New NFR',
                createdAt: DateTime.now(),
              ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NFRPerformanceWidget(
              metrics: [],
              nfrRepository: mockNfrRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter name and description
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'New NFR');
      await tester.pumpAndSettle();
      await tester.enterText(fields.at(1), 'Test description');
      await tester.pumpAndSettle();

      // Create
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify description was passed
      verify(() => mockNfrRepo.createNFR(
            name: 'New NFR',
            description: 'Test description',
          )).called(1);
    });
  });
}

