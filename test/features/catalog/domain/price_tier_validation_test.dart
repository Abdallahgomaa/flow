import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/features/catalog/domain/price_tier.dart';
import 'package:flow/features/catalog/domain/price_tier_validation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Covers `P2-04`: the rules a price band has to satisfy before it is stored.
void main() {
  const Money price = Money.fromMinor(1850, Currency.egp);

  group('TierPriceValidation.validate', () {
    test('accepts a well-formed band', () {
      expect(
        TierPriceValidation.validate(
          productId: 'p1',
          minQuantity: TierPrice.firstBandQuantity,
          price: price,
        ),
        isNull,
      );
    });

    test('accepts a bulk band that starts higher up', () {
      expect(
        TierPriceValidation.validate(
          productId: 'p1',
          minQuantity: const Quantity.thousandths(12000),
          price: price,
        ),
        isNull,
      );
    });

    test('refuses a blank product', () {
      final Failure? failure = TierPriceValidation.validate(
        productId: '   ',
        minQuantity: TierPrice.firstBandQuantity,
        price: price,
      );

      expect(failure, isA<ValidationFailure>());
      expect(failure?.code, TierPriceValidation.productRequiredCode);
    });

    test('refuses a band that starts below one unit', () {
      final Failure? failure = TierPriceValidation.validate(
        productId: 'p1',
        minQuantity: const Quantity.thousandths(0),
        price: price,
      );

      expect(failure, isA<ValidationFailure>());
      expect(failure?.code, TierPriceValidation.minQuantityNotPositiveCode);
    });

    test('refuses a negative price', () {
      final Failure? failure = TierPriceValidation.validate(
        productId: 'p1',
        minQuantity: TierPrice.firstBandQuantity,
        price: const Money.fromMinor(-1, Currency.egp),
      );

      expect(failure, isA<ValidationFailure>());
      expect(failure?.code, TierPriceValidation.priceNegativeCode);
    });

    test('accepts a zero price, because a shop gives samples away', () {
      expect(
        TierPriceValidation.validate(
          productId: 'p1',
          minQuantity: TierPrice.firstBandQuantity,
          price: const Money.zero(Currency.egp),
        ),
        isNull,
      );
    });
  });

  group('TierPriceValidation.validateId', () {
    test('accepts an id', () {
      expect(TierPriceValidation.validateId('t1'), isNull);
    });

    test('refuses a blank id', () {
      final Failure? failure = TierPriceValidation.validateId('  ');

      expect(failure, isA<ValidationFailure>());
      expect(failure?.code, TierPriceValidation.idRequiredCode);
    });
  });
}
