import 'package:flow/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/locale_provider.dart';
import '../theme/theme_provider.dart';

/// Wires the settings screen to the application-level theme and locale state.
///
/// The screen itself must not import `lib/app/` (presentation boundary), so this
/// thin adapter lives in the composition root. It watches both controllers, which
/// means the selection highlights update live as the user switches theme or
/// language.
class SettingsRoute extends ConsumerWidget {
  /// Creates the route.
  const SettingsRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsScreen(
      themeMode: ref.watch(themeModeControllerProvider),
      languageCode: ref.watch(localeControllerProvider)?.languageCode,
      onThemeModeChanged: (ThemeMode mode) =>
          ref.read(themeModeControllerProvider.notifier).setMode(mode),
      onLanguageChanged: (String? code) => ref
          .read(localeControllerProvider.notifier)
          .setLocale(code == null ? null : Locale(code)),
    );
  }
}
