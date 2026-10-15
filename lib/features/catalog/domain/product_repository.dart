import 'package:flow/core/result/result.dart';

import 'product.dart';

/// The storage contract for products (`P2-02`).
///
/// The interface is pure Dart so use cases depend on the behaviour, never on
/// Drift; the Drift implementation lives in `data/`.
abstract interface class ProductRepository {
  /// Failure code: no product has that id.
  static const String notFoundCode = 'product.notFound';

  /// Failure code: the category a write names does not exist.
  static const String categoryNotFoundCode = 'product.categoryNotFound';

  /// Failure code: the stock unit a write names does not exist.
  static const String stockUnitNotFoundCode = 'product.stockUnitNotFound';

  /// Failure code: the purchase unit a write names does not exist.
  static const String purchaseUnitNotFoundCode = 'product.purchaseUnitNotFound';

  /// Every product, including disabled ones, ordered by name.
  ///
  /// Disabled rows are returned on purpose: the catalogue screens show them
  /// greyed out, and a sale line from last year must still resolve its product.
  Future<Result<List<Product>>> readAll();

  /// The product with [id], or a [ProductRepository.notFoundCode] failure.
  Future<Result<Product>> readById(String id);

  /// Stores a new product.
  ///
  /// Every write here is one atomic, audited unit of work: the row change and its
  /// audit entry commit together, or not at all (AGENTS rule 3). [payload] is
  /// merged with the price audit fields the caller supplies, so a price change is
  /// recorded explicitly.
  Future<Result<Product>> create({
    required Product product,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  });

  /// Overwrites an existing product.
  ///
  /// Returns [ProductRepository.notFoundCode] when the row is gone, so two
  /// sessions editing the same product cannot silently resurrect a deleted one.
  Future<Result<Product>> update({
    required Product product,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  });

  /// Retires a product by stamping `disabled_at`.
  ///
  /// The row is kept, because sale lines and stock movements reference it.
  Future<Result<void>> disable({
    required String id,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  });
}
