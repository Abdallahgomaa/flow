/// Strategy applied when a monetary computation is not exact.
///
/// Every rounding decision in the app funnels through [Rounding.divide] so the
/// behaviour is identical everywhere (tax, allocations, ratios).
enum RoundingMode {
  /// Round half away from zero (commercial rounding). The app default.
  halfUp,

  /// Round half to even ("banker's rounding"), to avoid statistical bias.
  halfEven,

  /// Truncate towards zero.
  down,

  /// Round away from zero.
  up,
}

/// Integer division with explicit, deterministic rounding.
abstract final class Rounding {
  const Rounding._();

  /// Divides [numerator] by [denominator] and rounds per [mode].
  ///
  /// [denominator] must be strictly positive; [numerator] may be negative, in
  /// which case the result follows the sign of [numerator] (symmetric
  /// rounding around zero).
  static BigInt divide(
    BigInt numerator,
    BigInt denominator,
    RoundingMode mode,
  ) {
    if (denominator <= BigInt.zero) {
      throw ArgumentError.value(
        denominator,
        'denominator',
        'must be greater than zero',
      );
    }

    final bool negative = numerator.isNegative;
    final BigInt absNumerator = numerator.abs();
    final BigInt quotient = absNumerator ~/ denominator;
    final BigInt remainder = absNumerator % denominator;

    final BigInt magnitude = switch (mode) {
      RoundingMode.down => quotient,
      RoundingMode.up =>
        remainder == BigInt.zero ? quotient : quotient + BigInt.one,
      RoundingMode.halfUp =>
        (remainder * BigInt.two) >= denominator
            ? quotient + BigInt.one
            : quotient,
      RoundingMode.halfEven => _halfEven(quotient, remainder, denominator),
    };

    return negative ? -magnitude : magnitude;
  }

  static BigInt _halfEven(
    BigInt quotient,
    BigInt remainder,
    BigInt denominator,
  ) {
    final BigInt twice = remainder * BigInt.two;
    if (twice > denominator) {
      return quotient + BigInt.one;
    }
    if (twice < denominator) {
      return quotient;
    }
    // Exactly halfway: keep the even neighbour.
    return quotient.isEven ? quotient : quotient + BigInt.one;
  }
}
