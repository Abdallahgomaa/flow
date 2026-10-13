import 'package:flutter/material.dart';

/// Flow brand palette and the two [ColorScheme]s used by the application.
///
/// Widgets must resolve colors through [Theme] (or [AppColorsExtension]) and
/// never hard-code a [Color]. This keeps light/dark theming centralized.
abstract final class AppColors {
  const AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color tertiary = Color(0xFF7C3AED);

  // ── Semantic feedback ────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF0284C7);

  // ── Neutrals ─────────────────────────────────────────────────────────────
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);
  static const Color neutral950 = Color(0xFF020617);

  /// Light [ColorScheme].
  static final ColorScheme light =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: primary,
        onPrimary: neutral0,
        secondary: secondary,
        onSecondary: neutral0,
        tertiary: tertiary,
        onTertiary: neutral0,
        error: danger,
        onError: neutral0,
        surface: neutral0,
        onSurface: neutral900,
        surfaceContainerLowest: neutral0,
        surfaceContainerLow: neutral50,
        surfaceContainer: neutral100,
        surfaceContainerHigh: neutral200,
        outline: neutral400,
        outlineVariant: neutral200,
      );

  /// Dark [ColorScheme].
  static final ColorScheme dark =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: const Color(0xFF93B4FF),
        onPrimary: const Color(0xFF0A1F44),
        secondary: const Color(0xFF7DD3FC),
        onSecondary: const Color(0xFF082F49),
        tertiary: const Color(0xFFC4B5FD),
        onTertiary: const Color(0xFF2E1065),
        surface: neutral950,
        onSurface: const Color(0xFFE2E8F0),
        surfaceContainerLowest: neutral950,
        surfaceContainerLow: neutral900,
        surfaceContainer: neutral800,
        surfaceContainerHigh: const Color(0xFF334155),
        outline: neutral600,
        outlineVariant: neutral800,
      );

  /// Returns the [ColorScheme] matching [brightness].
  static ColorScheme of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
