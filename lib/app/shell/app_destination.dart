import 'package:flutter/material.dart';

import '../../shared/l10n/l10n.dart';

/// A top-level destination of the adaptive shell.
///
/// The shell renders these as a `NavigationBar` on phones and a
/// `NavigationRail` on tablets/desktop. The router mirrors the same order so
/// `AppDestination.values[i]` always matches `navigationShell.currentIndex`.
enum AppDestination {
  pointOfSale(
    path: '/',
    icon: Icons.point_of_sale_outlined,
    selectedIcon: Icons.point_of_sale,
  ),
  products(
    path: '/products',
    icon: Icons.inventory_2_outlined,
    selectedIcon: Icons.inventory_2,
  ),
  inventory(
    path: '/inventory',
    icon: Icons.warehouse_outlined,
    selectedIcon: Icons.warehouse,
  ),
  reports(
    path: '/reports',
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
  ),
  settings(
    path: '/settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  );

  const AppDestination({
    required this.path,
    required this.icon,
    required this.selectedIcon,
  });

  /// Route path owned by this destination.
  final String path;

  /// Icon shown while the destination is not selected.
  final IconData icon;

  /// Icon shown while the destination is selected.
  final IconData selectedIcon;

  /// Localised label used by navigation widgets and page headers.
  String label(AppLocalizations l10n) => switch (this) {
    AppDestination.pointOfSale => l10n.navigationPos,
    AppDestination.products => l10n.navigationProducts,
    AppDestination.inventory => l10n.navigationInventory,
    AppDestination.reports => l10n.navigationReports,
    AppDestination.settings => l10n.navigationSettings,
  };
}
