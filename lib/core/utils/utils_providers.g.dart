// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utils_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The application clock.
///
/// Override in tests with `clockProvider.overrideWithValue(FixedClock(...))`
/// so time-dependent behaviour is deterministic.

@ProviderFor(clock)
final clockProvider = ClockProvider._();

/// The application clock.
///
/// Override in tests with `clockProvider.overrideWithValue(FixedClock(...))`
/// so time-dependent behaviour is deterministic.

final class ClockProvider extends $FunctionalProvider<Clock, Clock, Clock>
    with $Provider<Clock> {
  /// The application clock.
  ///
  /// Override in tests with `clockProvider.overrideWithValue(FixedClock(...))`
  /// so time-dependent behaviour is deterministic.
  ClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockHash();

  @$internal
  @override
  $ProviderElement<Clock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Clock create(Ref ref) {
    return clock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Clock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Clock>(value),
    );
  }
}

String _$clockHash() => r'55214d6539f7396a3ae1aa23b06eea79fdac0ebe';

/// The UUIDv7 generator, bound to [clockProvider] so identifiers and timestamps
/// share a single notion of "now".

@ProviderFor(idGenerator)
final idGeneratorProvider = IdGeneratorProvider._();

/// The UUIDv7 generator, bound to [clockProvider] so identifiers and timestamps
/// share a single notion of "now".

final class IdGeneratorProvider
    extends
        $FunctionalProvider<UuidV7Generator, UuidV7Generator, UuidV7Generator>
    with $Provider<UuidV7Generator> {
  /// The UUIDv7 generator, bound to [clockProvider] so identifiers and timestamps
  /// share a single notion of "now".
  IdGeneratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'idGeneratorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$idGeneratorHash();

  @$internal
  @override
  $ProviderElement<UuidV7Generator> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UuidV7Generator create(Ref ref) {
    return idGenerator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UuidV7Generator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UuidV7Generator>(value),
    );
  }
}

String _$idGeneratorHash() => r'6d4dc9a45db2ecfdc7c7f00babf4b34033d6e26e';
