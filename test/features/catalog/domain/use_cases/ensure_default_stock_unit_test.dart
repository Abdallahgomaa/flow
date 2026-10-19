import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/features/catalog/domain/unit.dart';
import 'package:flow/features/catalog/domain/unit_repository.dart';
import 'package:flow/features/catalog/domain/use_cases/create_unit.dart';
import 'package:flow/features/catalog/domain/use_cases/ensure_default_stock_unit.dart';
import 'package:flow/features/catalog/domain/use_cases/load_units.dart';
import 'package:flutter_test/flutter_test.dart';

/// A [UnitRepository] that answers from memory, so the use case can be driven
/// through every branch without a database.
final class _FakeUnitRepository implements UnitRepository {
  List<Unit> units = <Unit>[];
  Failure? readFailure;
  Failure? createFailure;

  int createCalls = 0;
  Unit? created;
  String? createdAction;

  @override
  Future<Result<List<Unit>>> readAll() async => readFailure == null
      ? Result<List<Unit>>.ok(units)
      : Result<List<Unit>>.err(readFailure!);

  @override
  Future<Result<Unit>> readByCode(String code) async => const Result<Unit>.err(
    NotFoundFailure(
      message: 'No unit matches that code.',
      code: UnitRepository.notFoundCode,
    ),
  );

  @override
  Future<Result<Unit>> create({
    required Unit unit,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async {
    createCalls++;
    if (createFailure case final Failure failure) {
      return Result<Unit>.err(failure);
    }
    created = unit;
    createdAction = action;
    units = <Unit>[...units, unit];
    return Result<Unit>.ok(unit);
  }

  @override
  Future<Result<void>> disable({
    required String code,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async => const Result<void>.ok(null);
}

/// The default stock unit a fresh shop is provisioned with (`P2-06` follow-up).
///
/// The point of the use case is that it is *idempotent*: it may run on every
/// product-form open, and everything but the very first call must stay a pure
/// read. The tests therefore assert on `createCalls` as much as on the result.
void main() {
  final FixedClock clock = FixedClock(DateTime.utc(2026, 5, 1));
  late _FakeUnitRepository repository;

  EnsureDefaultStockUnit build() => EnsureDefaultStockUnit(
    LoadUnits(repository),
    CreateUnit(repository, clock),
  );

  setUp(() {
    repository = _FakeUnitRepository();
  });

  test('writes nothing when the shop already owns a unit', () async {
    repository.units = <Unit>[
      Unit(code: 'kg', name: 'Kilogram', createdAt: DateTime.utc(2026, 1, 1)),
    ];

    final Result<void> result = await build()();

    expect(result.isOk, isTrue);
    expect(repository.createCalls, 0);
  });

  test('creates one base unit when the catalogue is empty', () async {
    final Result<void> result = await build()();

    expect(result.isOk, isTrue);
    expect(repository.createCalls, 1);
    final Unit unit = repository.created!;
    // A base unit is its own reference point: no base, no factor.
    expect(unit.code, EnsureDefaultStockUnit.code);
    expect(unit.name, EnsureDefaultStockUnit.defaultName);
    expect(unit.baseUnitCode, isNull);
    expect(unit.factorThousandths, isNull);
    expect(unit.createdAt, clock.nowUtc());
    // The write is audited exactly like any other unit, through `CreateUnit`.
    expect(repository.createdAction, CreateUnit.auditAction);
  });

  test('treats a concurrent creation as success', () async {
    // Two form opens can race; the loser is told the code is taken, which means
    // the unit it wanted is there. That is not an error worth showing.
    repository.createFailure = const ConflictFailure(
      message: 'That code is already in use.',
      code: UnitRepository.codeTakenCode,
    );

    final Result<void> result = await build()();

    expect(result.isOk, isTrue);
  });

  test('propagates a read failure instead of creating anything', () async {
    repository.readFailure = const StorageFailure(
      message: 'Could not read the units.',
      code: 'unit.readFailed',
    );

    final Result<void> result = await build()();

    expect(result.failureOrNull?.code, 'unit.readFailed');
    expect(repository.createCalls, 0);
  });

  test('propagates a create failure the caller cannot recover from', () async {
    repository.createFailure = const StorageFailure(
      message: 'Could not create the unit.',
      code: 'unit.createFailed',
    );

    final Result<void> result = await build()();

    expect(result.failureOrNull?.code, 'unit.createFailed');
    expect(repository.createCalls, 1);
  });
}
