import 'package:flow/features/catalog/domain/product_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductType', () {
    test('exposes the six slugs the catalogue is built on', () {
      expect(
        ProductType.values.map((ProductType type) => type.code).toList(),
        <String>[
          'simple',
          'weighted',
          'service',
          'raw_material',
          'composite',
          'bundle',
        ],
      );
    });

    test('parses every stored slug back to its constant', () {
      for (final ProductType type in ProductType.values) {
        expect(ProductType.fromCode(type.code), type);
      }
    });

    test('returns null for a slug it does not know', () {
      expect(ProductType.fromCode('nope'), isNull);
      expect(ProductType.fromCode(''), isNull);
    });
  });
}
