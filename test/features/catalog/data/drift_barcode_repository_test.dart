import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/features/catalog/data/drift_barcode_repository.dart';
import 'package:flow/features/catalog/domain/barcode.dart';
import 'package:flow/features/catalog/domain/barcode_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Covers `P2-03`: the label row, the two-layer uniqueness rule, and what a scan
/// is allowed to resolve.
void main() {
  const String productId = 'p1';
  const String otherProductId = 'p2';
  const String code = '5901234123457';

  late AppDatabase database;
  late AuditService audit;
  late FixedClock clock;
  late DriftBarcodeRepository repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory(setup: DatabasePragmas.apply));
    clock = FixedClock(DateTime.utc(2026, 5, 1));
    audit = AuditService(database: database, clock: clock);
    repository = DriftBarcodeRepository(
      database: database,
      unitOfWork: DriftUnitOfWork(database),
      auditService: audit,
      clock: clock,
    );
    // Labels only exist next to a product, so the fixtures build the smallest
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
    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            id: productId,
            name: 'Milk',
            type: 'simple',
            stockUnitCode: 'piece',
            salePriceMinorUnits: 1850,
            createdAt: clock.nowUtc(),
          ),
        );
    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            id: otherProductId,
            name: 'Bread',
            type: 'simple',
            stockUnitCode: 'piece',
            salePriceMinorUnits: 900,
            createdAt: clock.nowUtc(),
          ),
        );
  });

  tearDown(() => database.close());

  Barcode barcode({
    String id = 'b1',
    String code = code,
    String productId = productId,
    Quantity multiplier = Barcode.plainUnitMultiplier,
  }) => Barcode(
    id: id,
    code: code,
    productId: productId,
    multiplier: multiplier,
    createdAt: DateTime.utc(2026, 5, 1),
  );

  Future<List<AuditLogData>> entries() =>
      database.select(database.auditLog).get();

  Future<List<BarcodeRow>> rows() => database.select(database.barcodes).get();

  test('a product with no labels is empty', () async {
    final Result<List<Barcode>> result = await repository.readForProduct(
      productId,
    );

    expect(result.isOk, isTrue);
    expect(result.valueOrNull, isEmpty);
  });

  test('creating a label stores it and audits the write once', () async {
    final int baseline = (await entries()).length;

    final Result<Barcode> created = await repository.create(
      barcode: barcode(),
      action: 'barcode.created',
      payload: barcode().toAuditPayload(),
    );

    expect(created, isA<Ok<Barcode>>());
    final List<BarcodeRow> stored = await rows();
    expect(stored, hasLength(1));
    expect(stored.single.id, 'b1');
    expect(stored.single.code, code);
    expect(stored.single.productId, productId);
    expect(stored.single.multiplierThousandths, 1000);
    expect(stored.single.disabledAt, isNull);

    final List<AuditLogData> log = await entries();
    expect(log, hasLength(baseline + 1));
    expect(log.last.action, 'barcode.created');
    expect(log.last.entity, DriftBarcodeRepository.auditEntity);
    expect(log.last.entityId, 'b1');
    expect((await audit.verifyChain()).isIntact, isTrue);
  });

  test('a carton label keeps the number of units one scan means', () async {
    await repository.create(
      barcode: barcode(multiplier: const Quantity.thousandths(12000)),
      action: 'barcode.created',
    );

    expect((await rows()).single.multiplierThousandths, 12000);
    final Barcode read = (await repository.readByCode(code)).valueOrNull!;
    expect(read.multiplier, const Quantity.thousandths(12000));
  });

  test('one product carries many labels', () async {
    await repository.create(barcode: barcode(), action: 'barcode.created');
    await repository.create(
      barcode: barcode(id: 'b2', code: '5900000000000'),
      action: 'barcode.created',
    );

    final List<Barcode> labels = (await repository.readForProduct(productId))
        .valueOrNull!;

    expect(labels.map((Barcode label) => label.code).toList(), <String>[
      code,
      '5900000000000',
    ]);
  });

  test(
    'a code another product already owns is refused and links back',
    () async {
      await repository.create(barcode: barcode(), action: 'barcode.created');
      final int baseline = (await entries()).length;

      final Result<Barcode> refused = await repository.create(
        barcode: barcode(id: 'b2', productId: otherProductId),
        action: 'barcode.created',
      );

      expect(refused, isA<Err<Barcode>>());
      expect(refused.failureOrNull, isA<ConflictFailure>());
      expect(refused.failureOrNull?.code, BarcodeRepository.alreadyLinkedCode);
      // Nothing was written, and nothing was audited.
      expect(await rows(), hasLength(1));
      expect(await entries(), hasLength(baseline));

      // The caller resolves the conflict by looking the code up, which is what
      // lets the screen show the product that already owns it (FR-INV-011).
      final Barcode owner = (await repository.readByCode(code)).valueOrNull!;
      expect(owner.productId, productId);
    },
  );

  test('a label for a product that is gone is refused', () async {
    final int baseline = (await entries()).length;

    final Result<Barcode> refused = await repository.create(
      barcode: barcode(productId: 'missing'),
      action: 'barcode.created',
    );

    expect(refused.failureOrNull, isA<NotFoundFailure>());
    expect(refused.failureOrNull?.code, BarcodeRepository.productNotFoundCode);
    expect(await rows(), isEmpty);
    expect(await entries(), hasLength(baseline));
  });

  test('a scan resolves a live label', () async {
    await repository.create(barcode: barcode(), action: 'barcode.created');

    final Result<Barcode> found = await repository.readByCode(code);

    expect(found.isOk, isTrue);
    expect(found.valueOrNull?.id, 'b1');
  });

  test('a scan does not resolve an unknown code', () async {
    final Result<Barcode> found = await repository.readByCode('missing');

    expect(found.failureOrNull, isA<NotFoundFailure>());
    expect(found.failureOrNull?.code, BarcodeRepository.notFoundCode);
  });

  test('a scan does not resolve a retired label', () async {
    await repository.create(barcode: barcode(), action: 'barcode.created');
    await repository.disable(id: 'b1', action: 'barcode.disabled');

    final Result<Barcode> found = await repository.readByCode(code);

    expect(found, isA<Err<Barcode>>());
    expect(found.failureOrNull?.code, BarcodeRepository.notFoundCode);
  });

  test('the product view still sees a retired label', () async {
    await repository.create(barcode: barcode(), action: 'barcode.created');
    await repository.disable(id: 'b1', action: 'barcode.disabled');

    final List<Barcode> labels = (await repository.readForProduct(productId))
        .valueOrNull!;

    expect(labels, hasLength(1));
    expect(labels.single.isDisabled, isTrue);
  });

  test('a retired label is still readable by its id', () async {
    await repository.create(barcode: barcode(), action: 'barcode.created');
    await repository.disable(id: 'b1', action: 'barcode.disabled');

    final Barcode? read = (await repository.readById('b1')).valueOrNull;

    expect(read, isNotNull);
    expect(read?.isDisabled, isTrue);
  });

  test('reading a label that is not there reports not found', () async {
    final Result<Barcode> read = await repository.readById('missing');

    expect(read.failureOrNull, isA<NotFoundFailure>());
    expect(read.failureOrNull?.code, BarcodeRepository.notFoundCode);
  });

  test('disabling keeps the row, stamps the clock and audits it', () async {
    await repository.create(barcode: barcode(), action: 'barcode.created');
    clock.advance(const Duration(minutes: 5));

    final Result<void> disabled = await repository.disable(
      id: 'b1',
      action: 'barcode.disabled',
    );

    expect(disabled.isOk, isTrue);
    final BarcodeRow stored = (await rows()).single;
    expect(stored.disabledAt?.toUtc(), DateTime.utc(2026, 5, 1, 0, 5));
    expect(stored.code, code);
    expect((await entries()).last.action, 'barcode.disabled');
    expect((await audit.verifyChain()).isIntact, isTrue);
  });

  test('disabling twice succeeds and audits nothing the second time', () async {
    await repository.create(barcode: barcode(), action: 'barcode.created');
    await repository.disable(id: 'b1', action: 'barcode.disabled');
    final int baseline = (await entries()).length;

    final Result<void> again = await repository.disable(
      id: 'b1',
      action: 'barcode.disabled',
    );

    expect(again.isOk, isTrue);
    expect(await entries(), hasLength(baseline));
    expect((await rows()).single.disabledAt, isNotNull);
  });

  test('disabling a label that is not there reports not found', () async {
    final Result<void> result = await repository.disable(
      id: 'missing',
      action: 'barcode.disabled',
    );

    expect(result.failureOrNull, isA<NotFoundFailure>());
    expect(result.failureOrNull?.code, BarcodeRepository.notFoundCode);
  });

  test(
    'the column itself rejects a duplicate written behind the repository',
    () async {
      await repository.create(barcode: barcode(), action: 'barcode.created');

      await expectLater(
        database
            .into(database.barcodes)
            .insert(
              BarcodesCompanion.insert(
                id: 'b2',
                code: code,
                productId: otherProductId,
                createdAt: clock.nowUtc(),
              ),
            ),
        throwsA(anything),
      );
      expect(await rows(), hasLength(1));
    },
  );
}
