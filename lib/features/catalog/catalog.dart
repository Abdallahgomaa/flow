/// The public surface of the catalog feature (`P2-01`).
///
/// Another feature may not reach into `features/catalog/data/` or
/// `features/catalog/presentation/` directly (`AGENTS.md` §3, enforced by
/// `tool/check_boundaries.dart`); anything it legitimately needs is re-exported
/// here. Pure value types are also reachable straight from
/// `features/catalog/domain/`, which is the better choice for a feature's own
/// `domain/` layer because this barrel drags Riverpod in with it.
library;

export 'data/catalog_providers.dart';
export 'domain/barcode.dart';
export 'domain/barcode_repository.dart';
export 'domain/barcode_validation.dart';
export 'domain/category.dart';
export 'domain/category_repository.dart';
export 'domain/category_tree.dart';
export 'domain/price_selector.dart';
export 'domain/price_tier.dart';
export 'domain/price_tier_validation.dart';
export 'domain/product.dart';
export 'domain/product_repository.dart';
export 'domain/product_type.dart';
export 'domain/product_validation.dart';
export 'domain/tier_price_repository.dart';
export 'domain/unit.dart';
export 'domain/unit_converter.dart';
export 'domain/unit_repository.dart';
