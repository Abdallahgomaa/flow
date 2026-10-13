import '../result/failure.dart';
import '../result/result.dart';
import 'money.dart';
import 'rounding_mode.dart';

/// An exact, unit-agnostic quantity stored as an integer number of
/// *thousandths* (e.g. `750` == `0.750`).
///
/// Quantities never use `double`, matching the binding project rule that all
/// money and quantity maths is integer-based.
final class Quantity implements Comparable<Quantity> {
  /// Creates a quantity from its raw [thousandths] value.
  const Quantity.thousandths(this.thousandths);

  /// Creates a quantity of [units] whole items (e.g. `3` == `3.000`).
  factory Quantity.units(int units) => Quantity.thousandths(units * 1000);

  /// Parses a decimal string such as `'2'`, `'0.750'` or `'-1.5'`.
  ///
  /// Accepts at most three decimal places and rejects thousand separators,
  /// letters and malformed input with a [ValidationFailure].
  static Result<Quantity> parse(String input) {
    final String trimmed = input.trim();
    if (trimmed.isEmpty) {
      return _invalid(input);
    }
    final bool negative = trimmed.startsWith('-');
    final String unsigned = negative ? trimmed.substring(1) : trimmed;
    if (unsigned.isEmpty) {
      return _invalid(input);
    }
    final List<String> parts = unsigned.split('.');
    if (parts.length > 2) {
      return _invalid(input);
    }
    final String wholeRaw = parts[0];
    final String fractionRaw = parts.length == 2 ? parts[1] : '';
    if (wholeRaw.isEmpty && fractionRaw.isEmpty) {
      return _invalid(input);
    }
    final String whole = wholeRaw.isEmpty ? '0' : wholeRaw;
    if (!_onlyDigits(whole) ||
        (fractionRaw.isNotEmpty && !_onlyDigits(fractionRaw))) {
      return _invalid(input);
    }
    if (fractionRaw.length > 3) {
      return _invalid(input);
    }
    final int wholeValue = int.parse(whole);
    final String padded = fractionRaw.padRight(3, '0');
    final int fractionValue = padded.isEmpty ? 0 : int.parse(padded);
    final int magnitude = wholeValue * 1000 + fractionValue;
    return Result<Quantity>.ok(
      Quantity.thousandths(negative ? -magnitude : magnitude),
    );
  }

  /// The quantity in thousandths of a unit.
  final int thousandths;

  /// True when the quantity represents exactly zero.
  bool get isZero => thousandths == 0;

  /// True when the quantity is negative (e.g. a stock adjustment).
  bool get isNegative => thousandths < 0;

  /// True when the quantity has no fractional part.
  bool get isWhole => thousandths % 1000 == 0;

  /// The quantity with its sign removed.
  Quantity abs() => Quantity.thousandths(thousandths.abs());

  /// Adds two quantities.
  Quantity operator +(Quantity other) =>
      Quantity.thousandths(thousandths + other.thousandths);

  /// Subtracts [other] from this quantity.
  Quantity operator -(Quantity other) =>
      Quantity.thousandths(thousandths - other.thousandths);

  /// Negates this quantity.
  Quantity operator -() => Quantity.thousandths(-thousandths);

  /// Multiplies this quantity by a whole [factor].
  Quantity operator *(int factor) => Quantity.thousandths(thousandths * factor);

  /// The line total for [unitPrice] at this quantity, rounded with [mode].
  Money lineTotal(Money unitPrice, {RoundingMode mode = RoundingMode.halfUp}) =>
      unitPrice.multiplyRatio(thousandths, 1000, mode: mode);

  @override
  int compareTo(Quantity other) => thousandths.compareTo(other.thousandths);

  bool operator <(Quantity other) => compareTo(other) < 0;

  bool operator <=(Quantity other) => compareTo(other) <= 0;

  bool operator >(Quantity other) => compareTo(other) > 0;

  bool operator >=(Quantity other) => compareTo(other) >= 0;

  /// A canonical decimal string, e.g. `-0.750`, `3`, `0.050`.
  String toDecimalString() {
    final int magnitude = thousandths.abs();
    final int whole = magnitude ~/ 1000;
    final int fraction = magnitude % 1000;
    final String sign = isNegative ? '-' : '';
    if (fraction == 0) {
      return '$sign$whole';
    }
    return '$sign$whole.${fraction.toString().padLeft(3, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      other is Quantity && thousandths == other.thousandths;

  @override
  int get hashCode => thousandths.hashCode;

  @override
  String toString() => toDecimalString();

  static Result<Quantity> _invalid(String input) => Result<Quantity>.err(
    ValidationFailure(message: 'Invalid quantity: "$input"'),
  );

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
}
