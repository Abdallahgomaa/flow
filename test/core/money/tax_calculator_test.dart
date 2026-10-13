import 'dart:math';

import 'package:flow/core/money/money_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Currency egp = Currency.egp;
  const Rate vat = Rate.basisPoints(1400); // 14%

  Money minor(int value) => Money.fromMinor(value, egp);

  group('exclusive tax', () {
    test('adds tax on top of the net amount', () {
      final TaxResult result = TaxCalculator.calculate(
        amount: minor(10000),
        mode: TaxMode.exclusive,
        rates: <Rate>[vat],
      );
      expect(result.net, minor(10000));
      expect(result.tax, minor(1400));
      expect(result.gross, minor(11400));
      expect(result.perRate, <Money>[minor(1400)]);
    });

    test('sums multiple rates', () {
      final TaxResult result = TaxCalculator.calculate(
        amount: minor(10000),
        mode: TaxMode.exclusive,
        rates: const <Rate>[Rate.basisPoints(500), Rate.basisPoints(1400)],
      );
      expect(result.perRate, <Money>[minor(500), minor(1400)]);
      expect(result.tax, minor(1900));
      expect(result.gross, minor(11900));
    });
  });

  group('inclusive tax', () {
    test('extracts tax from a gross amount', () {
      final TaxResult result = TaxCalculator.calculate(
        amount: minor(11400),
        mode: TaxMode.inclusive,
        rates: const <Rate>[vat],
      );
      expect(result.gross, minor(11400));
      expect(result.tax, minor(1400));
      expect(result.net, minor(10000));
      expect(result.perRate, <Money>[minor(1400)]);
    });

    test('handles tiny edge amounts', () {
      final TaxResult oneCent = TaxCalculator.calculate(
        amount: minor(1),
        mode: TaxMode.inclusive,
        rates: const <Rate>[vat],
      );
      expect(oneCent.tax, minor(0));
      expect(oneCent.net, minor(1));
      expect(oneCent.net + oneCent.tax, oneCent.gross);

      final TaxResult fiveCents = TaxCalculator.calculate(
        amount: minor(5),
        mode: TaxMode.inclusive,
        rates: const <Rate>[vat],
      );
      expect(fiveCents.tax, minor(1));
      expect(fiveCents.net, minor(4));
    });

    test('zero or empty rates yield zero tax', () {
      final TaxResult empty = TaxCalculator.calculate(
        amount: minor(5000),
        mode: TaxMode.inclusive,
        rates: const <Rate>[],
      );
      expect(empty.tax, minor(0));
      expect(empty.net, minor(5000));
      expect(empty.perRate, isEmpty);

      final TaxResult zero = TaxCalculator.calculate(
        amount: minor(5000),
        mode: TaxMode.inclusive,
        rates: const <Rate>[Rate.zero],
      );
      expect(zero.tax, minor(0));
      expect(zero.perRate, <Money>[minor(0)]);
    });
  });

  group('invariants', () {
    test('net + tax == gross and perRate sums to tax (random)', () {
      final Random random = Random(90210);
      for (int i = 0; i < 2000; i++) {
        final Money amount = Money.fromMinor(random.nextInt(500000), egp);
        final int rateCount = 1 + random.nextInt(3);
        final List<Rate> rates = <Rate>[
          for (int j = 0; j < rateCount; j++)
            Rate.basisPoints(random.nextInt(2000)),
        ];
        for (final TaxMode mode in TaxMode.values) {
          final TaxResult result = TaxCalculator.calculate(
            amount: amount,
            mode: mode,
            rates: rates,
          );
          expect(result.net + result.tax, result.gross);
          Money partsSum = const Money.zero(egp);
          for (final Money part in result.perRate) {
            partsSum = partsSum + part;
          }
          expect(partsSum, result.tax);
          expect(result.perRate.length, rateCount);
        }
      }
    });
  });
}
