import 'package:flow/app/app.dart';
import 'package:flow/app/router/router.dart';
import 'package:flow/app/shell/app_destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('language toggle flips the app between LTR and RTL', (
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

    // The test environment reports an English locale, so the app starts LTR.
    expect(find.text('Design System'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(Scaffold))),
      TextDirection.ltr,
    );

    await tester.tap(find.byKey(const Key('language-toggle')));
    await tester.pumpAndSettle();

    // Arabic is bundled and is rendered right-to-left.
    expect(find.text('نظام التصميم'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(Scaffold))),
      TextDirection.rtl,
    );
  });
}
