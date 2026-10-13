// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_flavor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Exposes the build [AppFlavor] through Riverpod.
///
/// The value is resolved from `--dart-define=APP_FLAVOR` at startup (see
/// `lib/bootstrap.dart`) and can be overridden in tests via
/// `appFlavorProvider.overrideWith((ref) => AppFlavor.dev)`.

@ProviderFor(appFlavor)
final appFlavorProvider = AppFlavorProvider._();

/// Exposes the build [AppFlavor] through Riverpod.
///
/// The value is resolved from `--dart-define=APP_FLAVOR` at startup (see
/// `lib/bootstrap.dart`) and can be overridden in tests via
/// `appFlavorProvider.overrideWith((ref) => AppFlavor.dev)`.

final class AppFlavorProvider
    extends $FunctionalProvider<AppFlavor, AppFlavor, AppFlavor>
    with $Provider<AppFlavor> {
  /// Exposes the build [AppFlavor] through Riverpod.
  ///
  /// The value is resolved from `--dart-define=APP_FLAVOR` at startup (see
  /// `lib/bootstrap.dart`) and can be overridden in tests via
  /// `appFlavorProvider.overrideWith((ref) => AppFlavor.dev)`.
  AppFlavorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appFlavorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appFlavorHash();

  @$internal
  @override
  $ProviderElement<AppFlavor> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppFlavor create(Ref ref) {
    return appFlavor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppFlavor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppFlavor>(value),
    );
  }
}

String _$appFlavorHash() => r'0413806dcc81a9125e6fdcc2b43d44305a13b03b';
