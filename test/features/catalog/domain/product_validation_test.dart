import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/features/catalog/domain/product_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Money price = Money.fromMinor(1850, Currency.egp);

  group('ProductValidation.validate', () {
    test('accepts a well-formed product', () {
      expect(
        ProductValidation.validate(
          name: 'Milk',
          stockUnitCode: 'piece',
          salePrice: price,
        ),
        isNull,
      );
    });

    test('refuses a blank name', () {
      final Failure? failure = ProductValidation.validate(
        name: '   ',
        stockUnitCode: 'piece',
        salePrice: price,
      );
      expect(failure, isA<ValidationFailure>());
      expect(failure?.code, ProductValidation.nameRequiredCode);
    });

    test('refuses a blank stock unit', () {
      final Failure? failure = ProductValidation.validate(
        name: 'Milk',
        stockUnitCode: '  ',
        salePrice: price,
      );
      expect(failure, isA<ValidationFailure>());
      expect(failure?.code, ProductValidation.stockUnitRequiredCode);
    });

    test('refuses a negative sale price', () {
      final Failure? failure = ProductValidation.validate(
        name: 'Milk',
        stockUnitCode: 'piece',
        salePrice: const Money.fromMinor(-1, Currency.egp),
      );
      expect(failure, isA<ValidationFailure>());
      expect(failure?.code, ProductValidation.priceNegativeCode);
    });

    test('refuses a negative cost even when the sale price is fine', () {
      final Failure? failure = ProductValidation.validate(
        name: 'Milk',
        stockUnitCode: 'piece',
        salePrice: price,
        costPrice: const Money.fromMinor(-1, Currency.egp),
      );
      expect(failure, isA<ValidationFailure>());
      expect(failure?.code, ProductValidation.priceNegativeCode);
    });

    test('accepts a zero price', () {
      expect(
        ProductValidation.validate(
          name: 'Sample',
          stockUnitCode: 'piece',
          salePrice: const Money.zero(Currency.egp),
        ),
        isNull,
      );
    });
  });

  group('ProductValidation.validateId', () {
    test('accepts an id', () {
      expect(ProductValidation.validateId('p1'), isNull);
    });

    test('refuses a blank id', () {
      final Failure? failure = ProductValidation.validateId('  ');
      expect(failure, isA<ValidationFailure>());
      expect(failure?.code, ProductValidation.idRequiredCode);
    });
  });

  group('ProductValidation.normaliseOptional', () {
    test('trims what it keeps', () {
      expect(ProductValidation.normaliseOptional('  piece '), 'piece');
    });

    test('collapses blank input to null', () {
      expect(ProductValidation.normaliseOptional('   '), isNull);
      expect(ProductValidation.normaliseOptional(null), isNull);
    });
  });
}
