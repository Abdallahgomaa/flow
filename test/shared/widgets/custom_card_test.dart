import 'package:flow/app/theme/app_theme.dart';
import 'package:flow/shared/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('renders header and child content', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const CustomCard(
          title: 'Pending orders',
          subtitle: '3 items',
          child: Text('Body'),
        ),
      ),
    );

    expect(find.text('Pending orders'), findsOneWidget);
    expect(find.text('3 items'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
  });

  testWidgets('invokes onTap when tapped', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      _wrap(CustomCard(title: 'Tappable', onTap: () => tapped++)),
    );

    await tester.tap(find.text('Tappable'));
    expect(tapped, 1);
  });

  testWidgets('outlined variant draws a visible border', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const CustomCard(
          variant: CustomCardVariant.outlined,
          child: SizedBox(height: 32),
        ),
      ),
    );

    final Finder cardMaterial = find.descendant(
      of: find.byType(CustomCard),
      matching: find.byType(Material),
    );
    final Material material = tester.widget<Material>(cardMaterial);
    expect(material.shape, isA<RoundedRectangleBorder>());

    final RoundedRectangleBorder shape =
        material.shape! as RoundedRectangleBorder;
    expect(shape.side.color, isNot(Colors.transparent));
  });
}
