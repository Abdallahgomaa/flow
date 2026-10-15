/// Localised labels for catalogue concepts (`P2-05`).
///
/// The domain enums deliberately store stable slugs and carry no display text,
/// because the domain is pure Dart and the app is bilingual. The mapping from a
/// value to what a person actually reads therefore lives here — once, next to
/// the screens that need it, instead of being repeated in each of them where the
/// copies would drift apart (AGENTS rule 1).
library;

import 'package:flow/core/money/money_core.dart';
import 'package:flow/shared/l10n/l10n.dart';

import '../domain/price_tier.dart';
import '../domain/product_type.dart';

/// The catalogue's money formatter.
///
/// Money is rendered through `MoneyFormatter` and never through `toString()`,
/// which is a debugging aid, not a display format.
const MoneyFormatter catalogMoney = MoneyFormatter();

/// The label for a product type.
String productTypeLabel(AppLocalizations l10n, ProductType type) =>
    switch (type) {
      ProductType.simple => l10n.productTypeSimple,
      ProductType.weighted => l10n.productTypeWeighted,
      ProductType.service => l10n.productTypeService,
      ProductType.rawMaterial => l10n.productTypeRawMaterial,
      ProductType.composite => l10n.productTypeComposite,
      ProductType.bundle => l10n.productTypeBundle,
    };

/// The label for a price tier.
String priceTierLabel(AppLocalizations l10n, PriceTier tier) => switch (tier) {
  PriceTier.retail => l10n.priceTierRetail,
  PriceTier.wholesale => l10n.priceTierWholesale,
  PriceTier.custom => l10n.priceTierCustom,
};
