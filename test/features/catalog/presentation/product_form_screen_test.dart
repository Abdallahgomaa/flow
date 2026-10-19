import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/database/database_providers.dart';
import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/features/catalog/data/catalog_providers.dart';
import 'package:flow/features/catalog/domain/product.dart';
import 'package:flow/features/catalog/domain/product_type.dart';
import 'package:flow/features/catalog/domain/use_cases/create_product.dart';
import 'package:flow/features/catalog/domain/use_cases/create_unit.dart';
import 'package:flow/features/catalog/domain/use_cases/ensure_default_stock_unit.dart';
import 'package:flow/features/catalog/domain/use_cases/update_product.dart';
import 'package:flow/features/catalog/presentation/catalog_routes.dart';
import 'package:flow/features/catalog/presentation/catalog_ui_providers.dart';
import 'package:flow/features/catalog/presentation/product_form_screen.dart';
import 'package:flow/shared/l10n/l10n.dart';
import 'package:flow/shared/widgets/widgets.dart';
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

/// The product form, which is also where the price rule is enforced on the write
/// path (`P2-05`).
///
/// Two things matter here. The form writes only through `CreateProduct` /
/// `UpdateProduct`, so the test asserts on the row they produced and on the
/// audit entry beside it — not on what the widgets show. And a role that may not
/// see prices must leave the stored price exactly where it was: `UpdateProduct`
/// requires a sale price, so the dangerous failure is not an exception but a
/// silent reprice, which is what the second test watches for.
void main() {
  final DateTime createdAt = DateTime.utc(2026, 5, 1);
  const int storedSaleMinorUnits = 1850;
  const int storedCostMinorUnits = 1200;

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

  /// The one unit every product in these tests is counted in.
  Future<void> seedUnit(ProviderContainer container) async {
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
  }

  /// Seeds a product to edit, through the real use case, and returns its id.
  Future<String> seedProduct(ProviderContainer container) async {
    await seedUnit(container);
    final Result<Product> result = await container.read(createProductProvider)(
      name: 'Milk',
      type: ProductType.simple,
      stockUnitCode: 'piece',
      salePrice: const Money.fromMinor(storedSaleMinorUnits, Currency.usd),
      costPrice: const Money.fromMinor(storedCostMinorUnits, Currency.usd),
    );
    return result.valueOrNull!.id;
  }

  Future<List<ProductRow>> rows(ProviderContainer container) => container
      .read(appDatabaseProvider)
      .select(container.read(appDatabaseProvider).products)
      .get();

  Future<List<AuditLogData>> auditEntries(ProviderContainer container) =>
      container
          .read(appDatabaseProvider)
          .select(container.read(appDatabaseProvider).auditLog)
          .get();

  /// The field carrying [label], found the way a user reads it.
  Finder fieldWithLabel(String label) => find.descendant(
    of: find.ancestor(
      of: find.text(label),
      matching: find.byType(CustomTextField),
    ),
    matching: find.byType(TextFormField),
  );

  /// Pumps the form at its own route, with a marker standing in for the details
  /// screen it navigates to after a successful save.
  ///
  /// The viewport is made tall enough that every field and the save button are
  /// on screen at once; a short viewport would push the button out of reach and
  /// turn a real assertion into an off-screen tap.
  Future<void> pumpForm(
    WidgetTester tester,
    ProviderContainer container, {
    String? productId,
  }) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final GoRouter router = GoRouter(
      initialLocation: productId == null
          ? CatalogRoutes.create
          : CatalogRoutes.edit(productId),
      routes: <RouteBase>[
        GoRoute(
          path: CatalogRoutes.products,
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: SizedBox.shrink()),
          routes: <RouteBase>[
            GoRoute(
              path: CatalogRoutes.createSegment,
              builder: (BuildContext context, GoRouterState state) =>
                  const Scaffold(body: ProductFormScreen()),
            ),
            GoRoute(
              path: CatalogRoutes.idSegment,
              builder: (BuildContext context, GoRouterState state) =>
                  const Scaffold(body: Text('details screen')),
              routes: <RouteBase>[
                GoRoute(
                  path: CatalogRoutes.editSegment,
                  builder: (BuildContext context, GoRouterState state) =>
                      Scaffold(body: ProductFormScreen(productId: productId)),
                ),
              ],
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

  testWidgets('creates a product through the use case and opens it', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = roleContainer();
    await seedUnit(container);
    await pumpForm(tester, container);

    expect(find.text('New product'), findsOneWidget);
    await tester.enterText(fieldWithLabel('Name'), 'Tea');
    await tester.enterText(fieldWithLabel('Sale price'), '12.50');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final List<ProductRow> products = await rows(container);
    expect(products, hasLength(1));
    expect(products.single.name, 'Tea');
    expect(products.single.salePriceMinorUnits, 1250);
    expect(products.single.stockUnitCode, 'piece');

    // The write is audited under the same transaction, so the product and its
    // history cannot disagree.
    final List<AuditLogData> log = await auditEntries(container);
    expect(log.last.action, CreateProduct.auditAction);
    expect(log.last.entityId, products.single.id);

    expect(find.text('details screen'), findsOneWidget);
  });

  testWidgets('carries the stored price over when a price-blind role edits', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = roleContainer(canViewPrices: false);
    final String productId = await seedProduct(container);
    await pumpForm(tester, container, productId: productId);

    // The price is not on the screen at all, only the note that explains why.
    expect(find.text('Edit product'), findsOneWidget);
    expect(find.text('Sale price'), findsNothing);
    expect(find.text('Cost price'), findsNothing);
    expect(
      find.text(
        'Your role may not see or change prices. They keep their current values.',
      ),
      findsOneWidget,
    );

    await tester.enterText(fieldWithLabel('Name'), 'Milk 1L');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // The name changed; the money did not. A save that repriced the product
    // would be invisible to the person who caused it.
    final List<ProductRow> products = await rows(container);
    expect(products.single.name, 'Milk 1L');
    expect(products.single.salePriceMinorUnits, storedSaleMinorUnits);
    expect(products.single.costPriceMinorUnits, storedCostMinorUnits);

    final List<AuditLogData> log = await auditEntries(container);
    expect(log.last.action, UpdateProduct.auditAction);
    expect(log.last.entityId, productId);

    expect(find.text('details screen'), findsOneWidget);
  });

  testWidgets('provisions a stock unit so a brand-new shop can save', (
    WidgetTester tester,
  ) async {
    // A fresh install owns no unit, and Phase 2 ships no unit screen: before the
    // form offers its picker, the catalogue has to provision one. Without it the
    // operator could only ever read "choose the unit the stock is counted in" —
    // an error they have no way to clear.
    final ProviderContainer container = roleContainer();
    await pumpForm(tester, container);

    await tester.enterText(fieldWithLabel('Name'), 'Tea');
    await tester.enterText(fieldWithLabel('Sale price'), '12.50');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Choose the unit the stock is counted in.'), findsNothing);

    final List<ProductRow> products = await rows(container);
    expect(products, hasLength(1));
    expect(products.single.stockUnitCode, EnsureDefaultStockUnit.code);

    // The unit was written once, and through the audited use case: the unit row
    // and its audit entry come before the product that depends on them.
    final AppDatabase database = container.read(appDatabaseProvider);
    final List<UnitRow> units = await database.select(database.units).get();
    expect(units.map((UnitRow unit) => unit.code), <String>[
      EnsureDefaultStockUnit.code,
    ]);
    final List<AuditLogData> log = await auditEntries(container);
    expect(log.map((AuditLogData entry) => entry.action), <String>[
      CreateUnit.auditAction,
      CreateProduct.auditAction,
    ]);
  });

  testWidgets('refuses a product with no name', (WidgetTester tester) async {
    final ProviderContainer container = roleContainer();
    await seedUnit(container);
    await pumpForm(tester, container);

    await tester.enterText(fieldWithLabel('Sale price'), '5.00');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a product name.'), findsOneWidget);
    expect(await rows(container), isEmpty);
  });

  testWidgets('rejects a price it cannot read', (WidgetTester tester) async {
    final ProviderContainer container = roleContainer();
    await seedUnit(container);
    await pumpForm(tester, container);

    await tester.enterText(fieldWithLabel('Name'), 'Tea');
    await tester.enterText(fieldWithLabel('Sale price'), 'not a price');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid price.'), findsOneWidget);
    expect(await rows(container), isEmpty);
  });
}
