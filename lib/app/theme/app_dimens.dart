import 'package:flutter/widgets.dart';

/// Spacing scale (logical pixels) used for padding, gaps and margins.
abstract final class AppSpacing {
  const AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Corner radius scale.
abstract final class AppRadius {
  const AppRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;

  static const BorderRadius card = BorderRadius.all(Radius.circular(md));
  static const BorderRadius input = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius button = BorderRadius.all(Radius.circular(sm));
}

/// Fixed sizes for interactive elements and icons.
///
/// [minTouchTarget] honours NFR-07 (>= 48dp touch targets).
abstract final class AppSizes {
  const AppSizes._();

  static const double minTouchTarget = 48;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;
}

/// Animation durations.
abstract final class AppDurations {
  const AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

/// Layout breakpoints for the adaptive shell (phone / tablet / desktop).
abstract final class AppBreakpoints {
  const AppBreakpoints._();

  static const double compact = 600;
  static const double medium = 900;
  static const double expanded = 1200;
}

/// The three responsive layout classes used across the app.
enum WindowSize { compact, medium, expanded }

/// Resolves the [WindowSize] for a given logical [width].
WindowSize windowSizeFor(double width) {
  if (width < AppBreakpoints.compact) {
    return WindowSize.compact;
  }
  if (width < AppBreakpoints.expanded) {
    return WindowSize.medium;
  }
  return WindowSize.expanded;
}
