import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/design/app_dimens.dart';
import '../../shared/l10n/l10n.dart';
import '../l10n/locale_provider.dart';
import '../router/router.dart';
import '../theme/theme_provider.dart';
import 'app_destination.dart';

/// Adaptive navigation shell shared by every top-level destination.
///
/// Phones get a bottom `NavigationBar`; tablets and desktops (anything wider
/// than [WindowSize.compact]) get a `NavigationRail`. The shell owns the
/// application's single `Scaffold` and `AppBar`; page bodies must stay
/// body-only.
class AdaptiveShell extends ConsumerWidget {
  const AdaptiveShell({required this.navigationShell, super.key});

  /// The go_router shell state — one independent nested navigator per branch.
  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    // Re-tapping the current tab returns it to its root location.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final bool useRail =
        windowSizeFor(MediaQuery.sizeOf(context).width) != WindowSize.compact;

    final List<NavigationRailDestination> railDestinations =
        <NavigationRailDestination>[
          for (final AppDestination destination in AppDestination.values)
            NavigationRailDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: Text(destination.label(l10n)),
            ),
        ];
    final List<NavigationDestination> barDestinations = <NavigationDestination>[
      for (final AppDestination destination in AppDestination.values)
        NavigationDestination(
          icon: Icon(destination.icon),
          selectedIcon: Icon(destination.selectedIcon),
          label: destination.label(l10n),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: <Widget>[
          IconButton(
            key: const Key('dev-tools'),
            tooltip: l10n.devScreenTitle,
            onPressed: () => context.push(AppRoutes.dev),
            icon: const Icon(Icons.construction_outlined),
          ),
          IconButton(
            key: const Key('language-toggle'),
            tooltip: l10n.languageLabel,
            onPressed: () =>
                ref.read(localeControllerProvider.notifier).toggle(),
            icon: const Icon(Icons.translate),
          ),
          IconButton(
            key: const Key('theme-toggle'),
            tooltip: l10n.themeToggleTooltip,
            onPressed: () =>
                ref.read(themeModeControllerProvider.notifier).cycle(),
            icon: const Icon(Icons.dark_mode_outlined),
          ),
        ],
      ),
      body: useRail
          ? Row(
              children: <Widget>[
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _goBranch,
                  labelType: NavigationRailLabelType.all,
                  destinations: railDestinations,
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: navigationShell),
              ],
            )
          : navigationShell,
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
              destinations: barDestinations,
            ),
    );
  }
}
