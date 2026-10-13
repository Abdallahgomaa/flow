import '../../core/money/money_core.dart';
import '../../shared/l10n/l10n.dart';

/// Demo catalogue backing the Day-2 search showcase.
///
/// This is **UI seed data only** — deliberately not a domain entity. It exists
/// so the search field can return real, visible results before the encrypted
/// database and the real product model land (`P0-11`..`P0-16`). Prices are
/// stored in integer minor units (EGP), never as `double`.
enum DemoProduct {
  milk(barcode: '1000000000017', price: Money.fromMinor(1850, Currency.egp)),
  bread(barcode: '1000000000024', price: Money.fromMinor(500, Currency.egp)),
  rice(barcode: '1000000000031', price: Money.fromMinor(4200, Currency.egp)),
  tea(barcode: '1000000000048', price: Money.fromMinor(7500, Currency.egp)),
  oil(barcode: '1000000000055', price: Money.fromMinor(9800, Currency.egp)),
  sugar(barcode: '1000000000062', price: Money.fromMinor(3600, Currency.egp)),
  water(barcode: '1000000000079', price: Money.fromMinor(600, Currency.egp)),
  soap(barcode: '1000000000086', price: Money.fromMinor(2500, Currency.egp));

  const DemoProduct({required this.barcode, required this.price});

  /// Machine-readable barcode (digits only, as scanned).
  final String barcode;

  /// Unit price in the demo currency.
  final Money price;

  /// Localised, human-readable name.
  String name(AppLocalizations l10n) => switch (this) {
    DemoProduct.milk => l10n.demoProductMilk,
    DemoProduct.bread => l10n.demoProductBread,
    DemoProduct.rice => l10n.demoProductRice,
    DemoProduct.tea => l10n.demoProductTea,
    DemoProduct.oil => l10n.demoProductOil,
    DemoProduct.sugar => l10n.demoProductSugar,
    DemoProduct.water => l10n.demoProductWater,
    DemoProduct.soap => l10n.demoProductSoap,
  };

  /// Whether this product matches [query] by name or barcode.
  ///
  /// Matching is case-insensitive and ignores surrounding [query] whitespace;
  /// an empty/blank query never matches, which lets callers treat "no query"
  /// and "no results" distinctly.
  bool matches(AppLocalizations l10n, String query) {
    final String needle = query.trim().toLowerCase();
    if (needle.isEmpty) {
      return false;
    }
    return name(l10n).toLowerCase().contains(needle) ||
        barcode.toLowerCase().contains(needle);
  }
}
