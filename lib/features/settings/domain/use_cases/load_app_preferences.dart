import 'package:flow/core/result/result.dart';

import '../app_preferences.dart';
import '../settings_repository.dart';

/// Reads the persisted theme and language choices.
///
/// Called once during `bootstrap`, before the first frame, so the app opens in
/// the user's chosen theme and language instead of flashing the defaults.
final class LoadAppPreferences {
  /// Creates the use case.
  const LoadAppPreferences(this._repository);

  final SettingsRepository _repository;

  /// Executes the use case.
  Future<Result<AppPreferences>> call() async {
    final Result<Map<String, String>> result = await _repository.readAll();
    return result.map(AppPreferences.fromSettings);
  }
}
