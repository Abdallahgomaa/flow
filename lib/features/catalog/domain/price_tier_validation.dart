import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';

/// The rules a price band has to satisfy (`P2-04`).
///
/// They live in one place so `CreateTierPrice` and `UpdateTierPrice` accept and
/// reject exactly the same input (binding rule 1).
abstract final class TierPriceValidation {
  const TierPriceValidation._();

  /// Failure code: no product was chosen for the band.
  static const String productRequiredCode = 'tierPrice.productRequired';

  /// Failure code: the band starts below one unit.
  static const String minQuantityNotPositiveCode =
      'tierPrice.minQuantityNotPositive';

  /// Failure code: the band price was negative.
  static const String priceNegativeCode = 'tierPrice.priceNegative';

  /// Failure code: no band was named for an edit or a retirement.
  static const String idRequiredCode = 'tierPrice.idRequired';

  /// Returns the first problem with the supplied band, or `null` when it is
  /// usable.
  static Failure? validate({
    required String productId,
    required Quantity minQuantity,
    required Money price,
  }) {
    if (productId.trim().isEmpty) {
      return const ValidationFailure(
        message: 'Choose the product this price belongs to.',
        code: productRequiredCode,
      );
    }
    if (minQuantity.thousandths <= 0) {
      return const ValidationFailure(
        message: 'A price band must start at one unit or more.',
        code: minQuantityNotPositiveCode,
      );
    }
    if (price.isNegative) {
      return const ValidationFailure(
        message: 'A price cannot be negative.',
        code: priceNegativeCode,
      );
    }
    return null;
  }

  /// Returns the first problem with the supplied band [id], or `null` when it is
  /// usable.
  static Failure? validateId(String id) {
    if (id.trim().isEmpty) {
      return const ValidationFailure(
        message: 'Choose a price band first.',
        code: idRequiredCode,
      );
    }
    return null;
  }
}
