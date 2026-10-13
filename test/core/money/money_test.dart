import 'dart:math';

import 'package:flow/core/money/money_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Currency egp = Currency.egp;
  const Currency kwd = Currency.kwd;
  const Currency jpy = Currency.jpy;

  group('Currency', () {
    test('validates the code format', () {
      expect(() => Currency('egp', 2), throwsArgumentError);
      expect(() => Currency('EG', 2), throwsArgumentError);
      expect(() => Currency('EGPP', 2), throwsArgumentError);
    });

    test('validates the number of minor digits', () {
      expect(() => Currency('EGP', -1), throwsArgumentError);
      expect(() => Currency('EGP', 5), throwsArgumentError);
      expect(Currency('EGP', 2), Currency.egp);
    });

    test('is a value type', () {
      expect(Currency('USD', 2), Currency.usd);
      expect(Currency('USD', 2).hashCode, Currency.usd.hashCode);
    });
  });

  group('Money.parse', () {
    test('accepts whole and fractional amounts', () {
      expect(
        Money.parse('12', egp).valueOrNull,
        const Money.fromMinor(1200, egp),
      );
      expect(
        Money.parse('12.5', egp).valueOrNull,
        const Money.fromMinor(1250, egp),
      );
      expect(
        Money.parse('12.50', egp).valueOrNull,
        const Money.fromMinor(1250, egp),
      );
      expect(
        Money.parse('-0.05', egp).valueOrNull,
        const Money.fromMinor(-5, egp),
      );
      expect(Money.parse('0', egp).valueOrNull, const Money.zero(egp));
      expect(
        Money.parse('.5', egp).valueOrNull,
        const Money.fromMinor(50, egp),
      );
    });

    test('respects the currency scale', () {
      expect(
        Money.parse('1.234', kwd).valueOrNull,
        const Money.fromMinor(1234, kwd),
      );
      expect(
        Money.parse('1234', jpy).valueOrNull,
        const Money.fromMinor(1234, jpy),
      );
      expect(Money.parse('12.5', jpy).isErr, isTrue);
    });

    test('rejects thousand separators, letters and stray dots', () {
      expect(Money.parse('1,234', egp).isErr, isTrue);
      expect(Money.parse('abc', egp).isErr, isTrue);
      expect(Money.parse('1.234', egp).isErr, isTrue);
      expect(Money.parse('1.2.3', egp).isErr, isTrue);
      expect(Money.parse('', egp).isErr, isTrue);
      expect(Money.parse('-', egp).isErr, isTrue);
    });

    test('round-trips through toDecimalString', () {
      final Random random = Random(20260101);
      const List<Currency> currencies = <Currency>[jpy, egp, kwd];
      for (int i = 0; i < 500; i++) {
        final Currency currency = currencies[i % currencies.length];
        final int minorUnits = random.nextInt(2000000) - 1000000;
        final Money money = Money.fromMinor(minorUnits, currency);
        final Money parsed = Money.parse(
          money.toDecimalString(),
          currency,
        ).valueOrNull!;
        expect(parsed, money);
      }
    });
  });

  group('Money arithmetic', () {
    test('adds, subtracts and negates', () {
      const Money a = Money.fromMinor(1234, egp);
      const Money b = Money.fromMinor(66, egp);
      expect(a + b, const Money.fromMinor(1300, egp));
      expect(a - b, const Money.fromMinor(1168, egp));
      expect((-a).minorUnits, -1234);
      expect(a.abs(), a);
      expect(
        const Money.fromMinor(-5, egp).abs(),
        const Money.fromMinor(5, egp),
      );
    });

    test('multiplication and (a + b) - b == a', () {
      final Random random = Random(4242);
      for (int i = 0; i < 1000; i++) {
        final Money a = Money.fromMinor(random.nextInt(1000000), egp);
        final Money b = Money.fromMinor(random.nextInt(1000000), egp);
        expect((a + b) - b, a);
        expect(a * 1, a);
        expect(a * 2, a + a);
      }
    });

    test('rejects operations across currencies', () {
      const Money egpAmount = Money.fromMinor(100, egp);
      const Money kwdAmount = Money.fromMinor(100, kwd);
      expect(() => egpAmount + kwdAmount, throwsArgumentError);
      expect(() => egpAmount.compareTo(kwdAmount), throwsArgumentError);
      expect(egpAmount == kwdAmount, isFalse);
    });

    test('rejects a non-positive ratio denominator', () {
      expect(
        () => const Money.fromMinor(100, egp).multiplyRatio(1, 0),
        throwsArgumentError,
      );
      expect(
        () => const Money.fromMinor(100, egp).multiplyRatio(1, -2),
        throwsArgumentError,
      );
    });

    test('applyRate uses half-up by default', () {
      const Rate vat = Rate.basisPoints(1400); // 14%
      expect(
        const Money.fromMinor(10000, egp).applyRate(vat),
        const Money.fromMinor(1400, egp),
      );
      // 0.05 * 14% = 0.007 -> rounds to 0.01
      expect(
        const Money.fromMinor(5, egp).applyRate(vat),
        const Money.fromMinor(1, egp),
      );
    });

    test('compareTo and boolean operators', () {
      const Money small = Money.fromMinor(1, egp);
      const Money big = Money.fromMinor(2, egp);
      expect(small.compareTo(big), isNegative);
      expect(small < big, isTrue);
      expect(small <= big, isTrue);
      expect(big > small, isTrue);
      expect(big >= small, isTrue);
      expect(small > big, isFalse);
    });

    test('state helpers and equality', () {
      expect(const Money.zero(egp).isZero, isTrue);
      expect(const Money.fromMinor(-1, egp).isNegative, isTrue);
      expect(const Money.fromMinor(1, egp).isPositive, isTrue);
      expect(const Money.fromMinor(5, egp), const Money.fromMinor(5, egp));
      expect(
        const Money.fromMinor(5, egp).hashCode,
        const Money.fromMinor(5, egp).hashCode,
      );
    });
  });

  group('Money.allocate', () {
    test('distributes the classic 100 into 34/33/33', () {
      final List<Money> parts = const Money.fromMinor(
        100,
        egp,
      ).allocate(<int>[1, 1, 1]);
      expect(parts, <Money>[
        const Money.fromMinor(34, egp),
        const Money.fromMinor(33, egp),
        const Money.fromMinor(33, egp),
      ]);
    });

    test('always sums back to the original', () {
      final Random random = Random(777);
      for (int i = 0; i < 1000; i++) {
        final int minorUnits = random.nextInt(2000000) - 1000000;
        final Money amount = Money.fromMinor(minorUnits, egp);
        final int count = 1 + random.nextInt(5);
        final List<int> ratios = <int>[
          for (int j = 0; j < count; j++) random.nextInt(9),
        ];
        if (ratios.every((int r) => r == 0)) {
          ratios[0] = 1;
        }
        final List<Money> parts = amount.allocate(ratios);
        final Money total = parts.reduce((Money a, Money b) => a + b);
        expect(total, amount);
      }
    });

    test('rejects empty, negative and all-zero ratios', () {
      const Money amount = Money.fromMinor(100, egp);
      expect(() => amount.allocate(<int>[]), throwsArgumentError);
      expect(() => amount.allocate(<int>[1, -1]), throwsArgumentError);
      expect(() => amount.allocate(<int>[0, 0]), throwsArgumentError);
    });
  });

  group('Rounding.divide', () {
    test('rounds around the midpoint for every mode', () {
      expect(
        Rounding.divide(BigInt.from(5), BigInt.two, RoundingMode.halfUp),
        BigInt.from(3),
      );
      expect(
        Rounding.divide(BigInt.from(-5), BigInt.two, RoundingMode.halfUp),
        BigInt.from(-3),
      );
      expect(
        Rounding.divide(BigInt.from(5), BigInt.two, RoundingMode.halfEven),
        BigInt.from(2),
      );
      expect(
        Rounding.divide(BigInt.from(7), BigInt.two, RoundingMode.halfEven),
        BigInt.from(4),
      );
      expect(
        Rounding.divide(BigInt.from(5), BigInt.two, RoundingMode.down),
        BigInt.from(2),
      );
      expect(
        Rounding.divide(BigInt.from(-5), BigInt.two, RoundingMode.down),
        BigInt.from(-2),
      );
      expect(
        Rounding.divide(BigInt.from(5), BigInt.two, RoundingMode.up),
        BigInt.from(3),
      );
      expect(
        Rounding.divide(BigInt.from(-5), BigInt.two, RoundingMode.up),
        BigInt.from(-3),
      );
    });

    test('exact divisions are unaffected by the mode', () {
      for (final RoundingMode mode in RoundingMode.values) {
        expect(
          Rounding.divide(BigInt.from(6), BigInt.two, mode),
          BigInt.from(3),
        );
      }
    });

    test('rejects a non-positive denominator', () {
      expect(
        () => Rounding.divide(BigInt.one, BigInt.zero, RoundingMode.halfUp),
        throwsArgumentError,
      );
    });
  });
}
