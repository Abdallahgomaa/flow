// `isNull`/`isNotNull` are exported by both drift (SQL expressions) and
// flutter_test (matchers); the tests mean the matchers, so drift's are hidden.
import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/features/catalog/data/drift_tier_price_repository.dart';
import 'package:flow/features/catalog/domain/price_tier.dart';
import 'package:flow/features/catalog/domain/tier_price_repository.dart';
import 'package:flow/features/settings/data/drift_settings_repository.dart';
import 'package:flow/features/settings/domain/setting_keys.dart';
import 'package:flow/features/settings/domain/use_cases/load_business_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// Covers `P2-04`: the band row, its money, the two-layer duplication rule and
/// the audit trail that has to explain every price change.
void main() {
  const String productId = 'p1';
  const String otherProductId = 'p2';
  const Money defaultPrice = Money.fromMinor(1850, Currency.egp);
  const Money editedPrice = Money.fromMinor(2000, Currency.egp);

  late AppDatabase database;
  late AuditService audit;
  late FixedClock clock;
  late DriftSettingsRepository settings;
  late DriftTierPriceRepository repository;

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
    repository = DriftTierPriceRepository(
      database: database,
      unitOfWork: DriftUnitOfWork(database),
      auditService: audit,
      clock: clock,
      loadBusinessProfile: LoadBusinessProfile(settings),
    );
    // The shop trades in Egyptian pounds, so a stored price is read back as EGP.
    await settings.save(
      values: <String, String>{SettingKeys.currency: 'EGP'},
      action: 'settings.updated',
    );
    // A band only exists next to a product, so the fixtures build the smallest
    // catalogue that can hold one.
    await database
        .into(database.units)
        .insert(
          UnitsCompanion.insert(
            code: 'piece',
            name: 'Piece',
            createdAt: clock.nowUtc(),
          ),
        );
    for (final String id in <String>[productId, otherProductId]) {
      await database
          .into(database.products)
          .insert(
            ProductsCompanion.insert(
              id: id,
              name: 'Product $id',
              type: 'simple',
              stockUnitCode: 'piece',
              salePriceMinorUnits: defaultPrice.minorUnits,
              createdAt: clock.nowUtc(),
            ),
          );
    }
  });

  tearDown(() => database.close());

  TierPrice band({
    String id = 't1',
    String productId = productId,
    PriceTier tier = PriceTier.retail,
    Money? price,
    Quantity minQuantity = TierPrice.firstBandQuantity,
    DateTime? disabledAt,
    DateTime? updatedAt,
  }) => TierPrice(
    id: id,
    productId: productId,
    tier: tier,
    price: price ?? defaultPrice,
    minQuantity: minQuantity,
    createdAt: DateTime.utc(2026, 5, 1),
    disabledAt: disabledAt,
    updatedAt: updatedAt,
  );

  Future<List<AuditLogData>> entries() =>
      database.select(database.auditLog).get();

  Future<List<PriceTierRow>> rows() =>
      database.select(database.priceTiers).get();

  test('a product with no bands is empty', () async {
    final Result<List<TierPrice>> result = await repository.readForProduct(
      productId,
    );

    expect(result.isOk, isTrue);
    expect(result.valueOrNull, isEmpty);
  });

  test('creating a band stores it and audits the write once', () async {
    final int baseline = (await entries()).length;

    final Result<TierPrice> created = await repository.create(
      tierPrice: band(),
      action: 'tierPrice.created',
      payload: band().toAuditPayload(),
    );

    expect(created, isA<Ok<TierPrice>>());
    final List<PriceTierRow> stored = await rows();
    expect(stored, hasLength(1));
    expect(stored.single.id, 't1');
    expect(stored.single.productId, productId);
    expect(stored.single.tier, 'retail');
    expect(stored.single.priceMinorUnits, 1850);
    expect(stored.single.minQuantityThousandths, 1000);
    expect(stored.single.disabledAt, isNull);

    final List<AuditLogData> log = await entries();
    expect(log, hasLength(baseline + 1));
    expect(log.last.action, 'tierPrice.created');
    expect(log.last.entity, DriftTierPriceRepository.auditEntity);
    expect(log.last.entityId, 't1');
    expect((await audit.verifyChain()).isIntact, isTrue);
  });

  test('a stored price is read back as money in the shop currency', () async {
    await repository.create(tierPrice: band(), action: 'tierPrice.created');

    final TierPrice read = (await repository.readById('t1')).valueOrNull!;

    expect(read.price, defaultPrice);
    expect(read.price.currency, Currency.egp);
    expect(read.minQuantity, TierPrice.firstBandQuantity);
  });

  test('a band keeps a weighted product edge in thousandths', () async {
    await repository.create(
      tierPrice: band(minQuantity: const Quantity.thousandths(2500)),
      action: 'tierPrice.created',
    );

    expect((await rows()).single.minQuantityThousandths, 2500);
    final TierPrice read = (await repository.readById('t1')).valueOrNull!;
    expect(read.minQuantity, const Quantity.thousandths(2500));
  });

  test('one product carries many bands, ordered by tier and edge', () async {
    // Inserted out of order on purpose: the query, not the callers, decides.
    await repository.create(
      tierPrice: band(
        id: 'w2',
        tier: PriceTier.wholesale,
        minQuantity: const Quantity.thousandths(12000),
      ),
      action: 'tierPrice.created',
    );
    await repository.create(
      tierPrice: band(id: 'r2', minQuantity: const Quantity.thousandths(12000)),
      action: 'tierPrice.created',
    );
    await repository.create(
      tierPrice: band(id: 'c1', tier: PriceTier.custom),
      action: 'tierPrice.created',
    );
    await repository.create(
      tierPrice: band(id: 'r1'),
      action: 'tierPrice.created',
    );

    final List<TierPrice> bands = (await repository.readForProduct(productId))
        .valueOrNull!;

    expect(
      bands
          .map(
            (TierPrice item) =>
                '${item.tier.code}:${item.minQuantity.thousandths}',
          )
          .toList(),
      <String>['custom:1000', 'retail:1000', 'retail:12000', 'wholesale:12000'],
    );
  });

  test('the same start quantity is allowed on a different tier', () async {
    await repository.create(
      tierPrice: band(id: 'r1'),
      action: 'tierPrice.created',
    );
    final Result<TierPrice> sameEdgeOtherTier = await repository.create(
      tierPrice: band(id: 'w1', tier: PriceTier.wholesale),
      action: 'tierPrice.created',
    );

    expect(sameEdgeOtherTier.isOk, isTrue);
    expect(await rows(), hasLength(2));
  });

  test(
    'a band for a product that is gone is refused and writes nothing',
    () async {
      final int baseline = (await entries()).length;

      final Result<TierPrice> refused = await repository.create(
        tierPrice: band(productId: 'missing'),
        action: 'tierPrice.created',
      );

      expect(refused, isA<Err<TierPrice>>());
      expect(refused.failureOrNull, isA<NotFoundFailure>());
      expect(
        refused.failureOrNull?.code,
        TierPriceRepository.productNotFoundCode,
      );
      expect(await rows(), isEmpty);
      expect(await entries(), hasLength(baseline));
    },
  );

  test('a second band at the same tier and edge is refused', () async {
    await repository.create(tierPrice: band(), action: 'tierPrice.created');
    final int baseline = (await entries()).length;

    final Result<TierPrice> refused = await repository.create(
      tierPrice: band(id: 't2'),
      action: 'tierPrice.created',
    );

    expect(refused, isA<Err<TierPrice>>());
    expect(refused.failureOrNull, isA<ConflictFailure>());
    expect(refused.failureOrNull?.code, TierPriceRepository.duplicateBandCode);
    // Nothing was written, and nothing was audited.
    expect(await rows(), hasLength(1));
    expect(await entries(), hasLength(baseline));
  });

  test('reading a band that is not there reports not found', () async {
    final Result<TierPrice> read = await repository.readById('missing');

    expect(read.failureOrNull, isA<NotFoundFailure>());
    expect(read.failureOrNull?.code, TierPriceRepository.notFoundCode);
  });

  test('editing a band rewrites its price and records the change', () async {
    await repository.create(tierPrice: band(), action: 'tierPrice.created');
    final TierPrice previous = (await repository.readById('t1')).valueOrNull!;
    clock.advance(const Duration(minutes: 5));
    final TierPrice edited = band(
      price: editedPrice,
      updatedAt: clock.nowUtc(),
    );

    final Result<TierPrice> updated = await repository.update(
      tierPrice: edited,
      action: 'tierPrice.updated',
      payload: <String, Object?>{
        ...edited.toAuditPayload(),
        ...edited.priceAuditPayload(previous: previous),
      },
    );

    expect(updated.isOk, isTrue);
    final PriceTierRow stored = (await rows()).single;
    expect(stored.priceMinorUnits, 2000);
    expect(stored.updatedAt?.toUtc(), DateTime.utc(2026, 5, 1, 0, 5));

    final Map<String, Object?> payload =
        jsonDecode((await entries()).last.payload) as Map<String, Object?>;
    expect(payload['priceMinorUnitsBefore'], 1850);
    expect(payload['priceMinorUnitsAfter'], 2000);
    expect((await audit.verifyChain()).isIntact, isTrue);
  });

  test('editing a band onto another band of its tier is refused', () async {
    await repository.create(tierPrice: band(), action: 'tierPrice.created');
    await repository.create(
      tierPrice: band(id: 't2', minQuantity: const Quantity.thousandths(12000)),
      action: 'tierPrice.created',
    );
    final int baseline = (await entries()).length;

    final Result<TierPrice> refused = await repository.update(
      tierPrice: band(
        id: 't2',
        minQuantity: TierPrice.firstBandQuantity,
        updatedAt: clock.nowUtc(),
      ),
      action: 'tierPrice.updated',
    );

    expect(refused.failureOrNull, isA<ConflictFailure>());
    expect(refused.failureOrNull?.code, TierPriceRepository.duplicateBandCode);
    expect(await entries(), hasLength(baseline));
  });

  test('editing a band does not collide with itself', () async {
    await repository.create(tierPrice: band(), action: 'tierPrice.created');

    final Result<TierPrice> updated = await repository.update(
      tierPrice: band(price: editedPrice, updatedAt: clock.nowUtc()),
      action: 'tierPrice.updated',
    );

    expect(updated.isOk, isTrue);
    expect((await rows()).single.priceMinorUnits, 2000);
  });

  test('editing a band that is gone reports not found', () async {
    final Result<TierPrice> result = await repository.update(
      tierPrice: band(),
      action: 'tierPrice.updated',
    );

    expect(result.failureOrNull, isA<NotFoundFailure>());
    expect(result.failureOrNull?.code, TierPriceRepository.notFoundCode);
  });

  test('disabling keeps the row, stamps the clock and audits it', () async {
    await repository.create(tierPrice: band(), action: 'tierPrice.created');
    clock.advance(const Duration(minutes: 5));

    final Result<void> disabled = await repository.disable(
      id: 't1',
      action: 'tierPrice.disabled',
    );

    expect(disabled.isOk, isTrue);
    final PriceTierRow stored = (await rows()).single;
    expect(stored.disabledAt?.toUtc(), DateTime.utc(2026, 5, 1, 0, 5));
    expect(stored.priceMinorUnits, 1850);
    expect((await entries()).last.action, 'tierPrice.disabled');
    expect((await audit.verifyChain()).isIntact, isTrue);
  });

  test('disabling twice succeeds and audits nothing the second time', () async {
    await repository.create(tierPrice: band(), action: 'tierPrice.created');
    await repository.disable(id: 't1', action: 'tierPrice.disabled');
    final int baseline = (await entries()).length;

    final Result<void> again = await repository.disable(
      id: 't1',
      action: 'tierPrice.disabled',
    );

    expect(again.isOk, isTrue);
    expect(await entries(), hasLength(baseline));
    expect((await rows()).single.disabledAt, isNotNull);
  });

  test('disabling a band that is not there reports not found', () async {
    final Result<void> result = await repository.disable(
      id: 'missing',
      action: 'tierPrice.disabled',
    );

    expect(result.failureOrNull, isA<NotFoundFailure>());
    expect(result.failureOrNull?.code, TierPriceRepository.notFoundCode);
  });

  test('a retired band is still visible to the product screen', () async {
    await repository.create(tierPrice: band(), action: 'tierPrice.created');
    await repository.disable(id: 't1', action: 'tierPrice.disabled');

    final List<TierPrice> bands = (await repository.readForProduct(productId))
        .valueOrNull!;
    expect(bands, hasLength(1));
    expect(bands.single.isDisabled, isTrue);
    expect((await repository.readById('t1')).valueOrNull?.isDisabled, isTrue);
  });

  test(
    'the columns themselves refuse a duplicate written behind the repository',
    () async {
      await repository.create(tierPrice: band(), action: 'tierPrice.created');

      // Same product, same tier, same edge: the UNIQUE constraint is the last
      // line of defence, so even a writer that skips the check is stopped.
      await expectLater(
        database
            .into(database.priceTiers)
            .insert(
              PriceTiersCompanion.insert(
                id: 't2',
                productId: productId,
                tier: 'retail',
                priceMinorUnits: 1,
                createdAt: clock.nowUtc(),
              ),
            ),
        throwsA(anything),
      );
      expect(await rows(), hasLength(1));
    },
  );

  test('the shop currency is re-read, never cached', () async {
    await repository.create(tierPrice: band(), action: 'tierPrice.created');
    expect(
      (await repository.readById('t1')).valueOrNull?.price.currency,
      Currency.egp,
    );

    await settings.save(
      values: <String, String>{SettingKeys.currency: 'USD'},
      action: 'settings.updated',
    );

    final TierPrice read = (await repository.readById('t1')).valueOrNull!;
    expect(read.price.currency, Currency.usd);
    // The number itself never changed: only its currency did.
    expect(read.price.minorUnits, 1850);
  });

  test('a corrupted tier slug falls back to retail', () async {
    await repository.create(tierPrice: band(), action: 'tierPrice.created');
    // Written by something other than this app, so the row is asserted to be
    // readable rather than trusted.
    await (database.update(database.priceTiers)
          ..where(($PriceTiersTable table) => table.id.equals('t1')))
        .write(const PriceTiersCompanion(tier: Value<String>('mystery')));

    final TierPrice read = (await repository.readById('t1')).valueOrNull!;

    expect(read.tier, PriceTier.retail);
  });
}
