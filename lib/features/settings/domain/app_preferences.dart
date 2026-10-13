import 'setting_keys.dart';

/// The user's theme choice, independent of any UI framework.
///
/// Flutter's `ThemeMode` is mapped at the presentation edge so the domain stays
/// pure Dart (usable from plain unit tests).
enum AppThemePreference {
  /// Follow the device setting.
  system('system'),

  /// Always light.
  light('light'),

  /// Always dark.
  dark('dark');

  const AppThemePreference(this.storageValue);

  /// Value written to the settings store.
  final String storageValue;

  /// Reads a stored value, falling back to [system] for anything unknown.
  static AppThemePreference fromStorage(String? value) => switch (value) {
    'light' => AppThemePreference.light,
    'dark' => AppThemePreference.dark,
    _ => AppThemePreference.system,
  };
}

/// Preferences that must survive an application restart.
final class AppPreferences {
  /// Creates preferences.
  const AppPreferences({
    this.theme = AppThemePreference.system,
    this.languageCode,
  });

  /// The state a fresh install starts from.
  static const AppPreferences initial = AppPreferences();

  /// Selected theme.
  final AppThemePreference theme;

  /// BCP-47 language code, or `null` to follow the device language.
  final String? languageCode;

  /// Reads preferences from the raw settings [values].
  factory AppPreferences.fromSettings(Map<String, String> values) {
    final String language = values[SettingKeys.locale] ?? '';
    return AppPreferences(
      theme: AppThemePreference.fromStorage(values[SettingKeys.themeMode]),
      languageCode: language.isEmpty ? null : language,
    );
  }

  /// The rows to persist for these preferences.
  Map<String, String> toSettings() => <String, String>{
    SettingKeys.themeMode: theme.storageValue,
    SettingKeys.locale: languageCode ?? '',
  };

  @override
  bool operator ==(Object other) =>
      other is AppPreferences &&
      other.theme == theme &&
      other.languageCode == languageCode;

  @override
  int get hashCode => Object.hash(theme, languageCode);

  @override
  String toString() =>
      'AppPreferences(theme: ${theme.name}, language: $languageCode)';
}
