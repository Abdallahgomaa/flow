import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

/// Holds the user-selected [ThemeMode] for the whole app.
///
/// Kept alive for the whole session; later steps will persist the choice in
/// the `settings` table (P0-10 / P1-12).
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  @override
  ThemeMode build() => ThemeMode.system;

  /// Applies an explicit [mode].
  void setMode(ThemeMode mode) => state = mode;

  /// Cycles system → light → dark → system.
  void cycle() {
    state = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
  }
}
