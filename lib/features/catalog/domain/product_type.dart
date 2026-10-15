/// The kinds of product Flow sells (`P2-02`).
///
/// The PRD's «الأنواع الستة» is not part of this repository, so the list below is
/// a deliberate derivation rather than a quotation, and it stays provisional
/// until the PRD can be checked against it (the project rule is never to guess
/// silently). What each type means for stock, pricing and receipts is decided by
/// the later steps that consume it (`P2-08` movements, `P3-*` selling), so
/// adding a type later is a schema-safe change: only this enum and its codes are
/// involved.
enum ProductType {
  /// Tracked as whole units and sold one at a time (بسيط).
  simple('simple'),

  /// Sold by weight or volume, so the quantity may be fractional (موزون).
  weighted('weighted'),

  /// No stock at all: a haircut, a delivery fee, a repair (خدمة).
  service('service'),

  /// Bought and consumed inside the shop rather than sold as-is (مادة خام).
  rawMaterial('raw_material'),

  /// Assembled from other products, which are consumed when it is made (مركّب).
  composite('composite'),

  /// A ready-made set of products sold for one price (طقم).
  bundle('bundle');

  const ProductType(this.code);

  /// The stable slug persisted in `products.type`.
  ///
  /// The slug is what is stored, never [index], so reordering this enum cannot
  /// silently reclassify every stored product.
  final String code;

  /// The type the stored [code] refers to, or `null` when nothing matches.
  ///
  /// A `null` means the row was written by something other than this app (a
  /// hand-edited database, or a downgrade), which the repository handles at its
  /// own boundary rather than by throwing here.
  static ProductType? fromCode(String code) {
    for (final ProductType type in ProductType.values) {
      if (type.code == code) {
        return type;
      }
    }
    return null;
  }
}
