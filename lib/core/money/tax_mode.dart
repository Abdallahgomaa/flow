/// Describes how a tax rate relates to the amount it applies to.
enum TaxMode {
  /// The amount is *net*; tax is added on top of it.
  exclusive,

  /// The amount is *gross*; tax is already included and must be extracted.
  inclusive,
}
