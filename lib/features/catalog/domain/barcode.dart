import 'package:flow/core/money/money_core.dart';

/// A scannable label that resolves to a product (`P2-03`).
///
/// One product carries many labels: the manufacturer's code, a shelf label the
/// shop printed itself, and the code on the outer carton are all the same
/// product reached three different ways. Keeping them as rows of their own —
/// rather than a column on the product — is what lets a carton label mean
/// "twelve units" instead of "one product" ([multiplier]).
///
/// The multiplier is integer thousandths, never a `double` (binding rule 2):
/// a label on a single unit is `1000`, the label on a carton of twelve is
/// `12000`.
final class Barcode {
  /// Creates a label.
  const Barcode({
    required this.id,
    required this.code,
    required this.productId,
    required this.createdAt,
    this.multiplier = plainUnitMultiplier,
    this.disabledAt,
    this.updatedAt,
  });

  /// What one scan of a label on a single unit represents.
  ///
  /// It lives here so "one unit" has one definition instead of a literal
  /// `1000` scattered across the callers.
  static const Quantity plainUnitMultiplier = Quantity.thousandths(1000);

  /// Stable identifier (UUID v7), assigned by the creating use case.
  final String id;

  /// The scannable code, unique across the whole shop.
  final String code;

  /// The product a scan of this code resolves to.
  final String productId;

  /// How many stock units one scan of this code represents.
  final Quantity multiplier;

  /// When the label was retired (UTC), or `null` while it is active.
  final DateTime? disabledAt;

  /// When the label was created (UTC).
  final DateTime createdAt;

  /// When the label was last modified (UTC), or `null` if never.
  final DateTime? updatedAt;

  /// Whether the label has been retired.
  bool get isDisabled => disabledAt != null;

  /// The fields worth recording in the audit trail.
  ///
  /// The multiplier travels in its integer form because that is the number the
  /// row stores; a formatted decimal would be a second, lossier spelling of it.
  Map<String, Object?> toAuditPayload() => <String, Object?>{
    'id': id,
    'code': code,
    'productId': productId,
    'multiplierThousandths': multiplier.thousandths,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Barcode &&
          other.id == id &&
          other.code == code &&
          other.productId == productId &&
          other.multiplier == multiplier &&
          other.disabledAt == disabledAt &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    code,
    productId,
    multiplier,
    disabledAt,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'Barcode(id: $id, code: $code, productId: $productId, '
      'multiplierThousandths: ${multiplier.thousandths}, '
      'isDisabled: $isDisabled)';
}
