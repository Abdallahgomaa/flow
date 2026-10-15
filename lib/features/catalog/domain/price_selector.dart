import 'package:flow/core/money/money_core.dart';

import 'price_tier.dart';

/// Chooses the price to charge for a quantity on a tier (`P2-04`).
///
/// The selector is a value service: it takes the bands it should reason about and
/// never touches a database, so the pricing rules are testable on their own.
/// Availability (which bands exist) and permissions are the caller's business —
/// but a retired band is ignored here, because it is retired precisely so that it
/// cannot price anything new.
abstract final class PriceSelector {
  const PriceSelector._();

  /// The price per stock unit for [quantity] on [tier].
  ///
  /// Bands stack: of the bands belonging to [tier] that are live and start at or
  /// below [quantity], the one starting at the **largest** quantity wins, so
  /// «from twelve» beats «from one» once twelve are bought.
  ///
  /// When no band of [tier] applies — the product has none, they are all retired,
  /// or [quantity] is below the smallest one — [fallback] is returned. That is the
  /// product's own sale price: a missing wholesale rule must never be read as
  /// «free», and a customer who buys three when wholesale starts at twelve pays
  /// the retail price rather than nothing.
  static Money select({
    required List<TierPrice> tiers,
    required PriceTier tier,
    required Quantity quantity,
    required Money fallback,
  }) {
    TierPrice? best;
    for (final TierPrice band in tiers) {
      if (band.isDisabled || band.tier != tier) {
        continue;
      }
      if (band.minQuantity.thousandths > quantity.thousandths) {
        continue;
      }
      // Strictly greater, so the first band of the tightest start quantity wins
      // and a later row can never displace it.
      if (best == null ||
          band.minQuantity.thousandths > best.minQuantity.thousandths) {
        best = band;
      }
    }
    return best?.price ?? fallback;
  }
}
