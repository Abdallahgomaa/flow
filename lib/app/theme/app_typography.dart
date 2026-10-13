import 'package:flutter/material.dart';

/// Typography scale for Flow, derived from the Material 3 type ramp.
///
/// Only weights and letter spacing are customised; colors are applied from the
/// active [ColorScheme] so the same styles work in light and dark mode.
abstract final class AppTypography {
  const AppTypography._();

  /// Builds a full [TextTheme] tinted for [scheme].
  static TextTheme textTheme(ColorScheme scheme) {
    final TextTheme base = ThemeData(colorScheme: scheme).textTheme;

    return base
        .copyWith(
          displaySmall: base.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          headlineLarge: base.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          labelLarge: base.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
  }
}
