import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/database/database_providers.dart';
import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/features/catalog/data/catalog_providers.dart';
import 'package:flow/features/catalog/domain/product.dart';
import 'package:flow/features/catalog/domain/product_type.dart';
import 'package:flow/features/catalog/presentation/catalog_routes.dart';
import 'package:flow/features/catalog/presentation/catalog_ui_providers.dart';
import 'package:flow/features/catalog/presentation/product_list_screen.dart';
import 'package:flow/shared/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// In-memory [DatabaseConnector] so the screen runs against a real Drift
/// database without SQLCipher or the file system.
final class _MemoryConnector implements DatabaseConnector {
  @override
  QueryExecutor open() => NativeDatabase.memory(setup: DatabasePragmas.apply);
}

/// The product list, including the «بدون أسعار» acceptance criterion (`P2-05`).
///
/// The screen reads through the real use cases into a real database, and the
/// role is played by overriding the three permission flags — the same ones the
/// screens actually consult. Nothing about the price rule is stubbed, so a
/// regression that leaks a price fails here rather than in production.
void main() {
  final DateTime createdAt = DateTime.utc(2026, 5, 1);
  const int milkMinorUnits = 1850;
  const int oilMinorUnits = 4200;

  ProviderContainer roleContainer({
    bool canViewPrices = true,
    bool canManageProducts = true,
  }) {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        databaseConnectorProvider.overrideWith((Ref ref) => _MemoryConnector()),
        canViewProductsProvider.overrideWithValue(true),
        canManageProductsProvider.overrideWithValue(canManageProducts),
        canViewPricesProvider.overrideWithValue(canViewPrices),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Seeds one unit and one category, then two products through the real use
  /// case; returns the ids it generated.
  Future<List<String>> seed(
    ProviderContainer container, {
    bool withProducts = true,
  }) async {
    final AppDatabase database = container.read(appDatabaseProvider);
    await database
        .into(database.units)
        .insert(
          UnitsCompanion.insert(
            code: 'piece',
            name: 'Piece',
            createdAt: createdAt,
          ),
        );
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'c1',
            name: 'Drinks',
            createdAt: createdAt,
          ),
        );

    if (!withProducts) {
      return const <String>[];
    }

    final Result<Product> milk = await container.read(createProductProvider)(
      name: 'Milk',
      type: ProductType.simple,
      stockUnitCode: 'piece',
      salePrice: const Money.fromMinor(milkMinorUnits, Currency.usd),
      categoryId: 'c1',
    );
    final Result<Product> oil = await container.read(createProductProvider)(
      name: 'Olive oil',
      type: ProductType.simple,
      stockUnitCode: 'piece',
      salePrice: const Money.fromMinor(oilMinorUnits, Currency.usd),
    );

    return <String>[milk.valueOrNull!.id, oil.valueOrNull!.id];
  }

  /// The string the shop's currency renders [minorUnits] as.
  ///
  /// Money is never asserted against a hard-coded symbol: the test asks the same
  /// provider the screen asks, so it stays true if the default currency changes.
  Future<String> money(ProviderContainer container, int minorUnits) async {
    final Currency currency = (await container.read(
      shopCurrencyProvider.future,
    )).valueOrNull!;
    return const MoneyFormatter().format(Money.fromMinor(minorUnits, currency));
  }

  Future<void> pumpList(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    // The tile navigates through `context.go`, so the screen needs a router.
    // The child route renders a marker instead of the real details screen: this
    // test is about where a tap takes the operator, not about what is there.
    final GoRouter router = GoRouter(
      initialLocation: CatalogRoutes.products,
      routes: <RouteBase>[
        GoRoute(
          path: CatalogRoutes.products,
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: ProductListScreen()),
          routes: <RouteBase>[
            GoRoute(
              path: CatalogRoutes.idSegment,
              builder: (BuildContext context, GoRouterState state) =>
                  const Scaffold(body: Text('details screen')),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: kSupportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists each product with its category, unit and price', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = roleContainer();
    await seed(container);
    await pumpList(tester, container);

    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Products: 2'), findsOneWidget);
    expect(find.text('New product'), findsOneWidget);

    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Simple · Drinks · Piece'), findsOneWidget);
    expect(find.text(await money(container, milkMinorUnits)), findsOneWidget);
    expect(find.text(await money(container, oilMinorUnits)), findsOneWidget);
  });

  testWidgets(
    'shows the product but no price to a role that may not see them',
    (WidgetTester tester) async {
      final ProviderContainer container = roleContainer(canViewPrices: false);
      await seed(container);
      await pumpList(tester, container);

      // The catalogue is still fully usable: identity is not money.
      expect(find.text('Milk'), findsOneWidget);
      expect(find.text('Simple · Drinks · Piece'), findsOneWidget);

      // Not one price reaches the screen.
      expect(find.text(await money(container, milkMinorUnits)), findsNothing);
      expect(find.textContaining('18.50'), findsNothing);
      expect(find.textContaining('42.00'), findsNothing);
    },
  );

  testWidgets(
    'withholds the create action from a role that may not set prices',
    (WidgetTester tester) async {
      final ProviderContainer container = roleContainer(canViewPrices: false);
      await seed(container);
      await pumpList(tester, container);

      // A new product cannot exist without a price, so a role that may not set one
      // is never offered the form. Editing the rest still stays open.
      expect(find.text('New product'), findsNothing);
    },
  );

  testWidgets('opens the details screen when a product is tapped', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = roleContainer();
    final List<String> ids = await seed(container);
    await pumpList(tester, container);

    await tester.tap(find.text('Milk'));
    await tester.pumpAndSettle();

    expect(ids, hasLength(2));
    expect(find.text('details screen'), findsOneWidget);
    expect(find.text('Products: 2'), findsNothing);
  });

  testWidgets('filters the list as the operator types', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = roleContainer();
    await seed(container);
    await pumpList(tester, container);

    await tester.enterText(find.byType(TextField), 'olive');
    await tester.pumpAndSettle();

    expect(find.text('Olive oil'), findsOneWidget);
    expect(find.text('Milk'), findsNothing);
    // The count still describes the catalogue, not the filtered view.
    expect(find.text('Products: 2'), findsOneWidget);
  });

  testWidgets('explains an empty catalogue and offers a first product', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = roleContainer();
    await seed(container, withProducts: false);
    await pumpList(tester, container);

    expect(find.text('No products yet'), findsOneWidget);
    expect(
      find.text('Add your first product to start selling.'),
      findsOneWidget,
    );
    // The search field and the count line would be noise with nothing to search.
    expect(find.text('Products: 0'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('New product'), findsNWidgets(2));
  });

  testWidgets('says so when a search matches nothing', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = roleContainer();
    await seed(container);
    await pumpList(tester, container);

    await tester.enterText(find.byType(TextField), 'nothing like this');
    await tester.pumpAndSettle();

    expect(find.text('No products found'), findsOneWidget);
    expect(find.text('Try another word.'), findsOneWidget);
    // An empty result is not an empty catalogue, so no first-product action.
    expect(find.text('New product'), findsOneWidget);
  });
}
