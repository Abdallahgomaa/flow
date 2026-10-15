import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/features/catalog/domain/unit.dart';
import 'package:flow/features/catalog/domain/unit_converter.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit conversion is pure arithmetic, so these tests need no database: the
/// catalogue is just a list of [Unit] rows (`P2-01`).
void main() {
  final DateTime createdAt = DateTime.utc(2026, 5, 1);

  Unit baseUnit(String code) =>
      Unit(code: code, name: code, createdAt: createdAt);

  Unit derivedUnit(
    String code, {
    required String baseUnitCode,
    required int factorThousandths,
    DateTime? disabledAt,
  }) => Unit(
    code: code,
    name: code,
    createdAt: createdAt,
    baseUnitCode: baseUnitCode,
    factorThousandths: factorThousandths,
    disabledAt: disabledAt,
  );

  /// The shop the acceptance criterion describes: a carton holds twelve pieces
  /// and a box holds six cartons.
  final List<Unit> shop = <Unit>[
    baseUnit('piece'),
    derivedUnit('carton', baseUnitCode: 'piece', factorThousandths: 12000),
    derivedUnit('box', baseUnitCode: 'carton', factorThousandths: 6000),
  ];

  Result<Quantity> convert(String from, String to, [Quantity? amount]) =>
      UnitConverter.convert(
        amount: amount ?? Quantity.units(1),
        fromCode: from,
        toCode: to,
        catalogue: shop,
      );

  test('the acceptance case: one carton is twelve pieces', () {
    final Result<Quantity> result = convert('carton', 'piece');

    expect(result.valueOrNull, Quantity.units(12));
  });

  test('two cartons are twenty-four pieces', () {
    final Result<Quantity> result = convert(
      'carton',
      'piece',
      Quantity.units(2),
    );

    expect(result.valueOrNull, Quantity.units(24));
  });

  test('a chain multiplies as it walks up to the base unit', () {
    // One box is six cartons of twelve pieces each: seventy-two pieces.
    final Result<Quantity> result = convert('box', 'piece');

    expect(result.valueOrNull, Quantity.units(72));
  });

  test('converting towards the larger unit divides', () {
    final Result<Quantity> result = convert(
      'piece',
      'carton',
      Quantity.units(24),
    );

    expect(result.valueOrNull, Quantity.units(2));
  });

  test('rounding half up is applied once, at three decimals', () {
    // One piece is 1/72 of a box: 13.888… thousandths, which rounds to 14.
    final Result<Quantity> result = convert('piece', 'box');

    expect(result.valueOrNull, const Quantity.thousandths(14));
  });

  test('converting a unit into itself returns the same amount', () {
    final Result<Quantity> result = convert(
      'carton',
      'carton',
      Quantity.units(3),
    );

    expect(result.valueOrNull, Quantity.units(3));
  });

  test('an unknown source unit is rejected', () {
    final Result<Quantity> result = convert('ghost', 'piece');

    expect(result.failureOrNull, isA<ValidationFailure>());
    expect(result.failureOrNull?.code, UnitConverter.unknownUnitCode);
  });

  test('an unknown target unit is rejected', () {
    final Result<Quantity> result = convert('piece', 'ghost');

    expect(result.failureOrNull?.code, UnitConverter.unknownUnitCode);
  });

  test('a derived unit without a factor is rejected', () {
    final List<Unit> broken = <Unit>[
      baseUnit('piece'),
      Unit(
        code: 'crate',
        name: 'crate',
        createdAt: createdAt,
        baseUnitCode: 'piece',
      ),
    ];

    final Result<Quantity> result = UnitConverter.convert(
      amount: Quantity.units(1),
      fromCode: 'crate',
      toCode: 'piece',
      catalogue: broken,
    );

    expect(result.failureOrNull?.code, UnitConverter.factorMissingCode);
  });

  test('a loop in the catalogue is rejected instead of hanging', () {
    final List<Unit> loop = <Unit>[
      derivedUnit('a', baseUnitCode: 'b', factorThousandths: 1000),
      derivedUnit('b', baseUnitCode: 'a', factorThousandths: 1000),
    ];

    final Result<Quantity> result = UnitConverter.convert(
      amount: Quantity.units(1),
      fromCode: 'a',
      toCode: 'b',
      catalogue: loop,
    );

    expect(result.failureOrNull?.code, UnitConverter.cycleCode);
  });

  test('a disabled unit still converts, so old documents recalculate', () {
    final List<Unit> retired = <Unit>[
      baseUnit('piece'),
      derivedUnit(
        'carton',
        baseUnitCode: 'piece',
        factorThousandths: 12000,
        disabledAt: DateTime.utc(2026, 6, 1),
      ),
    ];

    final Result<Quantity> result = UnitConverter.convert(
      amount: Quantity.units(1),
      fromCode: 'carton',
      toCode: 'piece',
      catalogue: retired,
    );

    expect(result.valueOrNull, Quantity.units(12));
  });
}
