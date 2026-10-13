// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Exposes the application [AppLogger] through Riverpod so it can be replaced
/// in tests or features without touching the global singleton:
///
/// ```dart
/// ProviderScope(overrides: [appLoggerProvider.overrideWithValue(custom)])
/// ```
///
/// The logger's timestamp source is the injected [clockProvider], so every
/// record can be made deterministic in tests by overriding the clock.

@ProviderFor(appLogger)
final appLoggerProvider = AppLoggerProvider._();

/// Exposes the application [AppLogger] through Riverpod so it can be replaced
/// in tests or features without touching the global singleton:
///
/// ```dart
/// ProviderScope(overrides: [appLoggerProvider.overrideWithValue(custom)])
/// ```
///
/// The logger's timestamp source is the injected [clockProvider], so every
/// record can be made deterministic in tests by overriding the clock.

final class AppLoggerProvider
    extends $FunctionalProvider<AppLogger, AppLogger, AppLogger>
    with $Provider<AppLogger> {
  /// Exposes the application [AppLogger] through Riverpod so it can be replaced
  /// in tests or features without touching the global singleton:
  ///
  /// ```dart
  /// ProviderScope(overrides: [appLoggerProvider.overrideWithValue(custom)])
  /// ```
  ///
  /// The logger's timestamp source is the injected [clockProvider], so every
  /// record can be made deterministic in tests by overriding the clock.
  AppLoggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLoggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLoggerHash();

  @$internal
  @override
  $ProviderElement<AppLogger> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppLogger create(Ref ref) {
    return appLogger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLogger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLogger>(value),
    );
  }
}

String _$appLoggerHash() => r'13af97b1077ef5454907b80858315603ee9d8878';
