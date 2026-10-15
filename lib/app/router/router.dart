import 'package:flow/features/auth/auth.dart';
import 'package:flow/features/auth/data/auth_providers.dart';
import 'package:flow/features/auth/presentation/login_screen.dart';
import 'package:flow/features/auth/presentation/owner_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../settings/settings_route.dart';
import '../shell/adaptive_shell.dart';
import '../shell/app_destination.dart';
import '../shell/dev_screen.dart';
import '../shell/home_screen.dart';
import '../shell/placeholder_page.dart';

part 'router.g.dart';

/// Routes that live outside the adaptive shell.
abstract final class AppRoutes {
  /// Developer tools (Money/Tax playground).
  static const String dev = '/dev';

  /// The sign-in screen (`P1-05`).
  ///
  /// It sits outside the shell and is reachable by path for now, so a returning
  /// operator can be tested by hand before any guard exists. `P1-09` replaces
  /// this with the real redirect that decides when the app may be entered.
  static const String login = '/login';

  /// The first-run owner setup screen.
  ///
  /// A brand-new installation has no accounts at all, so nobody exists who could
  /// sign in and the app has to ask for the owner first. Like the sign-in screen
  /// it lives outside the shell; the provisional gate in `appRouter` is what
  /// sends the app here, and `P1-09` replaces that gate with the real guards.
  static const String ownerSetup = '/owner-setup';
}

/// Builds the body for a top-level [AppDestination].
///
/// The point-of-sale and settings branches have real pages; the rest share the
/// placeholder until their features land.
Widget _pageFor(AppDestination destination) => switch (destination) {
  AppDestination.pointOfSale => const HomeScreen(),
  AppDestination.settings => const SettingsRoute(),
  AppDestination.products ||
  AppDestination.inventory ||
  AppDestination.reports => PlaceholderPage(destination: destination),
};

/// The application router.
///
/// Exposed through Riverpod so it is created once, overridable in tests, and
/// disposed with its scope.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // A brand-new installation has no accounts, so nobody could sign in. Until an
  // owner exists every location is answered with the setup screen instead. This
  // gate is deliberately provisional: `P1-09` replaces it with the real guards,
  // including the per-destination permission checks.
  final bool needsOwner = ref.watch(ownerSetupRequiredProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (BuildContext context, GoRouterState state) {
      final String location = state.matchedLocation;

      if (needsOwner) {
        return location == AppRoutes.ownerSetup ? null : AppRoutes.ownerSetup;
      }
      if (location == AppRoutes.ownerSetup) {
        return AppRoutes.login;
      }
      // Creating the owner flips `needsOwner`, which rebuilds this provider and
      // swaps in a fresh router that restarts at `initialLocation`; an operator
      // who is already signed in should not be bounced back to the sign-in form.
      if (location == AppRoutes.login && ref.read(sessionProvider).isSignedIn) {
        return AppDestination.pointOfSale.path;
      }
      return null;
    },
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) => AdaptiveShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          for (final AppDestination destination in AppDestination.values)
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: destination.path,
                  builder: (BuildContext context, GoRouterState state) =>
                      _pageFor(destination),
                ),
              ],
            ),
        ],
      ),
      GoRoute(
        path: AppRoutes.dev,
        builder: (BuildContext context, GoRouterState state) =>
            const DevScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) => LoginScreen(
          onSignedIn: () => context.go(AppDestination.pointOfSale.path),
        ),
      ),
      GoRoute(
        path: AppRoutes.ownerSetup,
        builder: (BuildContext context, GoRouterState state) =>
            OwnerSetupScreen(
              onInitialised: () => context.go(AppDestination.pointOfSale.path),
            ),
      ),
    ],
  );
}
