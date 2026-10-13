import 'package:flow/core/result/result.dart';

import '../setting_keys.dart';
import '../settings_repository.dart';

/// Persists the language choice.
///
/// `null` means "follow the device language" and is stored as an empty string,
/// because the `app_settings` table has no concept of null values.
final class SaveLanguagePreference {
  /// Creates the use case.
  const SaveLanguagePreference(this._repository);

  final SettingsRepository _repository;

  /// Audit action recorded whenever the language changes.
  static const String auditAction = 'settings.language.saved';

  /// Saves [languageCode] (`null` = follow the device language).
  Future<Result<void>> call(String? languageCode) => _repository.save(
    values: <String, String>{SettingKeys.locale: languageCode ?? ''},
    action: auditAction,
    payload: <String, Object?>{'language': languageCode},
  );
}
