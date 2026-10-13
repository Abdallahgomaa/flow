import 'package:flow/app/theme/app_theme.dart';
import 'package:flow/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('renders the label and fires onPressed', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      _wrap(CustomButton(label: 'Save', onPressed: () => tapped++)),
    );

    expect(find.text('Save'), findsOneWidget);
    await tester.tap(find.text('Save'));
    expect(tapped, 1);
  });

  testWidgets('loading state shows a spinner and blocks taps', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      _wrap(
        CustomButton(label: 'Save', isLoading: true, onPressed: () => tapped++),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(CustomButton), warnIfMissed: false);
    expect(tapped, 0);
  });

  testWidgets('null onPressed renders a disabled button', (tester) async {
    await tester.pumpWidget(_wrap(const CustomButton(label: 'Save')));

    await tester.tap(find.text('Save'), warnIfMissed: false);
  });

  testWidgets('isExpanded stretches to the full width', (tester) async {
    await tester.pumpWidget(
      _wrap(const CustomButton(label: 'Save', isExpanded: true)),
    );

    final double buttonWidth = tester.getSize(find.byType(CustomButton)).width;
    final double screenWidth = tester.getSize(find.byType(Scaffold)).width;
    expect(buttonWidth, screenWidth);
  });

  testWidgets('renders leading and trailing icons', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const CustomButton(
          label: 'Search',
          icon: Icons.search,
          trailingIcon: Icons.arrow_forward,
        ),
      ),
    );

    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
  });
}
