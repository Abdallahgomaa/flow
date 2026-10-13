import 'dart:async';

import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/logger.dart';
import 'package:flow/features/settings/data/settings_providers.dart';
import 'package:flow/features/settings/presentation/theme_mode_mapping.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

/// Holds the user-selected [ThemeMode] for the whole app.
///
/// The choice is written to the settings table (one audited row plus one audit
/// entry) so it survives closing the app; [restore] is used by `bootstrap` to
/// apply the stored value before the first frame without writing it back.
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  /// Logger component name.
  static const String _logName = 'app.theme';

  @override
  ThemeMode build() => ThemeMode.system;

  /// Applies an explicit [mode] and persists it.
  void setMode(ThemeMode mode) {
    if (state == mode) {
      return;
    }
    state = mode;
    unawaited(_persist(mode));
  }

  /// Applies a stored [mode] **without** writing it back (startup hydration).
  void restore(ThemeMode mode) => state = mode;

  /// Cycles system → light → dark → system.
  void cycle() {
    setMode(switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    });
  }

  /// Writes [mode] to the local database.
  ///
  /// This is a convenience write running in the background: a storage problem
  /// — or a missing database, as in a widget test that does not wire one — is
  /// logged instead of thrown, because the theme must still switch for the
  /// current session.
  Future<void> _persist(ThemeMode mode) async {
    Object? problem;
    try {
      final Result<void> result = await ref.read(saveThemePreferenceProvider)(
        mode.preference,
      );
      problem = switch (result) {
        Err<void>(:final Failure failure) => failure,
        Ok<void>() => null,
      };
    } on Object catch (error) {
      problem = error;
    }
    if (problem != null) {
      AppLogger.instance.warning(
        'Could not persist the theme mode.',
        name: _logName,
        error: problem,
      );
    }
  }
}
