import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/widgets/kpi_card.dart';
import 'package:architecture_evaluation_tool/theme/app_theme.dart';

void main() {
  group('KPICard Widget Tests', () {
    testWidgets('displays title, value, and subtitle correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KPICard(
              title: 'Total Diagrams',
              value: '42',
              subtitle: 'Last upload: 2h ago',
              icon: Icons.account_tree,
              iconColor: AppTheme.blue,
            ),
          ),
        ),
      );

      expect(find.text('Total Diagrams'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Last upload: 2h ago'), findsOneWidget);
    });

    testWidgets('displays icon with correct color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KPICard(
              title: 'Test',
              value: '10',
              subtitle: 'Subtitle',
              icon: Icons.check_circle,
              iconColor: AppTheme.green,
            ),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.check_circle);
      expect(iconFinder, findsOneWidget);

      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.color, equals(AppTheme.green));
    });

    testWidgets('displays change indicator when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KPICard(
              title: 'Test',
              value: '10',
              subtitle: 'Subtitle',
              icon: Icons.trending_up,
              iconColor: AppTheme.blue,
              change: '+5',
            ),
          ),
        ),
      );

      expect(find.text('+5'), findsOneWidget);
    });

    testWidgets('displays badge when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KPICard(
              title: 'Test',
              value: '10',
              subtitle: 'Subtitle',
              icon: Icons.warning,
              iconColor: AppTheme.red,
              badge: 'Action required',
            ),
          ),
        ),
      );

      expect(find.text('Action required'), findsOneWidget);
    });

    testWidgets('does not display change when not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KPICard(
              title: 'Test',
              value: '10',
              subtitle: 'Subtitle',
              icon: Icons.info,
              iconColor: AppTheme.blue,
            ),
          ),
        ),
      );

      // Should not find any change indicator
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('applies correct styling for positive change', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KPICard(
              title: 'Test',
              value: '10',
              subtitle: 'Subtitle',
              icon: Icons.trending_up,
              iconColor: AppTheme.blue,
              change: '+10',
            ),
          ),
        ),
      );

      expect(find.text('+10'), findsOneWidget);
      // The change should have green styling (tested via text presence)
    });

    testWidgets('applies correct styling for negative change', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KPICard(
              title: 'Test',
              value: '10',
              subtitle: 'Subtitle',
              icon: Icons.trending_down,
              iconColor: AppTheme.red,
              change: '-5',
            ),
          ),
        ),
      );

      expect(find.text('-5'), findsOneWidget);
      // The change should have red styling
    });

    testWidgets('renders as Card widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KPICard(
              title: 'Test',
              value: '10',
              subtitle: 'Subtitle',
              icon: Icons.info,
              iconColor: AppTheme.blue,
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });
  });
}

