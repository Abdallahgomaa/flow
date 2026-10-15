import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/features/catalog/data/drift_product_repository.dart';
import 'package:flow/features/catalog/data/drift_tier_price_repository.dart';
import 'package:flow/features/catalog/domain/price_tier.dart';
import 'package:flow/features/catalog/domain/product_repository.dart';
import 'package:flow/features/catalog/domain/use_cases/select_price.dart';
import 'package:flow/features/settings/data/drift_settings_repository.dart';
import 'package:flow/features/settings/domain/setting_keys.dart';
import 'package:flow/features/settings/domain/use_cases/load_business_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// Covers the acceptance criterion of `P2-04` end to end: the price a sale gets
/// is chosen from the tier **and** the quantity, through the real use case over
/// real stored bands.
void main() {
  const String productId = 'p1';
  const Money retail = Money.fromMinor(1850, Currency.egp);
  const Money wholesale = Money.fromMinor(1500, Currency.egp);
  const Money wholesaleBulk = Money.fromMinor(1350, Currency.egp);

  late AppDatabase database;
  late AuditService audit;
  late FixedClock clock;
  late DriftSettingsRepository settings;
  late DriftTierPriceRepository tiers;
  late DriftProductRepository products;
  late SelectPrice selectPrice;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory(setup: DatabasePragmas.apply));
    clock = FixedClock(DateTime.utc(2026, 5, 1));
    audit = AuditService(database: database, clock: clock);
    settings = DriftSettingsRepository(
      database: database,
      unitOfWork: DriftUnitOfWork(database),
      auditService: audit,
      clock: clock,
    );
    tiers = DriftTierPriceRepository(
      database: database,
      unitOfWork: DriftUnitOfWork(database),
      auditService: audit,
      clock: clock,
      loadBusinessProfile: LoadBusinessProfile(settings),
    );
    products = DriftProductRepository(
      database: database,
      unitOfWork: DriftUnitOfWork(database),
      auditService: audit,
      clock: clock,
      loadBusinessProfile: LoadBusinessProfile(settings),
    );
    selectPrice = SelectPrice(tiers, products);
    await settings.save(
      values: <String, String>{SettingKeys.currency: 'EGP'},
      action: 'settings.updated',
    );
    await database
        .into(database.units)
        .insert(
          UnitsCompanion.insert(
            code: 'piece',
            name: 'Piece',
            createdAt: clock.nowUtc(),
          ),
        );
    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            id: productId,
            name: 'Milk',
            type: 'simple',
            stockUnitCode: 'piece',
            salePriceMinorUnits: retail.minorUnits,
            createdAt: clock.nowUtc(),
          ),
        );
  });

  tearDown(() => database.close());

  Future<void> addBand({
    required String id,
    required PriceTier tier,
    required int startUnits,
    required Money price,
  }) => tiers.create(
    tierPrice: TierPrice(
      id: id,
      productId: productId,
      tier: tier,
      price: price,
      minQuantity: Quantity.units(startUnits),
      createdAt: clock.nowUtc(),
    ),
    action: 'tierPrice.created',
  );

  test('the acceptance case: tier and quantity decide the price', () async {
    await addBand(
      id: 'w1',
      tier: PriceTier.wholesale,
      startUnits: 12,
      price: wholesale,
    );
    await addBand(
      id: 'w2',
      tier: PriceTier.wholesale,
      startUnits: 100,
      price: wholesaleBulk,
    );

    expect(
      (await selectPrice(
        productId: productId,
        tier: PriceTier.wholesale,
        quantity: Quantity.units(12),
      )).valueOrNull,
      wholesale,
    );
    expect(
      (await selectPrice(
        productId: productId,
        tier: PriceTier.wholesale,
        quantity: Quantity.units(150),
      )).valueOrNull,
      wholesaleBulk,
    );
  });

  test('a product with no bands sells at its own price', () async {
    expect(
      (await selectPrice(
        productId: productId,
        tier: PriceTier.retail,
        quantity: Quantity.units(1),
      )).valueOrNull,
      retail,
    );
  });

  test(
    'a quantity below the smallest band falls back, never to free',
    () async {
      await addBand(
        id: 'w1',
        tier: PriceTier.wholesale,
        startUnits: 12,
        price: wholesale,
      );

      expect(
        (await selectPrice(
          productId: productId,
          tier: PriceTier.wholesale,
          quantity: Quantity.units(2),
        )).valueOrNull,
        retail,
      );
    },
  );

  test('a product that is gone reports not found', () async {
    final Result<Money> result = await selectPrice(
      productId: 'missing',
      tier: PriceTier.retail,
      quantity: Quantity.units(1),
    );

    expect(result.failureOrNull, isA<NotFoundFailure>());
    expect(result.failureOrNull?.code, ProductRepository.notFoundCode);
  });

  test('a retired band stops pricing, and the product price returns', () async {
    await addBand(
      id: 'w1',
      tier: PriceTier.wholesale,
      startUnits: 12,
      price: wholesale,
    );
    await tiers.disable(id: 'w1', action: 'tierPrice.disabled');

    expect(
      (await selectPrice(
        productId: productId,
        tier: PriceTier.wholesale,
        quantity: Quantity.units(50),
      )).valueOrNull,
      retail,
    );
  });

  test('the chosen price carries the shop currency', () async {
    await addBand(
      id: 'r1',
      tier: PriceTier.retail,
      startUnits: 1,
      price: retail,
    );

    final Money chosen = (await selectPrice(
      productId: productId,
      tier: PriceTier.retail,
      quantity: Quantity.units(3),
    )).valueOrNull!;

    expect(chosen.currency, Currency.egp);
  });
}
