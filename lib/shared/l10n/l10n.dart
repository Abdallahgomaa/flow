import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

// Re-export the generated class so callers only import one file.
export 'generated/app_localizations.dart';

/// The locales the app ships with, in preference order.
///
/// Arabic comes first on purpose: it is the primary market for Flow, so an
/// unsupported device locale falls back to the RTL language rather than English.
const List<Locale> kSupportedLocales = <Locale>[Locale('ar'), Locale('en')];

/// Language codes matching [kSupportedLocales], for language pickers.
const List<String> kSupportedLanguageCodes = <String>['ar', 'en'];

/// Ergonomic accessor so widgets read `context.l10n.appTitle` instead of the
/// verbose `AppLocalizations.of(context).appTitle`.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
