/// Converts quantities between the units of one catalogue (`P2-01`).
///
/// A conversion is resolved by walking the `baseUnitCode` chain up to the root
/// base unit and multiplying the factors along the way, so `carton → box →
/// piece` works without anyone having to enumerate every pair. Every step is
/// integer maths: factors are thousandths, and the single division is delegated
/// to [Quantity.multiplyRatio], which rounds explicitly.
library;

import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';

import 'unit.dart';

/// Pure, unit-to-unit conversion over a supplied catalogue.
///
/// The converter is a value service: it takes the units it should reason about
/// and never touches a database, so the conversion rules are testable on their
/// own. Availability (disabled units) and permissions are the caller's business.
abstract final class UnitConverter {
  const UnitConverter._();

  /// Failure code returned when a requested unit is not in the catalogue.
  static const String unknownUnitCode = 'unit.unknown';

  /// Failure code returned when the chain of base units forms a loop.
  static const String cycleCode = 'unit.cycle';

  /// Failure code returned when a non-base unit carries no factor.
  static const String factorMissingCode = 'unit.factorMissing';

  /// Converts [amount] from [fromCode] to [toCode] using [catalogue].
  ///
  /// Returns the converted quantity, rounded half up when the conversion is not
  /// exact, or a [ValidationFailure] naming the problem via its code.
  static Result<Quantity> convert({
    required Quantity amount,
    required String fromCode,
    required String toCode,
    required List<Unit> catalogue,
  }) {
    final Map<String, Unit> byCode = <String, Unit>{
      for (final Unit unit in catalogue) unit.code: unit,
    };

    final Unit? from = byCode[fromCode];
    if (from == null) {
      return Result<Quantity>.err(_unknown(fromCode));
    }
    final Unit? to = byCode[toCode];
    if (to == null) {
      return Result<Quantity>.err(_unknown(toCode));
    }
    if (fromCode == toCode) {
      return Result<Quantity>.ok(amount);
    }

    final Result<Quantity> fromMultiplier = _multiplierOf(from, byCode);
    if (fromMultiplier.isErr) {
      return fromMultiplier;
    }
    final Result<Quantity> toMultiplier = _multiplierOf(to, byCode);
    if (toMultiplier.isErr) {
      return toMultiplier;
    }

    return Result<Quantity>.ok(
      amount.multiplyRatio(
        fromMultiplier.valueOrNull!.thousandths,
        toMultiplier.valueOrNull!.thousandths,
      ),
    );
  }

  /// How much one [unit] is worth, expressed in thousandths of its root base
  /// unit; a base unit is worth `1.000` of itself.
  static Result<Quantity> _multiplierOf(Unit unit, Map<String, Unit> byCode) {
    final Set<String> visited = <String>{};
    Quantity multiplier = Quantity.units(1);
    Unit current = unit;
    while (!current.isBase) {
      if (!visited.add(current.code)) {
        return const Result<Quantity>.err(
          ValidationFailure(
            message: 'The units of measure form a loop.',
            code: cycleCode,
          ),
        );
      }
      // `isBase` is false here, so the chain is known to continue.
      final String baseUnitCode = current.baseUnitCode!;
      final Unit? base = byCode[baseUnitCode];
      if (base == null) {
        return Result<Quantity>.err(_unknown(baseUnitCode));
      }
      final int? factor = current.factorThousandths;
      if (factor == null) {
        return Result<Quantity>.err(_factorMissing(current.code));
      }
      multiplier = multiplier.multiplyRatio(factor, 1000);
      current = base;
    }
    return Result<Quantity>.ok(multiplier);
  }

  /// The failure raised when [code] is not part of the catalogue, at either end
  /// of a conversion or inside the chain that links the two.
  static ValidationFailure _unknown(String code) => ValidationFailure(
    message: 'There is no unit with the code "$code".',
    code: unknownUnitCode,
  );

  /// The failure raised when a non-base unit has no factor to walk with.
  static ValidationFailure _factorMissing(String code) => ValidationFailure(
    message: 'The unit "$code" has no conversion factor.',
    code: factorMissingCode,
  );
}
