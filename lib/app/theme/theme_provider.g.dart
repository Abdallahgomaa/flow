// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the user-selected [ThemeMode] for the whole app.
///
/// The choice is written to the settings table (one audited row plus one audit
/// entry) so it survives closing the app; [restore] is used by `bootstrap` to
/// apply the stored value before the first frame without writing it back.

@ProviderFor(ThemeModeController)
final themeModeControllerProvider = ThemeModeControllerProvider._();

/// Holds the user-selected [ThemeMode] for the whole app.
///
/// The choice is written to the settings table (one audited row plus one audit
/// entry) so it survives closing the app; [restore] is used by `bootstrap` to
/// apply the stored value before the first frame without writing it back.
final class ThemeModeControllerProvider
    extends $NotifierProvider<ThemeModeController, ThemeMode> {
  /// Holds the user-selected [ThemeMode] for the whole app.
  ///
  /// The choice is written to the settings table (one audited row plus one audit
  /// entry) so it survives closing the app; [restore] is used by `bootstrap` to
  /// apply the stored value before the first frame without writing it back.
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
    r'2aa23782f2082f828eec59257f1205a6b345229a';

/// Holds the user-selected [ThemeMode] for the whole app.
///
/// The choice is written to the settings table (one audited row plus one audit
/// entry) so it survives closing the app; [restore] is used by `bootstrap` to
/// apply the stored value before the first frame without writing it back.

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
