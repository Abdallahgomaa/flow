import 'package:flow/app/app.dart';
import 'package:flow/app/router/router.dart';
import 'package:flow/app/shell/app_destination.dart';
import 'package:flow/app/shell/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots and renders the home shell', (tester) async {
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
    expect(find.text('Flow'), findsOneWidget);
  });
}
