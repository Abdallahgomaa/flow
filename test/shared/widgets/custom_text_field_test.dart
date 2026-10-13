import 'package:flow/app/theme/app_theme.dart';
import 'package:flow/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('forwards text input to the controller', (tester) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _wrap(CustomTextField(controller: controller, label: 'Name')),
    );
    await tester.enterText(find.byType(TextFormField), 'Flow');

    expect(controller.text, 'Flow');
  });

  testWidgets('renders the label and helper text', (tester) async {
    await tester.pumpWidget(
      _wrap(const CustomTextField(label: 'Name', helperText: 'shown as hint')),
    );

    expect(find.text('Name'), findsOneWidget);
    expect(find.text('shown as hint'), findsOneWidget);
  });

  testWidgets('renders the error text', (tester) async {
    await tester.pumpWidget(
      _wrap(const CustomTextField(label: 'Name', errorText: 'invalid value')),
    );

    expect(find.text('Name'), findsOneWidget);
    expect(find.text('invalid value'), findsOneWidget);
  });

  testWidgets('obscure toggle reveals and masks input', (tester) async {
    await tester.pumpWidget(_wrap(const CustomTextField(obscureText: true)));

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  test('controller and initialValue are mutually exclusive', () {
    expect(
      () => CustomTextField(
        controller: TextEditingController(),
        initialValue: 'conflict',
      ),
      throwsAssertionError,
    );
  });
}
