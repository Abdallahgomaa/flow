import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_flavor.dart';
import '../core/config/app_flavor_provider.dart';
import 'shell/home_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

/// Root widget of the Flow application.
///
/// Reads app-level providers (flavor, theme mode) and delegates routing to the
/// adaptive shell ([HomeScreen] for now; go_router arrives in P0-10).
class FlowApp extends ConsumerWidget {
  const FlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppFlavor flavor = ref.watch(appFlavorProvider);
    final ThemeMode themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp(
      title: 'Flow',
      debugShowCheckedModeBanner: flavor == AppFlavor.dev,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
