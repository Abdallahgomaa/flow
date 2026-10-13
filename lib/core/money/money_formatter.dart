import 'money.dart';

/// Digit script used when rendering numbers.
enum NumberDigits {
  /// Western Arabic numerals (`0`..`9`). Default for the cashier UI.
  western,

  /// Arabic-Indic numerals (`٠`..`٩`).
  arabicIndic,
}

/// Locale-independent number rendering options.
///
/// The cashier screens default to Western digits for clarity; the settings
/// step (later) will let the user switch to Arabic-Indic digits.
final class NumberStyle {
  const NumberStyle({
    this.groupSeparator = ',',
    this.decimalSeparator = '.',
    this.digits = NumberDigits.western,
  });

  /// Separator inserted every three integer digits.
  final String groupSeparator;

  /// Separator placed before the minor digits.
  final String decimalSeparator;

  /// Digit script.
  final NumberDigits digits;
}

/// Renders [Money] values for display without depending on `intl`.
///
/// Example output: `1,234.50 EGP` (currency code after the amount by default;
/// set [symbolFirst] to place it before instead).
final class MoneyFormatter {
  const MoneyFormatter({
    this.style = const NumberStyle(),
    this.symbolFirst = false,
  });

  /// Number rendering options.
  final NumberStyle style;

  /// When `true`, prints the currency code before the amount.
  final bool symbolFirst;

  /// Formats [money] using the configured [style].
  String format(Money money) {
    final String raw = money.toDecimalString();
    final bool negative = raw.startsWith('-');
    final String unsigned = negative ? raw.substring(1) : raw;
    final int dot = unsigned.indexOf('.');
    final String whole = dot == -1 ? unsigned : unsigned.substring(0, dot);
    final String fraction = dot == -1 ? '' : unsigned.substring(dot + 1);

    final String grouped = _group(whole);
    final String signed = negative ? '-$grouped' : grouped;
    final String withFraction = fraction.isEmpty
        ? signed
        : '$signed${style.decimalSeparator}$fraction';

    final String amount = _toDigits(withFraction);
    return symbolFirst
        ? '${money.currency.code} $amount'
        : '$amount ${money.currency.code}';
  }

  String _group(String whole) {
    if (whole.length <= 3) {
      return whole;
    }
    final int firstGroup = whole.length % 3 == 0 ? 3 : whole.length % 3;
    final StringBuffer buffer = StringBuffer(whole.substring(0, firstGroup));
    for (int i = firstGroup; i < whole.length; i += 3) {
      buffer
        ..write(style.groupSeparator)
        ..write(whole.substring(i, i + 3));
    }
    return buffer.toString();
  }

  String _toDigits(String value) {
    if (style.digits == NumberDigits.western) {
      return value;
    }
    final StringBuffer buffer = StringBuffer();
    for (final int unit in value.codeUnits) {
      if (unit >= 0x30 && unit <= 0x39) {
        buffer.writeCharCode(0x0660 + (unit - 0x30));
      } else {
        buffer.writeCharCode(unit);
      }
    }
    return buffer.toString();
  }
}
