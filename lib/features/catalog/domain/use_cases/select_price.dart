import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/result.dart';

import '../price_selector.dart';
import '../price_tier.dart';
import '../product.dart';
import '../product_repository.dart';
import '../tier_price_repository.dart';

/// Picks the price to charge for a product at a quantity on a tier (`P2-04`).
///
/// A read-only use case: it loads the product and its bands and delegates the
/// choice to the pure [PriceSelector], so it records no audit entry.
///
/// The product is read for one reason only: its own sale price is the fallback
/// when no band of the requested tier applies, and the selector must not have to
/// guess it.
final class SelectPrice {
  /// Creates the use case.
  const SelectPrice(this._tierPriceRepository, this._productRepository);

  final TierPriceRepository _tierPriceRepository;
  final ProductRepository _productRepository;

  /// Executes the use case.
  Future<Result<Money>> call({
    required String productId,
    required PriceTier tier,
    required Quantity quantity,
  }) async {
    final String trimmed = productId.trim();
    final Result<Product> product = await _productRepository.readById(trimmed);
    final Product? resolved = product.valueOrNull;
    if (resolved == null) {
      return Result<Money>.err(product.failureOrNull!);
    }

    final Result<List<TierPrice>> tiers = await _tierPriceRepository
        .readForProduct(trimmed);
    return tiers.fold(
      ok: (List<TierPrice> bands) => Result<Money>.ok(
        PriceSelector.select(
          tiers: bands,
          tier: tier,
          quantity: quantity,
          fallback: resolved.salePrice,
        ),
      ),
      err: Result<Money>.err,
    );
  }
}
