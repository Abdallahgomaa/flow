// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The settings repository used by the UI and by `bootstrap`.
///
/// It is the single bridge between the database providers in `core` and the
/// settings feature, so no widget ever constructs a repository by hand.

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

/// The settings repository used by the UI and by `bootstrap`.
///
/// It is the single bridge between the database providers in `core` and the
/// settings feature, so no widget ever constructs a repository by hand.

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  /// The settings repository used by the UI and by `bootstrap`.
  ///
  /// It is the single bridge between the database providers in `core` and the
  /// settings feature, so no widget ever constructs a repository by hand.
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'9b5563a3f6eee2dac24bc9195cbbd059101879e7';

/// Reads the saved business profile.

@ProviderFor(loadBusinessProfile)
final loadBusinessProfileProvider = LoadBusinessProfileProvider._();

/// Reads the saved business profile.

final class LoadBusinessProfileProvider
    extends
        $FunctionalProvider<
          LoadBusinessProfile,
          LoadBusinessProfile,
          LoadBusinessProfile
        >
    with $Provider<LoadBusinessProfile> {
  /// Reads the saved business profile.
  LoadBusinessProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadBusinessProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadBusinessProfileHash();

  @$internal
  @override
  $ProviderElement<LoadBusinessProfile> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoadBusinessProfile create(Ref ref) {
    return loadBusinessProfile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadBusinessProfile value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadBusinessProfile>(value),
    );
  }
}

String _$loadBusinessProfileHash() =>
    r'370a495303bec10541788f3b94b7487323d493c6';

/// Validates and saves the business profile.

@ProviderFor(saveBusinessProfile)
final saveBusinessProfileProvider = SaveBusinessProfileProvider._();

/// Validates and saves the business profile.

final class SaveBusinessProfileProvider
    extends
        $FunctionalProvider<
          SaveBusinessProfile,
          SaveBusinessProfile,
          SaveBusinessProfile
        >
    with $Provider<SaveBusinessProfile> {
  /// Validates and saves the business profile.
  SaveBusinessProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveBusinessProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveBusinessProfileHash();

  @$internal
  @override
  $ProviderElement<SaveBusinessProfile> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveBusinessProfile create(Ref ref) {
    return saveBusinessProfile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveBusinessProfile value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveBusinessProfile>(value),
    );
  }
}

String _$saveBusinessProfileHash() =>
    r'0b35aae880c17f4f2d0dea08b6c87b8a731b67c8';

/// Reads the persisted theme and language choices.

@ProviderFor(loadAppPreferences)
final loadAppPreferencesProvider = LoadAppPreferencesProvider._();

/// Reads the persisted theme and language choices.

final class LoadAppPreferencesProvider
    extends
        $FunctionalProvider<
          LoadAppPreferences,
          LoadAppPreferences,
          LoadAppPreferences
        >
    with $Provider<LoadAppPreferences> {
  /// Reads the persisted theme and language choices.
  LoadAppPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadAppPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadAppPreferencesHash();

  @$internal
  @override
  $ProviderElement<LoadAppPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoadAppPreferences create(Ref ref) {
    return loadAppPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadAppPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadAppPreferences>(value),
    );
  }
}

String _$loadAppPreferencesHash() =>
    r'17a57ac8821bc8f5c296a862e3b4fe9d6d961013';

/// Persists the theme choice.

@ProviderFor(saveThemePreference)
final saveThemePreferenceProvider = SaveThemePreferenceProvider._();

/// Persists the theme choice.

final class SaveThemePreferenceProvider
    extends
        $FunctionalProvider<
          SaveThemePreference,
          SaveThemePreference,
          SaveThemePreference
        >
    with $Provider<SaveThemePreference> {
  /// Persists the theme choice.
  SaveThemePreferenceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveThemePreferenceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveThemePreferenceHash();

  @$internal
  @override
  $ProviderElement<SaveThemePreference> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveThemePreference create(Ref ref) {
    return saveThemePreference(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveThemePreference value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveThemePreference>(value),
    );
  }
}

String _$saveThemePreferenceHash() =>
    r'7820588219c459dd09fd7ab63340ee83e2a2047b';

/// Persists the language choice.

@ProviderFor(saveLanguagePreference)
final saveLanguagePreferenceProvider = SaveLanguagePreferenceProvider._();

/// Persists the language choice.

final class SaveLanguagePreferenceProvider
    extends
        $FunctionalProvider<
          SaveLanguagePreference,
          SaveLanguagePreference,
          SaveLanguagePreference
        >
    with $Provider<SaveLanguagePreference> {
  /// Persists the language choice.
  SaveLanguagePreferenceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveLanguagePreferenceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveLanguagePreferenceHash();

  @$internal
  @override
  $ProviderElement<SaveLanguagePreference> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveLanguagePreference create(Ref ref) {
    return saveLanguagePreference(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveLanguagePreference value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveLanguagePreference>(value),
    );
  }
}

String _$saveLanguagePreferenceHash() =>
    r'7473200857a2326eeb4c5cbd1af4d494f43b3800';
