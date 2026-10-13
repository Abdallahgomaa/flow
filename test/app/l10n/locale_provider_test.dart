import 'package:flow/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('language toggle flips the app between LTR and RTL', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: FlowApp()));
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
