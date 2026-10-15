import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';

/// The rules a product must satisfy, shared by `CreateProduct` and
/// `UpdateProduct`.
///
/// Both use cases must accept and reject exactly the same input, so the rules
/// live here once instead of being copied into each of them, where the two copies
/// would drift apart (AGENTS rule 1). It is plain Dart with no database and no
/// Flutter, so it is directly unit-testable.
abstract final class ProductValidation {
  const ProductValidation._();

  /// Failure code: the product has no name.
  static const String nameRequiredCode = 'product.nameRequired';

  /// Failure code: the product has no stock unit.
  static const String stockUnitRequiredCode = 'product.stockUnitRequired';

  /// Failure code: a price was negative.
  static const String priceNegativeCode = 'product.priceNegative';

  /// Returns the first problem with the given fields, or `null` when they are all
  /// acceptable.
  static Failure? validate({
    required String name,
    required String stockUnitCode,
    required Money salePrice,
    Money? costPrice,
  }) {
    if (name.trim().isEmpty) {
      return const ValidationFailure(
        message: 'Enter a product name.',
        code: nameRequiredCode,
      );
    }
    if (stockUnitCode.trim().isEmpty) {
      return const ValidationFailure(
        message: 'Choose the unit the stock is counted in.',
        code: stockUnitRequiredCode,
      );
    }
    if (salePrice.isNegative || (costPrice?.isNegative ?? false)) {
      return const ValidationFailure(
        message: 'A price cannot be negative.',
        code: priceNegativeCode,
      );
    }
    return null;
  }

  /// Trims [value], mapping `null` and blank input to `null`.
  ///
  /// Optional fields arrive from a form as empty strings; storing those would
  /// turn "not set" into a foreign key that points nowhere.
  static String? normaliseOptional(String? value) {
    final String? trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  /// Failure code: no product was named for an edit or a retirement.
  ///
  /// It lives here, once, because both `UpdateProduct` and `DisableProduct`
  /// refuse a blank id and two copies of the same code could drift apart.
  static const String idRequiredCode = 'product.idRequired';

  /// Returns the first problem with the supplied product [id], or `null` when it
  /// is usable.
  static Failure? validateId(String id) {
    if (id.trim().isEmpty) {
      return const ValidationFailure(
        message: 'Choose a product first.',
        code: idRequiredCode,
      );
    }
    return null;
  }
}
