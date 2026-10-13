// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controls the application language.
///
/// A state of `null` means "follow the device locale"; Flutter resolves it
/// against `kSupportedLocales`. Use [setLocale] to pin a language, or [toggle]
/// to flip between the two bundled ones (Arabic ↔ English).
///
/// Kept alive for the whole session because the selected language must survive
/// navigation and rebuilds.

@ProviderFor(LocaleController)
final localeControllerProvider = LocaleControllerProvider._();

/// Controls the application language.
///
/// A state of `null` means "follow the device locale"; Flutter resolves it
/// against `kSupportedLocales`. Use [setLocale] to pin a language, or [toggle]
/// to flip between the two bundled ones (Arabic ↔ English).
///
/// Kept alive for the whole session because the selected language must survive
/// navigation and rebuilds.
final class LocaleControllerProvider
    extends $NotifierProvider<LocaleController, Locale?> {
  /// Controls the application language.
  ///
  /// A state of `null` means "follow the device locale"; Flutter resolves it
  /// against `kSupportedLocales`. Use [setLocale] to pin a language, or [toggle]
  /// to flip between the two bundled ones (Arabic ↔ English).
  ///
  /// Kept alive for the whole session because the selected language must survive
  /// navigation and rebuilds.
  LocaleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeControllerHash();

  @$internal
  @override
  LocaleController create() => LocaleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale?>(value),
    );
  }
}

String _$localeControllerHash() => r'7d6157a5ba208a1fcae1b5e1eb50770b8cceb982';

/// Controls the application language.
///
/// A state of `null` means "follow the device locale"; Flutter resolves it
/// against `kSupportedLocales`. Use [setLocale] to pin a language, or [toggle]
/// to flip between the two bundled ones (Arabic ↔ English).
///
/// Kept alive for the whole session because the selected language must survive
/// navigation and rebuilds.

abstract class _$LocaleController extends $Notifier<Locale?> {
  Locale? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Locale?, Locale?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Locale?, Locale?>,
              Locale?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
