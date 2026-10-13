/// Stable identifiers of the rows stored in the `app_settings` table.
///
/// These strings are a persisted contract: the database keeps them verbatim
/// across releases, so an existing key must never be renamed without a
/// migration. Keeping them in one place stops typos from silently creating a
/// second, competing row.
abstract final class SettingKeys {
  /// Persisted `ThemeMode` name (`system`, `light` or `dark`).
  static const String themeMode = 'theme_mode';

  /// BCP-47 language code, or empty to follow the device language.
  static const String locale = 'locale';

  /// Business profile fields (see `BusinessProfile`).
  static const String businessName = 'business_name';
  static const String businessPhone = 'business_phone';
  static const String businessAddress = 'business_address';
  static const String currency = 'currency';
  static const String taxRate = 'tax_rate';

  /// Text printed at the bottom of every receipt.
  static const String receiptFooter = 'receipt_footer';
}
