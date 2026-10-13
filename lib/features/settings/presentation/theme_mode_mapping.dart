import 'package:flow/features/settings/domain/app_preferences.dart';
import 'package:flutter/material.dart';

/// Bridges Flutter's [ThemeMode] and the persisted [AppThemePreference].
///
/// The mapping lives at the presentation edge so the domain stays pure Dart
/// (no Flutter import) while the value can still round-trip through the
/// database unchanged.
extension ThemeModeMapping on ThemeMode {
  /// The persisted form of this theme mode.
  AppThemePreference get preference => switch (this) {
    ThemeMode.system => AppThemePreference.system,
    ThemeMode.light => AppThemePreference.light,
    ThemeMode.dark => AppThemePreference.dark,
  };
}

/// The Flutter theme mode selected by a persisted preference.
extension AppThemePreferenceMapping on AppThemePreference {
  /// The [ThemeMode] this preference selects.
  ThemeMode get themeMode => switch (this) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };
}
