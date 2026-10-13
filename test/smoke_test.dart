import 'package:flow/app/app.dart';
import 'package:flow/app/shell/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots and renders the home shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FlowApp()));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Flow'), findsOneWidget);
  });
}
