import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/features/catalog/domain/barcode.dart';
import 'package:flow/features/catalog/domain/barcode_validation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Covers `P2-03`: the label entity and the rules every caller has to agree on
/// before a scan can be trusted.
void main() {
  final DateTime createdAt = DateTime.utc(2026, 5, 1);

  Barcode barcode({
    String id = 'b1',
    String code = '5901234123457',
    String productId = 'p1',
    Quantity multiplier = Barcode.plainUnitMultiplier,
    DateTime? disabledAt,
  }) => Barcode(
    id: id,
    code: code,
    productId: productId,
    multiplier: multiplier,
    createdAt: createdAt,
    disabledAt: disabledAt,
  );

  group('Barcode', () {
    test('a label on a single item starts as one stock unit', () {
      expect(Barcode.plainUnitMultiplier, const Quantity.thousandths(1000));
      expect(barcode().multiplier, const Quantity.thousandths(1000));
    });

    test('carries its identity, and not its prices, in the audit payload', () {
      final Barcode carton = barcode(
        multiplier: const Quantity.thousandths(12000),
      );

      expect(carton.toAuditPayload(), <String, Object?>{
        'id': 'b1',
        'code': '5901234123457',
        'productId': 'p1',
        'multiplierThousandths': 12000,
      });
    });

    test('reports whether it has been retired', () {
      expect(barcode().isDisabled, isFalse);
      expect(barcode(disabledAt: DateTime.utc(2026, 5, 2)).isDisabled, isTrue);
    });

    test('two labels are equal when every field matches', () {
      expect(barcode(), barcode());
    });

    test('two labels that differ in code are not equal', () {
      expect(barcode(code: '5900000000000'), isNot(barcode()));
    });

    test('two labels that differ in multiplier are not equal', () {
      expect(
        barcode(multiplier: const Quantity.thousandths(12000)),
        isNot(barcode()),
      );
    });
  });

  group('BarcodeValidation.normaliseCode', () {
    test('trims what a scanner or a hurried typist appends', () {
      expect(
        BarcodeValidation.normaliseCode('  5901234123457\n'),
        '5901234123457',
      );
    });
  });

  group('BarcodeValidation.validate', () {
    test('accepts a well-formed label', () {
      expect(
        BarcodeValidation.validate(
          code: '5901234123457',
          productId: 'p1',
          multiplier: Barcode.plainUnitMultiplier,
        ),
        isNull,
      );
    });

    test('refuses a blank code', () {
      final Failure? failure = BarcodeValidation.validate(
        code: '   ',
        productId: 'p1',
        multiplier: Barcode.plainUnitMultiplier,
      );

      expect(failure, isA<ValidationFailure>());
      expect(failure?.code, BarcodeValidation.codeRequiredCode);
    });

    test('refuses a blank product', () {
      final Failure? failure = BarcodeValidation.validate(
        code: '5901234123457',
        productId: '   ',
        multiplier: Barcode.plainUnitMultiplier,
      );

      expect(failure, isA<ValidationFailure>());
      expect(failure?.code, BarcodeValidation.productRequiredCode);
    });

    test('refuses a multiplier that represents no unit at all', () {
      final Failure? failure = BarcodeValidation.validate(
        code: '5901234123457',
        productId: 'p1',
        multiplier: const Quantity.thousandths(0),
      );

      expect(failure, isA<ValidationFailure>());
      expect(failure?.code, BarcodeValidation.multiplierNotPositiveCode);
    });

    test('accepts a carton multiplier', () {
      expect(
        BarcodeValidation.validate(
          code: '5901234123457',
          productId: 'p1',
          multiplier: const Quantity.thousandths(12000),
        ),
        isNull,
      );
    });
  });

  group('BarcodeValidation.validateId', () {
    test('accepts an id', () {
      expect(BarcodeValidation.validateId('b1'), isNull);
    });

    test('refuses a blank id', () {
      final Failure? failure = BarcodeValidation.validateId('  ');

      expect(failure, isA<ValidationFailure>());
      expect(failure?.code, BarcodeValidation.idRequiredCode);
    });
  });
}
