// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the user-selected [ThemeMode] for the whole app.
///
/// Kept alive for the whole session; later steps will persist the choice in
/// the `settings` table (P0-10 / P1-12).

@ProviderFor(ThemeModeController)
final themeModeControllerProvider = ThemeModeControllerProvider._();

/// Holds the user-selected [ThemeMode] for the whole app.
///
/// Kept alive for the whole session; later steps will persist the choice in
/// the `settings` table (P0-10 / P1-12).
final class ThemeModeControllerProvider
    extends $NotifierProvider<ThemeModeController, ThemeMode> {
  /// Holds the user-selected [ThemeMode] for the whole app.
  ///
  /// Kept alive for the whole session; later steps will persist the choice in
  /// the `settings` table (P0-10 / P1-12).
  ThemeModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeControllerHash();

  @$internal
  @override
  ThemeModeController create() => ThemeModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeControllerHash() =>
    r'be4b544fc60afe4624b3508bd61d570f1689bfff';

/// Holds the user-selected [ThemeMode] for the whole app.
///
/// Kept alive for the whole session; later steps will persist the choice in
/// the `settings` table (P0-10 / P1-12).

abstract class _$ThemeModeController extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
