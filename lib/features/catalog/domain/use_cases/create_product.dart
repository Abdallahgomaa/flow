import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/uuid_v7.dart';

import '../product.dart';
import '../product_repository.dart';
import '../product_type.dart';
import '../product_validation.dart';

/// Adds a product to the catalogue (`P2-02`).
///
/// Identity (`id`, `created_at`) is decided here rather than in the database
/// layer, so the same [Clock] that stamps the row also seeds the UUID v7 that
/// orders it: identifiers and timestamps never disagree (the rule `CreateUser`
/// established for the auth feature).
///
/// The use case takes raw fields, not a ready-made [Product], because the caller
/// does not know the id or the creation time.
final class CreateProduct {
  /// Creates the use case.
  const CreateProduct(this._repository, this._idGenerator, this._clock);

  final ProductRepository _repository;
  final UuidV7Generator _idGenerator;
  final Clock _clock;

  /// The audit action recorded for a new product.
  static const String auditAction = 'product.created';

  /// Executes the use case.
  Future<Result<Product>> call({
    required String name,
    required ProductType type,
    required String stockUnitCode,
    required Money salePrice,
    String? categoryId,
    String? purchaseUnitCode,
    Money? costPrice,
    Quantity? reorderLevel,
  }) async {
    final Failure? invalid = ProductValidation.validate(
      name: name,
      stockUnitCode: stockUnitCode,
      salePrice: salePrice,
      costPrice: costPrice,
    );
    if (invalid != null) {
      return Result<Product>.err(invalid);
    }

    final Product product = Product(
      id: _idGenerator.next(),
      name: name.trim(),
      type: type,
      stockUnitCode: stockUnitCode.trim(),
      salePrice: salePrice,
      createdAt: _clock.nowUtc(),
      categoryId: ProductValidation.normaliseOptional(categoryId),
      purchaseUnitCode: ProductValidation.normaliseOptional(purchaseUnitCode),
      costPrice: costPrice,
      reorderLevel: reorderLevel,
    );

    return _repository.create(
      product: product,
      action: auditAction,
      payload: <String, Object?>{
        ...product.toAuditPayload(),
        ...product.priceAuditPayload(),
      },
    );
  }
}
