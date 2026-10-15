import 'package:flow/core/result/result.dart';

import '../product.dart';
import '../product_repository.dart';

/// Reads a single product by its id (`P2-05`).
///
/// The list screen can show a product from what it already loaded, but the edit
/// form cannot: it must be able to send back a **complete** product, including
/// the fields the signed-in role is not allowed to see. A save always goes
/// through `UpdateProduct`, and that use case requires a price, so the form has
/// to obtain the stored one rather than invent it. This read is how.
///
/// It is a read, not a mutation, so it records no audit entry.
final class LoadProductById {
  /// Creates the use case over the repository it reads from.
  const LoadProductById(this._repository);

  final ProductRepository _repository;

  /// Returns the stored product with [id], or a `product.notFound` failure when
  /// it is gone.
  Future<Result<Product>> call(String id) => _repository.readById(id.trim());
}
