import 'package:flow/core/money/money_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Rate.parsePercent', () {
    test('parses whole and fractional percentages', () {
      expect(Rate.parsePercent('14').valueOrNull, const Rate.basisPoints(1400));
      expect(
        Rate.parsePercent('5.25').valueOrNull,
        const Rate.basisPoints(525),
      );
      expect(Rate.parsePercent('0.5').valueOrNull, const Rate.basisPoints(50));
      expect(
        Rate.parsePercent('14.0').valueOrNull,
        const Rate.basisPoints(1400),
      );
      expect(Rate.parsePercent('0').valueOrNull, Rate.zero);
      expect(Rate.parsePercent('.5').valueOrNull, const Rate.basisPoints(50));
      expect(Rate.parsePercent('-3').valueOrNull, const Rate.basisPoints(-300));
    });

    test('rejects malformed input beyond two decimals', () {
      expect(Rate.parsePercent('abc').isErr, isTrue);
      expect(Rate.parsePercent('1.234').isErr, isTrue);
      expect(Rate.parsePercent('1.2.3').isErr, isTrue);
      expect(Rate.parsePercent('').isErr, isTrue);
      expect(Rate.parsePercent('-').isErr, isTrue);
    });
  });

  group('Rate', () {
    test('renders percent strings', () {
      expect(const Rate.basisPoints(1400).toPercentString(), '14%');
      expect(const Rate.basisPoints(525).toPercentString(), '5.25%');
      expect(const Rate.basisPoints(50).toPercentString(), '0.5%');
      expect(const Rate.basisPoints(0).toPercentString(), '0%');
      expect(const Rate.basisPoints(-300).toPercentString(), '-3%');
    });

    test('is a comparable value type', () {
      expect(const Rate.basisPoints(500), const Rate.basisPoints(500));
      expect(
        const Rate.basisPoints(500).hashCode,
        const Rate.basisPoints(500).hashCode,
      );
      expect(Rate.zero.isZero, isTrue);
      expect(const Rate.basisPoints(-1).isNegative, isTrue);
      expect(
        const Rate.basisPoints(500) + const Rate.basisPoints(250),
        const Rate.basisPoints(750),
      );
      expect(const Rate.basisPoints(500) > const Rate.basisPoints(250), isTrue);
      expect(
        const Rate.basisPoints(500) >= const Rate.basisPoints(500),
        isTrue,
      );
      expect(const Rate.basisPoints(500) < const Rate.basisPoints(750), isTrue);
      expect(
        const Rate.basisPoints(500) <= const Rate.basisPoints(500),
        isTrue,
      );
    });

    test('full is one hundred percent', () {
      expect(Rate.full.basisPoints, 10000);
      expect(Rate.full.toPercentString(), '100%');
    });
  });
}
