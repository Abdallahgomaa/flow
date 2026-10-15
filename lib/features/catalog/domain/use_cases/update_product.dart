import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';

import '../product.dart';
import '../product_repository.dart';
import '../product_type.dart';
import '../product_validation.dart';

/// Edits an existing product (`P2-02`).
///
/// Identity is deliberately not taken from the caller: [id] selects the row and
/// `created_at` is carried over from the stored product, so an edit can never
/// rewrite when the product came into existence. `updated_at` is stamped here by
/// the same [Clock] that stamps every other write.
///
/// The stored row is also what makes the audit entry meaningful: the price fields
/// of the payload are built by comparing the new prices with the previous ones,
/// so the trail records a price change as a before/after pair and an ordinary
/// edit as no price change at all.
final class UpdateProduct {
  /// Creates the use case.
  const UpdateProduct(this._repository, this._clock);

  final ProductRepository _repository;
  final Clock _clock;

  /// The audit action recorded for an edited product.
  static const String auditAction = 'product.updated';

  /// Executes the use case.
  Future<Result<Product>> call({
    required String id,
    required String name,
    required ProductType type,
    required String stockUnitCode,
    required Money salePrice,
    String? categoryId,
    String? purchaseUnitCode,
    Money? costPrice,
    Quantity? reorderLevel,
  }) async {
    final Failure? invalidId = ProductValidation.validateId(id);
    if (invalidId != null) {
      return Result<Product>.err(invalidId);
    }
    final Failure? invalid = ProductValidation.validate(
      name: name,
      stockUnitCode: stockUnitCode,
      salePrice: salePrice,
      costPrice: costPrice,
    );
    if (invalid != null) {
      return Result<Product>.err(invalid);
    }

    final Result<Product> stored = await _repository.readById(id.trim());
    final Product? previous = stored.valueOrNull;
    if (previous == null) {
      return Result<Product>.err(stored.failureOrNull!);
    }

    final Product product = Product(
      id: previous.id,
      name: name.trim(),
      type: type,
      stockUnitCode: stockUnitCode.trim(),
      salePrice: salePrice,
      createdAt: previous.createdAt,
      categoryId: ProductValidation.normaliseOptional(categoryId),
      purchaseUnitCode: ProductValidation.normaliseOptional(purchaseUnitCode),
      costPrice: costPrice,
      reorderLevel: reorderLevel,
      // Editing a product never re-enables it; only an explicit restore would,
      // and there is no such step yet.
      disabledAt: previous.disabledAt,
      updatedAt: _clock.nowUtc(),
    );

    return _repository.update(
      product: product,
      action: auditAction,
      payload: <String, Object?>{
        ...product.toAuditPayload(),
        ...product.priceAuditPayload(previous: previous),
      },
    );
  }
}
