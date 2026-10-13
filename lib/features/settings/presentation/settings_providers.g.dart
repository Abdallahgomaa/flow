// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The saved business profile, read straight from the database.
///
/// The provider exposes the raw `Result` instead of throwing, so the screen can
/// render a precise message for a storage failure. It is not kept alive: leaving
/// the settings destination disposes it and re-entering reloads from the
/// database, which is what makes the wiring verifiably "live".

@ProviderFor(savedBusinessProfile)
final savedBusinessProfileProvider = SavedBusinessProfileProvider._();

/// The saved business profile, read straight from the database.
///
/// The provider exposes the raw `Result` instead of throwing, so the screen can
/// render a precise message for a storage failure. It is not kept alive: leaving
/// the settings destination disposes it and re-entering reloads from the
/// database, which is what makes the wiring verifiably "live".

final class SavedBusinessProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<BusinessProfile>>,
          Result<BusinessProfile>,
          FutureOr<Result<BusinessProfile>>
        >
    with
        $FutureModifier<Result<BusinessProfile>>,
        $FutureProvider<Result<BusinessProfile>> {
  /// The saved business profile, read straight from the database.
  ///
  /// The provider exposes the raw `Result` instead of throwing, so the screen can
  /// render a precise message for a storage failure. It is not kept alive: leaving
  /// the settings destination disposes it and re-entering reloads from the
  /// database, which is what makes the wiring verifiably "live".
  SavedBusinessProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedBusinessProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedBusinessProfileHash();

  @$internal
  @override
  $FutureProviderElement<Result<BusinessProfile>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<BusinessProfile>> create(Ref ref) {
    return savedBusinessProfile(ref);
  }
}

String _$savedBusinessProfileHash() =>
    r'd1c37a38d3fb37959afe2d3b72e26e9b48dcfc1f';
