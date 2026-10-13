import 'package:flutter/material.dart';

import '../../shared/design/app_colors.dart';
import '../../shared/design/app_dimens.dart';
import '../../shared/design/app_theme_extension.dart';
import '../../shared/design/app_typography.dart';

/// Builds the light and dark [ThemeData] for Flow from the design tokens.
///
/// This is the single source of truth for the app look and feel. Widgets must
/// read styling from [Theme] instead of hard-coding values.
abstract final class AppTheme {
  const AppTheme._();

  /// Light theme.
  static ThemeData light() => _build(AppColors.light, AppColorsExtension.light);

  /// Dark theme.
  static ThemeData dark() => _build(AppColors.dark, AppColorsExtension.dark);

  static ThemeData _build(ColorScheme scheme, AppColorsExtension ext) {
    final TextTheme textTheme = AppTypography.textTheme(scheme);
    final bool isDark = scheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      extensions: <ThemeExtension<dynamic>>[ext],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: isDark ? 0 : 1,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
      dividerTheme: DividerThemeData(color: ext.border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: ext.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: ext.disabled),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.minTouchTarget),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.minTouchTarget),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          side: BorderSide(color: scheme.outline),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.minTouchTarget),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: textTheme.labelLarge,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
    );
  }
}
