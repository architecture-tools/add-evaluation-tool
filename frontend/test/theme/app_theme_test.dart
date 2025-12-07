import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/theme/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    test('defines all color constants', () {
      expect(AppTheme.primaryPurple, isA<Color>());
      expect(AppTheme.primaryPurpleLight, isA<Color>());
      expect(AppTheme.primaryPurpleDark, isA<Color>());
      expect(AppTheme.blue, isA<Color>());
      expect(AppTheme.yellow, isA<Color>());
      expect(AppTheme.red, isA<Color>());
      expect(AppTheme.green, isA<Color>());
      expect(AppTheme.orange, isA<Color>());
      expect(AppTheme.background, isA<Color>());
      expect(AppTheme.surface, isA<Color>());
      expect(AppTheme.sidebarBackground, isA<Color>());
      expect(AppTheme.borderColor, isA<Color>());
      expect(AppTheme.textPrimary, isA<Color>());
      expect(AppTheme.textSecondary, isA<Color>());
    });

    test('lightTheme returns ThemeData', () {
      final theme = AppTheme.lightTheme;
      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, equals(AppTheme.primaryPurple));
      expect(theme.colorScheme.secondary, equals(AppTheme.blue));
      expect(theme.scaffoldBackgroundColor, equals(AppTheme.background));
    });

    test('lightTheme has correct appBarTheme', () {
      final theme = AppTheme.lightTheme;
      expect(theme.appBarTheme?.backgroundColor, equals(AppTheme.surface));
      expect(theme.appBarTheme?.elevation, equals(0));
    });

    test('lightTheme has correct cardTheme', () {
      final theme = AppTheme.lightTheme;
      expect(theme.cardTheme?.color, equals(AppTheme.surface));
      expect(theme.cardTheme?.elevation, equals(0));
    });

    test('lightTheme has correct textTheme', () {
      final theme = AppTheme.lightTheme;
      expect(theme.textTheme.displayLarge, isNotNull);
      expect(theme.textTheme.displayMedium, isNotNull);
      expect(theme.textTheme.titleLarge, isNotNull);
      expect(theme.textTheme.titleMedium, isNotNull);
      expect(theme.textTheme.bodyLarge, isNotNull);
      expect(theme.textTheme.bodyMedium, isNotNull);
    });

    test('lightTheme has correct elevatedButtonTheme', () {
      final theme = AppTheme.lightTheme;
      expect(theme.elevatedButtonTheme?.style?.backgroundColor?.resolve({}),
          equals(AppTheme.primaryPurple));
    });

    test('lightTheme has correct inputDecorationTheme', () {
      final theme = AppTheme.lightTheme;
      expect(theme.inputDecorationTheme?.filled, isTrue);
      expect(theme.inputDecorationTheme?.fillColor, equals(AppTheme.surface));
    });
  });
}
