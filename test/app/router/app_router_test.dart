import 'package:flow/app/app.dart';
import 'package:flow/app/router/router.dart';
import 'package:flow/app/shell/app_destination.dart';
import 'package:flow/app/shell/dev_screen.dart';
import 'package:flow/app/shell/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shell switches between destinations', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const FlowApp()),
    );
    await tester.pumpAndSettle();

    // The app opens on the sign-in screen (`P1-05`); this test is about the
    // shell, so it enters it the way a signed-in operator would.
    container.read(appRouterProvider).go(AppDestination.pointOfSale.path);
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Design System'), findsOneWidget);

    // The default 800px test surface is "medium", so the shell uses a rail.
    await tester.tap(find.byIcon(Icons.inventory_2_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Products'), findsWidgets);
    expect(find.text('Coming soon'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('dev tools button opens the money/tax playground', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const FlowApp()),
    );
    await tester.pumpAndSettle();

    // The app opens on the sign-in screen (`P1-05`); this test is about the
    // shell, so it enters it the way a signed-in operator would.
    container.read(appRouterProvider).go(AppDestination.pointOfSale.path);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('dev-tools')));
    await tester.pumpAndSettle();

    expect(find.byType(DevScreen), findsOneWidget);
    expect(find.text('Developer tools'), findsWidgets);
    // Defaults: 100.00 @ 14% exclusive => net 100.00, tax 14.00, gross 114.00;
    // quantity 3 => line total 342.00.
    expect(find.text('100.00 EGP'), findsOneWidget);
    expect(find.text('14.00 EGP'), findsOneWidget);
    expect(find.text('114.00 EGP'), findsOneWidget);
    expect(find.text('342.00 EGP'), findsOneWidget);
  });
}
