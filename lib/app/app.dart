import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_flavor.dart';
import '../core/config/app_flavor_provider.dart';
import '../shared/l10n/l10n.dart';
import 'l10n/locale_provider.dart';
import 'router/router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

/// Root widget of the Flow application.
///
/// Reads app-level providers (flavor, theme mode, locale) and delegates routing
/// to the Riverpod-managed `appRouterProvider`.
class FlowApp extends ConsumerWidget {
  const FlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppFlavor flavor = ref.watch(appFlavorProvider);
    final ThemeMode themeMode = ref.watch(themeModeControllerProvider);
    final Locale? locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      title: 'Flow',
      onGenerateTitle: (BuildContext context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: flavor == AppFlavor.dev,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: kSupportedLocales,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
