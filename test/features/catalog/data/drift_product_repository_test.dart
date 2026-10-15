// `isNull` is exported by both drift (an SQL expression) and flutter_test (a
// matcher); the tests mean the matcher, so drift's is hidden here.
import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/features/catalog/data/drift_product_repository.dart';
import 'package:flow/features/catalog/domain/product.dart';
import 'package:flow/features/catalog/domain/product_repository.dart';
import 'package:flow/features/catalog/domain/product_type.dart';
import 'package:flow/features/settings/data/drift_settings_repository.dart';
import 'package:flow/features/settings/domain/setting_keys.dart';
import 'package:flow/features/settings/domain/use_cases/load_business_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// Covers `P2-02`: the product row, its money, and the audit trail that has to
/// explain every price change.
void main() {
  const String productId = 'p1';
  const String categoryId = 'cat-1';
  const Money defaultPrice = Money.fromMinor(1850, Currency.egp);

  late AppDatabase database;
  late AuditService audit;
  late FixedClock clock;
  late DriftSettingsRepository settings;
  late DriftProductRepository repository;

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
    repository = DriftProductRepository(
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
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            id: categoryId,
            name: 'Drinks',
            createdAt: clock.nowUtc(),
          ),
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
        .into(database.units)
        .insert(
          UnitsCompanion.insert(
            code: 'carton',
            name: 'Carton',
            createdAt: clock.nowUtc(),
            baseUnitCode: const Value<String?>('piece'),
            factorThousandths: const Value<int?>(12000),
          ),
        );
  });

  tearDown(() => database.close());

  Product product({
    String id = productId,
    String name = 'Milk',
    ProductType type = ProductType.simple,
    String stockUnitCode = 'piece',
    String? categoryId,
    String? purchaseUnitCode,
    Money? salePrice,
    Money? costPrice,
    Quantity? reorderLevel,
    DateTime? disabledAt,
    DateTime? updatedAt,
  }) => Product(
    id: id,
    name: name,
    type: type,
    stockUnitCode: stockUnitCode,
    salePrice: salePrice ?? defaultPrice,
    createdAt: DateTime.utc(2026, 5, 1),
    categoryId: categoryId,
    purchaseUnitCode: purchaseUnitCode,
    costPrice: costPrice,
    reorderLevel: reorderLevel,
    disabledAt: disabledAt,
    updatedAt: updatedAt,
  );

  Future<List<AuditLogData>> entries() =>
      database.select(database.auditLog).get();

  Future<List<ProductRow>> rows() => database.select(database.products).get();

  test('an untouched catalogue is empty', () async {
    final Result<List<Product>> result = await repository.readAll();

    expect(result.isOk, isTrue);
    expect(result.valueOrNull, isEmpty);
  });

  test('creating a product stores it and audits the write once', () async {
    final int baseline = (await entries()).length;

    final Result<Product> created = await repository.create(
      product: product(),
      action: 'product.created',
      payload: product().toAuditPayload(),
    );

    expect(created, isA<Ok<Product>>());
    final List<ProductRow> stored = await rows();
    expect(stored, hasLength(1));
    expect(stored.single.id, productId);
    expect(stored.single.name, 'Milk');
    expect(stored.single.type, 'simple');
    expect(stored.single.stockUnitCode, 'piece');
    expect(stored.single.salePriceMinorUnits, 1850);
    expect(stored.single.costPriceMinorUnits, isNull);
    expect(stored.single.categoryId, isNull);
    expect(stored.single.purchaseUnitCode, isNull);

    final List<AuditLogData> log = await entries();
    expect(log, hasLength(baseline + 1));
    expect(log.last.action, 'product.created');
    expect(log.last.entity, DriftProductRepository.auditEntity);
    expect(log.last.entityId, productId);

    final AuditChainStatus status = await audit.verifyChain();
    expect(status.isIntact, isTrue);
  });

  test('a stored price is read back as money in the shop currency', () async {
    await repository.create(product: product(), action: 'product.created');

    final Result<Product> read = await repository.readById(productId);

    expect(read.isOk, isTrue);
    expect(read.valueOrNull?.salePrice, defaultPrice);
    expect(read.valueOrNull?.salePrice.currency, Currency.egp);
  });

  test(
    'a product keeps its category, purchase unit and reorder level',
    () async {
      await repository.create(
        product: product(
          categoryId: categoryId,
          purchaseUnitCode: 'carton',
          costPrice: const Money.fromMinor(900, Currency.egp),
          reorderLevel: const Quantity.thousandths(2500),
        ),
        action: 'product.created',
      );

      final ProductRow stored = (await rows()).single;
      expect(stored.categoryId, categoryId);
      expect(stored.purchaseUnitCode, 'carton');
      expect(stored.reorderLevelThousandths, 2500);

      final Product read = (await repository.readById(productId)).valueOrNull!;
      expect(read.categoryId, categoryId);
      expect(read.purchaseUnitCode, 'carton');
      expect(read.costPrice, const Money.fromMinor(900, Currency.egp));
      expect(read.reorderLevel, const Quantity.thousandths(2500));
    },
  );

  test('an unknown category is refused and writes nothing', () async {
    final int baseline = (await entries()).length;

    final Result<Product> result = await repository.create(
      product: product(categoryId: 'nope'),
      action: 'product.created',
    );

    expect(result, isA<Err<Product>>());
    expect(result.failureOrNull, isA<NotFoundFailure>());
    expect(result.failureOrNull?.code, ProductRepository.categoryNotFoundCode);
    expect(await rows(), isEmpty);
    expect(await entries(), hasLength(baseline));
  });

  test('an unknown stock unit is refused and writes nothing', () async {
    final int baseline = (await entries()).length;

    final Result<Product> result = await repository.create(
      product: product(stockUnitCode: 'nope'),
      action: 'product.created',
    );

    expect(result.failureOrNull?.code, ProductRepository.stockUnitNotFoundCode);
    expect(await rows(), isEmpty);
    expect(await entries(), hasLength(baseline));
  });

  test('an unknown purchase unit is refused and writes nothing', () async {
    final int baseline = (await entries()).length;

    final Result<Product> result = await repository.create(
      product: product(purchaseUnitCode: 'nope'),
      action: 'product.created',
    );

    expect(
      result.failureOrNull?.code,
      ProductRepository.purchaseUnitNotFoundCode,
    );
    expect(await rows(), isEmpty);
    expect(await entries(), hasLength(baseline));
  });

  test('readAll orders the catalogue by name', () async {
    await repository.create(
      product: product(id: 'p2', name: 'Zebra'),
      action: 'product.created',
    );
    await repository.create(
      product: product(id: 'p3', name: 'Apples'),
      action: 'product.created',
    );

    final List<Product> catalogue = (await repository.readAll()).valueOrNull!;

    expect(catalogue.map((Product item) => item.name).toList(), <String>[
      'Apples',
      'Zebra',
    ]);
  });

  test('reading a product that is not there reports not found', () async {
    final Result<Product> result = await repository.readById('missing');

    expect(result.failureOrNull, isA<NotFoundFailure>());
    expect(result.failureOrNull?.code, ProductRepository.notFoundCode);
  });

  test('a price change is recorded in the audit payload', () async {
    await repository.create(
      product: product(costPrice: const Money.fromMinor(900, Currency.egp)),
      action: 'product.created',
    );
    final Product previous = (await repository.readById(productId))
        .valueOrNull!;
    final Product edited = product(
      salePrice: const Money.fromMinor(2000, Currency.egp),
      costPrice: const Money.fromMinor(950, Currency.egp),
      updatedAt: clock.nowUtc(),
    );

    final Result<Product> updated = await repository.update(
      product: edited,
      action: 'product.updated',
      payload: <String, Object?>{
        ...edited.toAuditPayload(),
        ...edited.priceAuditPayload(previous: previous),
      },
    );

    expect(updated.isOk, isTrue);
    final Map<String, Object?> payload =
        jsonDecode((await entries()).last.payload) as Map<String, Object?>;
    expect(payload['salePriceMinorUnitsBefore'], 1850);
    expect(payload['salePriceMinorUnitsAfter'], 2000);
    expect(payload['costPriceMinorUnitsBefore'], 900);
    expect(payload['costPriceMinorUnitsAfter'], 950);

    final ProductRow stored = (await rows()).single;
    expect(stored.salePriceMinorUnits, 2000);
    expect(stored.costPriceMinorUnits, 950);
    expect(stored.updatedAt?.toUtc(), clock.nowUtc());
    expect((await audit.verifyChain()).isIntact, isTrue);
  });

  test('updating a product that is gone reports not found', () async {
    final Result<Product> result = await repository.update(
      product: product(),
      action: 'product.updated',
    );

    expect(result.failureOrNull, isA<NotFoundFailure>());
    expect(result.failureOrNull?.code, ProductRepository.notFoundCode);
  });

  test('disabling keeps the row, stamps the clock and audits it', () async {
    await repository.create(product: product(), action: 'product.created');
    clock.advance(const Duration(minutes: 5));

    final Result<void> disabled = await repository.disable(
      id: productId,
      action: 'product.disabled',
    );

    expect(disabled.isOk, isTrue);
    final ProductRow stored = (await rows()).single;
    expect(stored.disabledAt?.toUtc(), DateTime.utc(2026, 5, 1, 0, 5));
    expect(stored.name, 'Milk');
    expect((await entries()).last.action, 'product.disabled');
    expect((await audit.verifyChain()).isIntact, isTrue);
  });

  test('disabling twice succeeds and audits nothing the second time', () async {
    await repository.create(product: product(), action: 'product.created');
    await repository.disable(id: productId, action: 'product.disabled');
    final int baseline = (await entries()).length;

    final Result<void> again = await repository.disable(
      id: productId,
      action: 'product.disabled',
    );

    expect(again.isOk, isTrue);
    expect(await entries(), hasLength(baseline));
    expect((await rows()).single.disabledAt, isNotNull);
  });

  test('disabling a product that is not there reports not found', () async {
    final Result<void> result = await repository.disable(
      id: 'missing',
      action: 'product.disabled',
    );

    expect(result.failureOrNull, isA<NotFoundFailure>());
    expect(result.failureOrNull?.code, ProductRepository.notFoundCode);
  });

  test('the shop currency is re-read, never cached', () async {
    await repository.create(product: product(), action: 'product.created');
    expect(
      (await repository.readById(productId)).valueOrNull?.salePrice.currency,
      Currency.egp,
    );

    await settings.save(
      values: <String, String>{SettingKeys.currency: 'USD'},
      action: 'settings.updated',
    );

    final Product read = (await repository.readById(productId)).valueOrNull!;
    expect(read.salePrice.currency, Currency.usd);
    // The number itself never changed: only its currency did.
    expect(read.salePrice.minorUnits, 1850);
  });

  test('a corrupted type slug falls back to a simple product', () async {
    await repository.create(
      product: product(type: ProductType.bundle),
      action: 'product.created',
    );
    // Written by something other than this app, so the row is asserted to be
    // readable rather than trusted.
    await (database.update(database.products)
          ..where(($ProductsTable table) => table.id.equals(productId)))
        .write(const ProductsCompanion(type: Value<String>('mystery')));

    final Product read = (await repository.readById(productId)).valueOrNull!;

    expect(read.type, ProductType.simple);
  });
}
