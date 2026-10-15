import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/database/database_providers.dart';
import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/features/catalog/data/catalog_providers.dart';
import 'package:flow/features/catalog/domain/barcode.dart';
import 'package:flow/features/catalog/domain/price_tier.dart';
import 'package:flow/features/catalog/domain/product.dart';
import 'package:flow/features/catalog/domain/product_type.dart';
import 'package:flow/features/catalog/presentation/catalog_routes.dart';
import 'package:flow/features/catalog/presentation/catalog_ui_providers.dart';
import 'package:flow/features/catalog/presentation/product_details_screen.dart';
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

/// The product details screen: one view holding the product, its price bands
/// (`P2-04`) and its barcodes (`P2-03`) (`P2-05`).
///
/// Two things are being pinned here. A retired band or barcode stays on the
/// screen — it is muted, never dropped, because a product's history is what
/// explains the stickers still on the shelf. And a role that may not see prices
/// loses the whole pricing section, not just the amounts, while everything that
/// is not money remains.
void main() {
  final DateTime createdAt = DateTime.utc(2026, 5, 1);
  const int saleMinorUnits = 1850;
  const int costMinorUnits = 1200;
  const int bandMinorUnits = 1500;
  const String barcodeCode = '6291000000001';
  const String categoryId = 'c1';

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

  /// Seeds a unit and a category directly, then the product and its labels
  /// through the real use cases, so no column name has to be guessed.
  Future<({String productId, String bandId, String barcodeId})> seed(
    ProviderContainer container,
  ) async {
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
            id: categoryId,
            name: 'Drinks',
            createdAt: createdAt,
          ),
        );

    final Result<Product> product = await container.read(createProductProvider)(
      name: 'Milk',
      type: ProductType.simple,
      stockUnitCode: 'piece',
      salePrice: const Money.fromMinor(saleMinorUnits, Currency.usd),
      categoryId: categoryId,
      costPrice: const Money.fromMinor(costMinorUnits, Currency.usd),
      reorderLevel: Quantity.units(6),
    );
    final String productId = product.valueOrNull!.id;

    final Result<TierPrice> band =
        await container.read(createTierPriceProvider)(
          productId: productId,
          tier: PriceTier.wholesale,
          price: const Money.fromMinor(bandMinorUnits, Currency.usd),
          minQuantity: Quantity.units(12),
        );
    final Result<Barcode> barcode = await container.read(createBarcodeProvider)(
      code: barcodeCode,
      productId: productId,
    );

    return (
      productId: productId,
      bandId: band.valueOrNull!.id,
      barcodeId: barcode.valueOrNull!.id,
    );
  }

  /// The string the shop's currency renders [minorUnits] as.
  Future<String> money(ProviderContainer container, int minorUnits) async {
    final Currency currency = (await container.read(
      shopCurrencyProvider.future,
    )).valueOrNull!;
    return const MoneyFormatter().format(Money.fromMinor(minorUnits, currency));
  }

  /// The label a band renders: the tier, then the quantity it starts at.
  String bandLabel(PriceTier tier, String tierName, int startUnits) =>
      '$tierName · from ${Quantity.units(startUnits).toDecimalString()}';

  Future<void> pumpDetails(
    WidgetTester tester,
    ProviderContainer container,
    String productId,
  ) async {
    final GoRouter router = GoRouter(
      initialLocation: CatalogRoutes.details(productId),
      routes: <RouteBase>[
        GoRoute(
          path: CatalogRoutes.products,
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: SizedBox.shrink()),
          routes: <RouteBase>[
            GoRoute(
              path: CatalogRoutes.idSegment,
              builder: (BuildContext context, GoRouterState state) =>
                  Scaffold(body: ProductDetailsScreen(productId: productId)),
              routes: <RouteBase>[
                GoRoute(
                  path: CatalogRoutes.editSegment,
                  builder: (BuildContext context, GoRouterState state) =>
                      const Scaffold(body: Text('edit screen')),
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

  testWidgets('gathers the product, its pricing, its bands and its barcodes', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = roleContainer();
    final ({String productId, String bandId, String barcodeId}) ids =
        await seed(container);
    await pumpDetails(tester, container, ids.productId);

    expect(find.text('Product details'), findsOneWidget);

    // Identity — never money, so it is here for every role.
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Simple'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Drinks'), findsOneWidget);
    expect(find.text('Stock unit'), findsOneWidget);
    expect(find.text('Piece'), findsOneWidget);
    expect(find.text('Purchase unit'), findsOneWidget);
    expect(find.text('None'), findsOneWidget);
    expect(find.text('Re-order level'), findsOneWidget);
    expect(find.text(Quantity.units(6).toDecimalString()), findsOneWidget);

    expect(find.text('Pricing'), findsOneWidget);
    expect(find.text('Sale price'), findsOneWidget);
    expect(find.text(await money(container, saleMinorUnits)), findsOneWidget);
    expect(find.text('Cost price'), findsOneWidget);
    expect(find.text(await money(container, costMinorUnits)), findsOneWidget);

    expect(find.text('Price bands'), findsOneWidget);
    expect(
      find.text(bandLabel(PriceTier.wholesale, 'Wholesale', 12)),
      findsOneWidget,
    );
    expect(find.text(await money(container, bandMinorUnits)), findsOneWidget);

    expect(find.text('Barcodes'), findsOneWidget);
    expect(find.text(barcodeCode), findsOneWidget);

    expect(find.text('Disabled'), findsNothing);
    expect(find.text('Edit'), findsOneWidget);
  });

  testWidgets('keeps a retired band and barcode, marked as retired', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = roleContainer();
    final ({String productId, String bandId, String barcodeId}) ids =
        await seed(container);
    await container.read(disableTierPriceProvider)(ids.bandId);
    await container.read(disableBarcodeProvider)(ids.barcodeId);

    await pumpDetails(tester, container, ids.productId);

    // Retired is a state, not a deletion: the row is still what the shelf says.
    expect(
      find.text(bandLabel(PriceTier.wholesale, 'Wholesale', 12)),
      findsOneWidget,
    );
    expect(find.text(barcodeCode), findsOneWidget);
    expect(find.text('Disabled'), findsNWidgets(2));
  });

  testWidgets('drops the whole pricing section for a role that may not see it', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = roleContainer(canViewPrices: false);
    final ({String productId, String bandId, String barcodeId}) ids =
        await seed(container);
    await pumpDetails(tester, container, ids.productId);

    // Not one amount, and not the empty frames that used to hold them either: a
    // band with no price has nothing left to say.
    expect(find.text('Pricing'), findsNothing);
    expect(find.text('Price bands'), findsNothing);
    expect(find.text('Sale price'), findsNothing);
    expect(find.text('Cost price'), findsNothing);
    expect(find.text(await money(container, saleMinorUnits)), findsNothing);
    expect(find.text(await money(container, costMinorUnits)), findsNothing);
    expect(find.text(await money(container, bandMinorUnits)), findsNothing);
    expect(find.textContaining('18.50'), findsNothing);

    // Everything that is not money is still there, in full.
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Drinks'), findsOneWidget);
    expect(find.text('Piece'), findsOneWidget);
    expect(find.text('Re-order level'), findsOneWidget);
    expect(find.text('Barcodes'), findsOneWidget);
    expect(find.text(barcodeCode), findsOneWidget);
  });

  testWidgets('withholds the edit action from a role that may not manage', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = roleContainer(canManageProducts: false);
    final ({String productId, String bandId, String barcodeId}) ids =
        await seed(container);
    await pumpDetails(tester, container, ids.productId);

    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Edit'), findsNothing);
  });
}
