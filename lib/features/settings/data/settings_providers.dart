import 'package:flow/core/database/database_providers.dart';
import 'package:flow/core/utils/utils_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/settings_repository.dart';
import '../domain/use_cases/load_app_preferences.dart';
import '../domain/use_cases/load_business_profile.dart';
import '../domain/use_cases/save_business_profile.dart';
import '../domain/use_cases/save_language_preference.dart';
import '../domain/use_cases/save_theme_preference.dart';
import 'drift_settings_repository.dart';

part 'settings_providers.g.dart';

/// The settings repository used by the UI and by `bootstrap`.
///
/// It is the single bridge between the database providers in `core` and the
/// settings feature, so no widget ever constructs a repository by hand.
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) => DriftSettingsRepository(
  database: ref.watch(appDatabaseProvider),
  unitOfWork: ref.watch(unitOfWorkProvider),
  auditService: ref.watch(auditServiceProvider),
  clock: ref.watch(clockProvider),
);

/// Reads the saved business profile.
@Riverpod(keepAlive: true)
LoadBusinessProfile loadBusinessProfile(Ref ref) =>
    LoadBusinessProfile(ref.watch(settingsRepositoryProvider));

/// Validates and saves the business profile.
@Riverpod(keepAlive: true)
SaveBusinessProfile saveBusinessProfile(Ref ref) =>
    SaveBusinessProfile(ref.watch(settingsRepositoryProvider));

/// Reads the persisted theme and language choices.
@Riverpod(keepAlive: true)
LoadAppPreferences loadAppPreferences(Ref ref) =>
    LoadAppPreferences(ref.watch(settingsRepositoryProvider));

/// Persists the theme choice.
@Riverpod(keepAlive: true)
SaveThemePreference saveThemePreference(Ref ref) =>
    SaveThemePreference(ref.watch(settingsRepositoryProvider));

/// Persists the language choice.
@Riverpod(keepAlive: true)
SaveLanguagePreference saveLanguagePreference(Ref ref) =>
    SaveLanguagePreference(ref.watch(settingsRepositoryProvider));
