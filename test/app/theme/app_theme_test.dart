import 'package:flow/app/theme/app_theme.dart';
import 'package:flow/shared/design/app_dimens.dart';
import 'package:flow/shared/design/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    test('light theme uses Material 3 and registers semantics', () {
      final ThemeData theme = AppTheme.light();
      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, isTrue);
      expect(theme.extension<AppColorsExtension>(), isNotNull);
    });

    test('dark theme flips brightness', () {
      final ThemeData theme = AppTheme.dark();
      expect(theme.brightness, Brightness.dark);
      expect(theme.extension<AppColorsExtension>(), isNotNull);
    });

    test('light and dark surface colors differ', () {
      expect(
        AppTheme.light().colorScheme.surface,
        isNot(AppTheme.dark().colorScheme.surface),
      );
    });

    test('light and dark themes do not share primary contrast', () {
      expect(
        AppTheme.light().colorScheme.onPrimary,
        isNot(AppTheme.dark().colorScheme.onPrimary),
      );
    });

    test('typography is tinted for the active scheme', () {
      final ThemeData light = AppTheme.light();
      final ThemeData dark = AppTheme.dark();
      expect(light.textTheme.bodyLarge?.color, light.colorScheme.onSurface);
      expect(dark.textTheme.bodyLarge?.color, dark.colorScheme.onSurface);
    });
  });

  group('window size breakpoints', () {
    test('classifies logical widths', () {
      expect(windowSizeFor(0), WindowSize.compact);
      expect(windowSizeFor(599.9), WindowSize.compact);
      expect(windowSizeFor(600), WindowSize.medium);
      expect(windowSizeFor(1199.9), WindowSize.medium);
      expect(windowSizeFor(1200), WindowSize.expanded);
    });
  });
}
