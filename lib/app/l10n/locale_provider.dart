import 'dart:async';

import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/logger.dart';
import 'package:flow/features/settings/data/settings_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_provider.g.dart';

/// Controls the application language.
///
/// A state of `null` means "follow the device locale"; Flutter resolves it
/// against `kSupportedLocales`. The choice is persisted so it survives closing
/// the app; [restore] is used by `bootstrap` to apply the stored value before
/// the first frame without writing it back.
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  /// Logger component name.
  static const String _logName = 'app.locale';

  @override
  Locale? build() => null;

  /// Pins the app to [locale] and persists it; `null` returns to the device
  /// locale.
  void setLocale(Locale? locale) {
    if (state?.languageCode == locale?.languageCode) {
      return;
    }
    state = locale;
    unawaited(_persist(locale));
  }

  /// Applies a stored [locale] **without** writing it back (startup hydration).
  void restore(Locale? locale) => state = locale;

  /// Flips between Arabic and English.
  void toggle() {
    setLocale(
      state?.languageCode == 'ar' ? const Locale('en') : const Locale('ar'),
    );
  }

  /// Writes the language choice to the local database.
  ///
  /// This is a convenience write running in the background: a storage problem
  /// — or a missing database, as in a widget test that does not wire one — is
  /// logged instead of thrown, because the language must still switch for the
  /// current session.
  Future<void> _persist(Locale? locale) async {
    Object? problem;
    try {
      final Result<void> result = await ref.read(
        saveLanguagePreferenceProvider,
      )(locale?.languageCode);
      problem = switch (result) {
        Err<void>(:final Failure failure) => failure,
        Ok<void>() => null,
      };
    } on Object catch (error) {
      problem = error;
    }
    if (problem != null) {
      AppLogger.instance.warning(
        'Could not persist the language.',
        name: _logName,
        error: problem,
      );
    }
  }
}
