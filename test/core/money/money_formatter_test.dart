import 'package:flow/core/money/money_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Currency egp = Currency.egp;
  const Currency jpy = Currency.jpy;

  group('MoneyFormatter', () {
    test('groups thousands with Western digits by default', () {
      const MoneyFormatter formatter = MoneyFormatter();
      expect(
        formatter.format(const Money.fromMinor(123450, egp)),
        '1,234.50 EGP',
      );
      expect(
        formatter.format(const Money.fromMinor(1234567890, egp)),
        '12,345,678.90 EGP',
      );
    });

    test('places the currency code first when asked', () {
      const MoneyFormatter formatter = MoneyFormatter(symbolFirst: true);
      expect(
        formatter.format(const Money.fromMinor(123450, egp)),
        'EGP 1,234.50',
      );
    });

    test('handles tiny and negative amounts', () {
      const MoneyFormatter formatter = MoneyFormatter();
      expect(formatter.format(const Money.fromMinor(5, egp)), '0.05 EGP');
      expect(formatter.format(const Money.fromMinor(-5, egp)), '-0.05 EGP');
      expect(formatter.format(const Money.zero(egp)), '0.00 EGP');
    });

    test('omits the decimal part for zero-digit currencies', () {
      const MoneyFormatter formatter = MoneyFormatter();
      expect(formatter.format(const Money.fromMinor(1234, jpy)), '1,234 JPY');
    });

    test('renders Arabic-Indic digits when requested', () {
      const MoneyFormatter formatter = MoneyFormatter(
        style: NumberStyle(digits: NumberDigits.arabicIndic),
      );
      expect(
        formatter.format(const Money.fromMinor(123450, egp)),
        '١,٢٣٤.٥٠ EGP',
      );
    });

    test('honours custom separators', () {
      const MoneyFormatter formatter = MoneyFormatter(
        style: NumberStyle(groupSeparator: '.', decimalSeparator: ','),
      );
      expect(
        formatter.format(const Money.fromMinor(123450, egp)),
        '1.234,50 EGP',
      );
    });
  });
}
