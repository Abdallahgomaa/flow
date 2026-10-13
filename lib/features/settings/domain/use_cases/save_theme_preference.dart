import 'package:flow/core/result/result.dart';

import '../app_preferences.dart';
import '../setting_keys.dart';
import '../settings_repository.dart';

/// Persists the theme choice.
///
/// Theme and language are written by separate use cases so the controllers that
/// own them stay independent (no controller needs to know the other's value).
final class SaveThemePreference {
  /// Creates the use case.
  const SaveThemePreference(this._repository);

  final SettingsRepository _repository;

  /// Audit action recorded whenever the theme changes.
  static const String auditAction = 'settings.theme.saved';

  /// Saves [theme].
  Future<Result<void>> call(AppThemePreference theme) => _repository.save(
    values: <String, String>{SettingKeys.themeMode: theme.storageValue},
    action: auditAction,
    payload: <String, Object?>{'theme': theme.storageValue},
  );
}
