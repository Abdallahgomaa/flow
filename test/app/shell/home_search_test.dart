import 'package:flow/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FlowApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('filters the demo catalogue by product name', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField), 'milk');
    await tester.pumpAndSettle();

    expect(find.text('Fresh milk 1L'), findsOneWidget);
    expect(find.text('Matches: 1'), findsOneWidget);
  });

  testWidgets('filters by barcode and shows the empty state', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField), '1000000000031');
    await tester.pumpAndSettle();
    expect(find.text('Egyptian rice 1kg'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'no-such-product');
    await tester.pumpAndSettle();
    expect(find.text('No products found'), findsOneWidget);
    expect(find.text('Matches: 0'), findsNothing);
  });
}
