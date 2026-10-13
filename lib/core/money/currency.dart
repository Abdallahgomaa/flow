/// An ISO 4217 currency supported by Flow.
///
/// Value type: two currencies are equal when their [code] matches. Each
/// currency knows how many [minorDigits] its minor unit uses, which drives all
/// parsing and formatting.
final class Currency {
  const Currency._(this.code, this.minorDigits);

  /// Creates and validates a currency from its [code] and [minorDigits].
  ///
  /// Throws [ArgumentError] when the code is not three uppercase letters or
  /// when [minorDigits] is outside `0..4`.
  factory Currency(String code, int minorDigits) {
    if (!_codePattern.hasMatch(code)) {
      throw ArgumentError.value(code, 'code', 'must be 3 uppercase letters');
    }
    if (minorDigits < 0 || minorDigits > 4) {
      throw ArgumentError.value(
        minorDigits,
        'minorDigits',
        'must be between 0 and 4',
      );
    }
    return Currency._(code, minorDigits);
  }

  static final RegExp _codePattern = RegExp(r'^[A-Z]{3}$');

  /// Egyptian pound (2 minor digits).
  static const Currency egp = Currency._('EGP', 2);

  /// United States dollar (2 minor digits).
  static const Currency usd = Currency._('USD', 2);

  /// Euro (2 minor digits).
  static const Currency eur = Currency._('EUR', 2);

  /// Saudi riyal (2 minor digits).
  static const Currency sar = Currency._('SAR', 2);

  /// Kuwaiti dinar (3 minor digits).
  static const Currency kwd = Currency._('KWD', 3);

  /// Japanese yen (0 minor digits).
  static const Currency jpy = Currency._('JPY', 0);

  /// ISO 4217 alphabetic code (e.g. `EGP`).
  final String code;

  /// Number of digits after the decimal separator (`0..4`).
  final int minorDigits;

  /// The currencies Flow ships with, keyed by code.
  static const List<Currency> predefined = <Currency>[
    egp,
    usd,
    eur,
    sar,
    kwd,
    jpy,
  ];

  @override
  bool operator ==(Object other) => other is Currency && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => code;
}
