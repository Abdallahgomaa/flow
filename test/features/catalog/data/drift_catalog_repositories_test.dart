// `isNull` is exported by both drift (an SQL expression) and flutter_test (a
// matcher); the tests mean the matcher, so drift's is hidden here.
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/features/catalog/data/drift_category_repository.dart';
import 'package:flow/features/catalog/data/drift_unit_repository.dart';
import 'package:flow/features/catalog/domain/category.dart';
import 'package:flow/features/catalog/domain/category_repository.dart';
import 'package:flow/features/catalog/domain/unit.dart';
import 'package:flow/features/catalog/domain/unit_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// The catalog repositories against a real (in-memory) Drift database, so the
/// schema, the foreign keys, the audit transaction and the read ordering are all
/// exercised rather than mocked (`P2-01`).
void main() {
  late AppDatabase database;
  late AuditService audit;
  late FixedClock clock;
  late DriftCategoryRepository categories;
  late DriftUnitRepository units;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory(setup: DatabasePragmas.apply));
    clock = FixedClock(DateTime.utc(2026, 5, 1));
    audit = AuditService(database: database, clock: clock);
    final DriftUnitOfWork unitOfWork = DriftUnitOfWork(database);
    categories = DriftCategoryRepository(
      database: database,
      unitOfWork: unitOfWork,
      auditService: audit,
      clock: clock,
    );
    units = DriftUnitRepository(
      database: database,
      unitOfWork: unitOfWork,
      auditService: audit,
      clock: clock,
    );
  });

  tearDown(() => database.close());

  Category category(
    String id, {
    String? parentId,
    String? name,
    int sortOrder = 0,
  }) => Category(
    id: id,
    name: name ?? id,
    createdAt: clock.nowUtc(),
    parentId: parentId,
    sortOrder: sortOrder,
  );

  Unit unit(
    String code, {
    String? name,
    String? baseUnitCode,
    int? factorThousandths,
  }) => Unit(
    code: code,
    name: name ?? code,
    createdAt: clock.nowUtc(),
    baseUnitCode: baseUnitCode,
    factorThousandths: factorThousandths,
  );

  Future<List<AuditLogData>> entries() =>
      database.select(database.auditLog).get();

  group('DriftCategoryRepository', () {
    test('an untouched store reads back empty', () async {
      expect((await categories.readAll()).valueOrNull, isEmpty);
    });

    test('create persists the row, audits once and keeps the chain', () async {
      final Result<Category> created = await categories.create(
        category: category('food', name: 'Food'),
        action: 'category.created',
      );

      expect(created, isA<Ok<Category>>());

      final Result<Category> found = await categories.readById('food');
      expect(found.valueOrNull?.name, 'Food');
      expect(found.valueOrNull?.isRoot, isTrue);

      final List<AuditLogData> log = await entries();
      expect(log, hasLength(1));
      expect(log.single.entity, DriftCategoryRepository.auditEntity);
      expect(log.single.entityId, 'food');
      expect((await audit.verifyChain()).isIntact, isTrue);
    });

    test('a nested category keeps its parent', () async {
      await categories.create(
        category: category('food'),
        action: 'category.created',
      );
      await categories.create(
        category: category('rice', parentId: 'food'),
        action: 'category.created',
      );

      final Result<Category> found = await categories.readById('rice');

      expect(found.valueOrNull?.parentId, 'food');
      expect((await categories.readAll()).valueOrNull, hasLength(2));
    });

    test('an unknown parent is refused and writes nothing', () async {
      final Result<Category> created = await categories.create(
        category: category('rice', parentId: 'ghost'),
        action: 'category.created',
      );

      expect(created.failureOrNull, isA<NotFoundFailure>());
      expect(
        created.failureOrNull?.code,
        CategoryRepository.parentNotFoundCode,
      );
      // The refusal rolled back atomically: no row, no audit entry.
      expect(await database.select(database.categories).get(), isEmpty);
      expect(await entries(), isEmpty);
    });

    test('readAll orders by sort order and then by name', () async {
      await categories.create(
        category: category('c', name: 'Zebra', sortOrder: 2),
        action: 'category.created',
      );
      await categories.create(
        category: category('a', name: 'Milk', sortOrder: 1),
        action: 'category.created',
      );
      await categories.create(
        category: category('b', name: 'Apples', sortOrder: 1),
        action: 'category.created',
      );

      final List<String> ids = (await categories.readAll()).valueOrNull!
          .map((Category row) => row.id)
          .toList();

      expect(ids, <String>['b', 'a', 'c']);
    });

    test('readById reports not-found for an unknown id', () async {
      final Result<Category> found = await categories.readById('ghost');

      expect(found.failureOrNull?.code, CategoryRepository.notFoundCode);
    });

    test('disable keeps the row, stamps the clock and audits', () async {
      await categories.create(
        category: category('food'),
        action: 'category.created',
      );
      clock.advance(const Duration(minutes: 5));

      final Result<void> disabled = await categories.disable(
        id: 'food',
        action: 'category.disabled',
      );

      expect(disabled, isA<Ok<void>>());

      // Logically retired, never deleted.
      final List<CategoryRow> rows = await database
          .select(database.categories)
          .get();
      expect(rows, hasLength(1));
      expect(rows.single.disabledAt?.toUtc(), DateTime.utc(2026, 5, 1, 0, 5));

      final List<AuditLogData> log = await entries();
      expect(log, hasLength(2));
      expect(log.last.action, 'category.disabled');
      expect((await audit.verifyChain()).isIntact, isTrue);
    });

    test('a category with children cannot be disabled', () async {
      await categories.create(
        category: category('food'),
        action: 'category.created',
      );
      await categories.create(
        category: category('rice', parentId: 'food'),
        action: 'category.created',
      );

      final Result<void> disabled = await categories.disable(
        id: 'food',
        action: 'category.disabled',
      );

      expect(disabled.failureOrNull, isA<ConflictFailure>());
      expect(disabled.failureOrNull?.code, CategoryRepository.hasChildrenCode);

      final List<CategoryRow> rows = await database
          .select(database.categories)
          .get();
      expect(
        rows.firstWhere((CategoryRow row) => row.id == 'food').disabledAt,
        isNull,
      );
    });

    test('disabling an already disabled category changes nothing', () async {
      await categories.create(
        category: category('food'),
        action: 'category.created',
      );
      await categories.disable(id: 'food', action: 'category.disabled');

      final Result<void> again = await categories.disable(
        id: 'food',
        action: 'category.disabled',
      );

      expect(again, isA<Ok<void>>());
      expect(await entries(), hasLength(2));
    });

    test('disabling an unknown category reports not-found', () async {
      final Result<void> disabled = await categories.disable(
        id: 'ghost',
        action: 'category.disabled',
      );

      expect(disabled.failureOrNull?.code, CategoryRepository.notFoundCode);
    });
  });

  group('DriftUnitRepository', () {
    test('an untouched store reads back empty', () async {
      expect((await units.readAll()).valueOrNull, isEmpty);
    });

    test('create stores a base unit and audits once', () async {
      final Result<Unit> created = await units.create(
        unit: unit('piece', name: 'Piece'),
        action: 'unit.created',
      );

      expect(created, isA<Ok<Unit>>());

      final Result<Unit> found = await units.readByCode('piece');
      expect(found.valueOrNull?.isBase, isTrue);
      expect(found.valueOrNull?.factor, isNull);

      final List<AuditLogData> log = await entries();
      expect(log, hasLength(1));
      expect(log.single.entity, DriftUnitRepository.auditEntity);
      expect(log.single.entityId, 'piece');
      expect((await audit.verifyChain()).isIntact, isTrue);
    });

    test('create stores a derived unit with its factor', () async {
      await units.create(
        unit: unit('piece', name: 'Piece'),
        action: 'unit.created',
      );

      final Result<Unit> created = await units.create(
        unit: unit(
          'carton',
          name: 'Carton',
          baseUnitCode: 'piece',
          factorThousandths: 12000,
        ),
        action: 'unit.created',
      );

      expect(created, isA<Ok<Unit>>());

      final Result<Unit> found = await units.readByCode('carton');
      expect(found.valueOrNull?.isBase, isFalse);
      expect(found.valueOrNull?.factor?.thousandths, 12000);
      expect((await units.readAll()).valueOrNull, hasLength(2));
    });

    test('a duplicate code is refused and writes nothing', () async {
      await units.create(
        unit: unit('piece', name: 'Piece'),
        action: 'unit.created',
      );

      final Result<Unit> duplicate = await units.create(
        unit: unit('piece', name: 'Piece'),
        action: 'unit.created',
      );

      expect(duplicate.failureOrNull, isA<ConflictFailure>());
      expect(duplicate.failureOrNull?.code, UnitRepository.codeTakenCode);
      expect(await database.select(database.units).get(), hasLength(1));
      expect(await entries(), hasLength(1));
    });

    test('an unknown base unit is refused', () async {
      final Result<Unit> created = await units.create(
        unit: unit('carton', baseUnitCode: 'ghost', factorThousandths: 12000),
        action: 'unit.created',
      );

      expect(created.failureOrNull, isA<NotFoundFailure>());
      expect(created.failureOrNull?.code, UnitRepository.baseNotFoundCode);
      expect(await database.select(database.units).get(), isEmpty);
    });

    test('readAll orders by display name', () async {
      await units.create(
        unit: unit('c', name: 'Zebra'),
        action: 'unit.created',
      );
      await units.create(
        unit: unit('a', name: 'Apple'),
        action: 'unit.created',
      );

      final List<String> codes = (await units.readAll()).valueOrNull!
          .map((Unit row) => row.code)
          .toList();

      expect(codes, <String>['a', 'c']);
    });

    test('readByCode reports not-found for an unknown code', () async {
      final Result<Unit> found = await units.readByCode('ghost');

      expect(found.failureOrNull?.code, UnitRepository.notFoundCode);
    });

    test('a stored catalogue that already loops is refused, not followed forever', () async {
      // `create` cannot build a loop, so the row is corrupted directly, the way
      // a bad import or a manual edit would leave it.
      await units.create(
        unit: unit('piece', name: 'Piece'),
        action: 'unit.created',
      );
      await units.create(
        unit: unit(
          'carton',
          name: 'Carton',
          baseUnitCode: 'piece',
          factorThousandths: 12000,
        ),
        action: 'unit.created',
      );
      await (database.update(
        database.units,
      )..where(($UnitsTable table) => table.code.equals('piece'))).write(
        const UnitsCompanion(
          baseUnitCode: Value<String?>('carton'),
          factorThousandths: Value<int?>(1000),
        ),
      );

      final Result<Unit> created = await units.create(
        unit: unit(
          'crate',
          name: 'Crate',
          baseUnitCode: 'piece',
          factorThousandths: 1000,
        ),
        action: 'unit.created',
      );

      expect(created.failureOrNull, isA<ConflictFailure>());
      expect(created.failureOrNull?.code, UnitRepository.cycleCode);
    });

    test('disable keeps the row, stamps the clock and audits', () async {
      await units.create(
        unit: unit('piece', name: 'Piece'),
        action: 'unit.created',
      );
      clock.advance(const Duration(minutes: 5));

      final Result<void> disabled = await units.disable(
        code: 'piece',
        action: 'unit.disabled',
      );

      expect(disabled, isA<Ok<void>>());

      final List<UnitRow> rows = await database.select(database.units).get();
      expect(rows, hasLength(1));
      expect(rows.single.disabledAt?.toUtc(), DateTime.utc(2026, 5, 1, 0, 5));

      expect((await entries()).last.action, 'unit.disabled');
    });

    test('disabling an already disabled unit changes nothing', () async {
      await units.create(
        unit: unit('piece', name: 'Piece'),
        action: 'unit.created',
      );
      await units.disable(code: 'piece', action: 'unit.disabled');

      final Result<void> again = await units.disable(
        code: 'piece',
        action: 'unit.disabled',
      );

      expect(again, isA<Ok<void>>());
      expect(await entries(), hasLength(2));
    });

    test('disabling an unknown unit reports not-found', () async {
      final Result<void> disabled = await units.disable(
        code: 'ghost',
        action: 'unit.disabled',
      );

      expect(disabled.failureOrNull?.code, UnitRepository.notFoundCode);
    });
  });
}
