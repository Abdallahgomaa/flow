import '../result/failure.dart';
import '../result/result.dart';

/// A decimal ratio stored as integer basis points.
///
/// One basis point is `1/10000` (`0.01%`). Storing the ratio as an integer
/// keeps every downstream computation exact, so [Rate] never touches `double`.
///
/// ```dart
/// const Rate vat = Rate.basisPoints(1400); // 14%
/// ```
final class Rate implements Comparable<Rate> {
  const Rate.basisPoints(this.basisPoints);

  /// Zero (0%).
  static const Rate zero = Rate.basisPoints(0);

  /// One hundred percent (100%).
  static const Rate full = Rate.basisPoints(10000);

  /// Parses a percentage string such as `'14'`, `'5.25'` or `'-3'`.
  ///
  /// At most two decimal places are accepted. Returns a [ValidationFailure]
  /// for malformed input instead of throwing.
  static Result<Rate> parsePercent(String input) {
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
        fraction.length > 2) {
      return _invalid(input);
    }

    final int hundredths = int.parse('$whole${fraction.padRight(2, '0')}');
    return Result<Rate>.ok(
      Rate.basisPoints(negative ? -hundredths : hundredths),
    );
  }

  /// The ratio in basis points (`10000` == `100%`).
  final int basisPoints;

  /// `true` when this rate is exactly zero.
  bool get isZero => basisPoints == 0;

  /// `true` when this rate is negative.
  bool get isNegative => basisPoints < 0;

  /// Sum of two rates (used to combine stacked taxes).
  Rate operator +(Rate other) =>
      Rate.basisPoints(basisPoints + other.basisPoints);

  @override
  int compareTo(Rate other) => basisPoints.compareTo(other.basisPoints);

  bool operator <(Rate other) => compareTo(other) < 0;

  bool operator <=(Rate other) => compareTo(other) <= 0;

  bool operator >(Rate other) => compareTo(other) > 0;

  bool operator >=(Rate other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is Rate && other.basisPoints == basisPoints;

  @override
  int get hashCode => basisPoints.hashCode;

  /// Human-readable percent form, e.g. `14%` or `5.25%`.
  String toPercentString() {
    final int abs = basisPoints.abs();
    final int whole = abs ~/ 100;
    final int fraction = abs % 100;
    final String sign = isNegative ? '-' : '';
    if (fraction == 0) {
      return '$sign$whole%';
    }
    if (fraction % 10 == 0) {
      return '$sign$whole.${fraction ~/ 10}%';
    }
    return '$sign$whole.${fraction.toString().padLeft(2, '0')}%';
  }

  @override
  String toString() => 'Rate(${toPercentString()})';

  static Result<Rate> _invalid(String input) =>
      Result<Rate>.err(ValidationFailure(message: 'Invalid rate: "$input"'));

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
