import 'package:flow/core/money/money_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Currency egp = Currency.egp;

  group('Quantity.parse', () {
    test('accepts whole and fractional values', () {
      expect(Quantity.parse('2').valueOrNull, Quantity.units(2));
      expect(
        Quantity.parse('0.750').valueOrNull,
        const Quantity.thousandths(750),
      );
      expect(
        Quantity.parse('-1.5').valueOrNull,
        const Quantity.thousandths(-1500),
      );
      expect(Quantity.parse('.5').valueOrNull, const Quantity.thousandths(500));
      expect(Quantity.parse('0').valueOrNull, const Quantity.thousandths(0));
    });

    test('rejects malformed input and extra precision', () {
      expect(Quantity.parse('1.2345').isErr, isTrue);
      expect(Quantity.parse('1,000').isErr, isTrue);
      expect(Quantity.parse('abc').isErr, isTrue);
      expect(Quantity.parse('').isErr, isTrue);
      expect(Quantity.parse('-').isErr, isTrue);
      expect(Quantity.parse('1.2.3').isErr, isTrue);
    });
  });

  group('Quantity', () {
    test('adds, subtracts and negates', () {
      const Quantity a = Quantity.thousandths(750);
      const Quantity b = Quantity.thousandths(1500);
      expect(a + b, const Quantity.thousandths(2250));
      expect(b - a, const Quantity.thousandths(750));
      expect(-a, const Quantity.thousandths(-750));
      expect(a.abs(), a);
      expect(
        const Quantity.thousandths(-750).abs(),
        const Quantity.thousandths(750),
      );
    });

    test('reports whole, zero and sign state', () {
      expect(Quantity.units(3).isWhole, isTrue);
      expect(const Quantity.thousandths(1500).isWhole, isFalse);
      expect(const Quantity.thousandths(0).isZero, isTrue);
      expect(const Quantity.thousandths(-1).isNegative, isTrue);
    });

    test('compares by magnitude', () {
      const Quantity small = Quantity.thousandths(1);
      const Quantity big = Quantity.thousandths(2);
      expect(small.compareTo(big), isNegative);
      expect(small < big, isTrue);
      expect(small <= big, isTrue);
      expect(big > small, isTrue);
      expect(big >= small, isTrue);
      expect(small == const Quantity.thousandths(1), isTrue);
      expect(small.hashCode, const Quantity.thousandths(1).hashCode);
    });

    test('renders a canonical decimal string', () {
      expect(const Quantity.thousandths(750).toDecimalString(), '0.750');
      expect(Quantity.units(3).toDecimalString(), '3');
      expect(const Quantity.thousandths(-1500).toDecimalString(), '-1.500');
    });
  });

  group('Quantity.lineTotal', () {
    test('multiplies a unit price by the quantity', () {
      const Money unitPrice = Money.fromMinor(1000, egp); // 10.00
      expect(
        const Quantity.thousandths(750).lineTotal(unitPrice),
        const Money.fromMinor(750, egp), // 7.50
      );
      expect(
        const Quantity.thousandths(1333).lineTotal(
          const Money.fromMinor(333, egp), // 3.33
        ),
        const Money.fromMinor(444, egp), // 4.44 (half-up)
      );
    });

    test('handles negative quantities (returns)', () {
      const Money unitPrice = Money.fromMinor(1000, egp);
      expect(
        const Quantity.thousandths(-750).lineTotal(unitPrice),
        const Money.fromMinor(-750, egp),
      );
    });
  });
}
