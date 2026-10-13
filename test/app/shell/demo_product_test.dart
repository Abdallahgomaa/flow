import 'package:flow/app/shell/demo_product.dart';
import 'package:flow/shared/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations en;
  late AppLocalizations ar;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
    ar = await AppLocalizations.delegate.load(const Locale('ar'));
  });

  test('catalogue is non-empty with unique barcodes', () {
    expect(DemoProduct.values, isNotEmpty);
    final Set<String> barcodes = DemoProduct.values
        .map((DemoProduct product) => product.barcode)
        .toSet();
    expect(barcodes, hasLength(DemoProduct.values.length));
  });

  test('matches by name (case-insensitive) and by barcode', () {
    expect(DemoProduct.milk.matches(en, 'milk'), isTrue);
    expect(DemoProduct.milk.matches(en, 'MILK'), isTrue);
    expect(DemoProduct.milk.matches(en, DemoProduct.milk.barcode), isTrue);
    expect(DemoProduct.milk.matches(en, '  milk  '), isTrue);
    expect(DemoProduct.milk.matches(en, 'bread'), isFalse);
    expect(DemoProduct.milk.matches(en, '   '), isFalse);
  });

  test('names are localised', () {
    expect(DemoProduct.milk.name(en), isNotEmpty);
    expect(DemoProduct.milk.name(en), isNot(DemoProduct.milk.name(ar)));
  });
}
