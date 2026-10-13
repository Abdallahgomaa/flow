import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_provider.g.dart';

/// Controls the application language.
///
/// A state of `null` means "follow the device locale"; Flutter resolves it
/// against `kSupportedLocales`. Use [setLocale] to pin a language, or [toggle]
/// to flip between the two bundled ones (Arabic ↔ English).
///
/// Kept alive for the whole session because the selected language must survive
/// navigation and rebuilds.
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  Locale? build() => null;

  /// Pins the app to [locale]; pass `null` to return to the system locale.
  void setLocale(Locale? locale) => state = locale;

  /// Flips between Arabic and English.
  void toggle() {
    state = state?.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
  }
}
