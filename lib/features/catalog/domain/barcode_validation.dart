import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';

/// The rules a barcode label has to satisfy (`P2-03`).
///
/// They live in one place so `CreateBarcode` and any later editor accept and
/// reject exactly the same input (binding rule 1).
abstract final class BarcodeValidation {
  const BarcodeValidation._();

  /// Failure code: the code was left blank.
  static const String codeRequiredCode = 'barcode.codeRequired';

  /// Failure code: no product was chosen for the label.
  static const String productRequiredCode = 'barcode.productRequired';

  /// Failure code: the multiplier is not a positive amount.
  static const String multiplierNotPositiveCode =
      'barcode.multiplierNotPositive';

  /// Failure code: no label was named for a retirement.
  static const String idRequiredCode = 'barcode.idRequired';

  /// Trims a scanned or typed code.
  ///
  /// Scanners happily append whitespace or a newline, and a code that differs
  /// from its stored twin by a space would miss on lookup while looking
  /// identical on screen, so the trimming happens once, here.
  static String normaliseCode(String code) => code.trim();

  /// Returns the first problem with the supplied label, or `null` when it is
  /// usable.
  static Failure? validate({
    required String code,
    required String productId,
    required Quantity multiplier,
  }) {
    if (code.trim().isEmpty) {
      return const ValidationFailure(
        message: 'Enter the barcode.',
        code: codeRequiredCode,
      );
    }
    if (productId.trim().isEmpty) {
      return const ValidationFailure(
        message: 'Choose the product this barcode belongs to.',
        code: productRequiredCode,
      );
    }
    if (multiplier.thousandths <= 0) {
      return const ValidationFailure(
        message: 'A barcode must represent at least one unit.',
        code: multiplierNotPositiveCode,
      );
    }
    return null;
  }

  /// Returns the first problem with the supplied label [id], or `null` when it
  /// is usable.
  static Failure? validateId(String id) {
    if (id.trim().isEmpty) {
      return const ValidationFailure(
        message: 'Choose a barcode first.',
        code: idRequiredCode,
      );
    }
    return null;
  }
}
