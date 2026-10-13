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
/// against `kSupportedLocales`. The choice is persisted so it survives closing
/// the app; [restore] is used by `bootstrap` to apply the stored value before
/// the first frame without writing it back.

@ProviderFor(LocaleController)
final localeControllerProvider = LocaleControllerProvider._();

/// Controls the application language.
///
/// A state of `null` means "follow the device locale"; Flutter resolves it
/// against `kSupportedLocales`. The choice is persisted so it survives closing
/// the app; [restore] is used by `bootstrap` to apply the stored value before
/// the first frame without writing it back.
final class LocaleControllerProvider
    extends $NotifierProvider<LocaleController, Locale?> {
  /// Controls the application language.
  ///
  /// A state of `null` means "follow the device locale"; Flutter resolves it
  /// against `kSupportedLocales`. The choice is persisted so it survives closing
  /// the app; [restore] is used by `bootstrap` to apply the stored value before
  /// the first frame without writing it back.
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

String _$localeControllerHash() => r'0c968ff9091dbf28ba90f98482b946829a9e795d';

/// Controls the application language.
///
/// A state of `null` means "follow the device locale"; Flutter resolves it
/// against `kSupportedLocales`. The choice is persisted so it survives closing
/// the app; [restore] is used by `bootstrap` to apply the stored value before
/// the first frame without writing it back.

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
