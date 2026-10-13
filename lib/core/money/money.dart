import '../result/failure.dart';
import '../result/result.dart';
import 'currency.dart';
import 'rate.dart';
import 'rounding_mode.dart';

/// An exact monetary amount, stored as an integer number of **minor units**
/// (for example piastres for `EGP`).
///
/// ## Why integers
/// Floating point cannot represent `0.10` exactly, so money is never a
/// `double`. The whole application stores money as `int` minor units and only
/// converts to text through `MoneyFormatter`.
///
/// ## Platform note
/// Flow targets native platforms where `int` is a 64-bit signed integer
/// (≈ ±9.2·10^18 minor units). The web platform is explicitly unsupported.
///
/// ## Errors
/// Operands with different currencies are a programming mistake, not a business
/// failure, so the mismatch throws [ArgumentError] rather than returning a
/// [Failure].
final class Money implements Comparable<Money> {
  /// Creates an amount of [minorUnits] in [currency].
  const Money.fromMinor(this.minorUnits, this.currency);

  /// Zero in [currency].
  const Money.zero(this.currency) : minorUnits = 0;

  /// Parses a decimal string such as `'12'`, `'12.5'`, `'12.50'` or
  /// `'-0.05'` into a [Money] in [currency].
  ///
  /// Thousand separators, letters and more decimals than the currency allows
  /// are rejected with a [ValidationFailure].
  static Result<Money> parse(String input, Currency currency) {
    final String trimmed = input.trim();
    final bool negative = trimmed.startsWith('-');
    final String unsigned = negative ? trimmed.substring(1) : trimmed;
    final List<String> parts = unsigned.split('.');

    if (unsigned.isEmpty || parts.length > 2) {
      return _invalid(input);
    }

    final String wholeRaw = parts[0];
    final String fraction = parts.length == 2 ? parts[1] : '';
    if (wholeRaw.isEmpty && fraction.isEmpty) {
      return _invalid(input);
    }
    final String whole = wholeRaw.isEmpty ? '0' : wholeRaw;
    if (!_onlyDigits(whole) ||
        (fraction.isNotEmpty && !_onlyDigits(fraction)) ||
        fraction.length > currency.minorDigits) {
      return _invalid(input);
    }

    final String padded = fraction.padRight(currency.minorDigits, '0');
    final int factor = _pow10(currency.minorDigits);
    final int magnitude =
        int.parse(whole) * factor + (padded.isEmpty ? 0 : int.parse(padded));

    return Result<Money>.ok(
      Money.fromMinor(negative ? -magnitude : magnitude, currency),
    );
  }

  /// The amount in minor units (e.g. `1234` == `12.34`).
  final int minorUnits;

  /// The currency of the amount.
  final Currency currency;

  /// `true` when the amount is exactly zero.
  bool get isZero => minorUnits == 0;

  /// `true` when the amount is negative.
  bool get isNegative => minorUnits < 0;

  /// `true` when the amount is strictly positive.
  bool get isPositive => minorUnits > 0;

  /// This amount with the opposite sign.
  Money get negated => Money.fromMinor(-minorUnits, currency);

  /// The absolute amount.
  Money abs() => Money.fromMinor(minorUnits.abs(), currency);

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money.fromMinor(minorUnits + other.minorUnits, currency);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money.fromMinor(minorUnits - other.minorUnits, currency);
  }

  /// Unary negation.
  Money operator -() => negated;

  /// Multiplies by an integer count (never a fraction).
  Money operator *(int factor) =>
      Money.fromMinor(minorUnits * factor, currency);

  /// Applies [rate] to this amount (e.g. a tax rate or a discount).
  Money applyRate(Rate rate, {RoundingMode mode = RoundingMode.halfUp}) =>
      multiplyRatio(rate.basisPoints, 10000, mode: mode);

  /// Multiplies by the ratio `numerator / denominator` with explicit rounding.
  ///
  /// This is the only place where a division is allowed inside [Money]; it uses
  /// [BigInt] internally so no overflow or precision is lost. [denominator]
  /// must be strictly positive.
  Money multiplyRatio(
    int numerator,
    int denominator, {
    RoundingMode mode = RoundingMode.halfUp,
  }) {
    if (denominator <= 0) {
      throw ArgumentError.value(
        denominator,
        'denominator',
        'must be greater than zero',
      );
    }
    final BigInt product = BigInt.from(minorUnits) * BigInt.from(numerator);
    final BigInt rounded = Rounding.divide(
      product,
      BigInt.from(denominator),
      mode,
    );
    return Money.fromMinor(rounded.toInt(), currency);
  }

  /// Splits this amount into parts proportional to [ratios] using the
  /// largest-remainder method, guaranteeing `parts.sum() == this` exactly.
  ///
  /// [ratios] must be non-empty, non-negative and not all zero.
  List<Money> allocate(List<int> ratios) {
    if (ratios.isEmpty) {
      throw ArgumentError.value(ratios, 'ratios', 'must not be empty');
    }
    int total = 0;
    for (final int ratio in ratios) {
      if (ratio < 0) {
        throw ArgumentError.value(ratio, 'ratios', 'must be non-negative');
      }
      total += ratio;
    }
    if (total == 0) {
      throw ArgumentError.value(ratios, 'ratios', 'must not be all zero');
    }

    final BigInt denominator = BigInt.from(total);
    final List<Money> parts = <Money>[];
    final List<({int index, int remainder})> remainders =
        <({int index, int remainder})>[];
    int allocated = 0;

    for (int i = 0; i < ratios.length; i++) {
      final BigInt share = BigInt.from(minorUnits) * BigInt.from(ratios[i]);
      final int whole = (share ~/ denominator).toInt();
      parts.add(Money.fromMinor(whole, currency));
      allocated += whole;
      remainders.add((
        index: i,
        remainder: (share % denominator).abs().toInt(),
      ));
    }

    // Deterministic ordering: biggest remainder first, then original index.
    remainders.sort((a, b) {
      final int byRemainder = b.remainder.compareTo(a.remainder);
      return byRemainder != 0 ? byRemainder : a.index.compareTo(b.index);
    });

    final int leftover = minorUnits - allocated;
    final int step = leftover.isNegative ? -1 : 1;
    for (int i = 0; i < leftover.abs(); i++) {
      final int index = remainders[i % remainders.length].index;
      parts[index] = Money.fromMinor(parts[index].minorUnits + step, currency);
    }

    return parts;
  }

  /// Canonical decimal text for storage/export: a dot decimal separator, no
  /// thousand separators (e.g. `'12.50'`, `'-0.05'`, `'1234'` for JPY).
  String toDecimalString() {
    final int factor = _pow10(currency.minorDigits);
    final int abs = minorUnits.abs();
    final int whole = abs ~/ factor;
    final int fraction = abs % factor;
    final String sign = isNegative ? '-' : '';
    if (currency.minorDigits == 0) {
      return '$sign$whole';
    }
    return '$sign$whole.${fraction.toString().padLeft(currency.minorDigits, '0')}';
  }

  @override
  int compareTo(Money other) {
    _assertSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  bool operator <(Money other) => compareTo(other) < 0;

  bool operator <=(Money other) => compareTo(other) <= 0;

  bool operator >(Money other) => compareTo(other) > 0;

  bool operator >=(Money other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.minorUnits == minorUnits &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);

  @override
  String toString() => '${toDecimalString()} ${currency.code}';

  void _assertSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError(
        'Currency mismatch: ${currency.code} vs ${other.currency.code}',
      );
    }
  }

  static Result<Money> _invalid(String input) =>
      Result<Money>.err(ValidationFailure(message: 'Invalid amount: "$input"'));

  static bool _onlyDigits(String value) {
    if (value.isEmpty) {
      return false;
    }
    for (final int unit in value.codeUnits) {
      if (unit < 0x30 || unit > 0x39) {
        return false;
      }
    }
    return true;
  }

  static int _pow10(int exponent) {
    int result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }
}
