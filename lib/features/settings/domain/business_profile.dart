import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/utils/canonical_json.dart';

import 'setting_keys.dart';

/// The store identity printed on receipts and reports.
///
/// Pure domain value object: it never touches Flutter or the database. The
/// mapping to and from the key/value settings store lives here too, so the
/// wire format has exactly one definition.
final class BusinessProfile {
  /// Creates a profile; every field has a safe default so the screen can open
  /// on a fresh install before anything has been saved.
  const BusinessProfile({
    this.name = '',
    this.phone = '',
    this.address = '',
    this.currencyCode = defaultCurrencyCode,
    this.taxRate = Rate.zero,
    this.receiptFooter = '',
  });

  /// Currency used until the owner picks one.
  static const String defaultCurrencyCode = 'USD';

  /// Name of the business.
  final String name;

  /// Contact phone number.
  final String phone;

  /// Postal address.
  final String address;

  /// ISO 4217 code of the currency the store trades in.
  final String currencyCode;

  /// Tax applied to sales, as an exact [Rate].
  final Rate taxRate;

  /// Text printed at the bottom of every receipt.
  final String receiptFooter;

  /// Whether nothing has been filled in yet.
  bool get isEmpty =>
      name.isEmpty && phone.isEmpty && address.isEmpty && receiptFooter.isEmpty;

  /// Returns a copy with the given fields replaced.
  BusinessProfile copyWith({
    String? name,
    String? phone,
    String? address,
    String? currencyCode,
    Rate? taxRate,
    String? receiptFooter,
  }) => BusinessProfile(
    name: name ?? this.name,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    currencyCode: currencyCode ?? this.currencyCode,
    taxRate: taxRate ?? this.taxRate,
    receiptFooter: receiptFooter ?? this.receiptFooter,
  );

  /// Reads a profile from the raw settings [values].
  ///
  /// Missing or unparsable values fall back to the defaults: a corrupt row must
  /// never stop the app from opening.
  factory BusinessProfile.fromSettings(Map<String, String> values) {
    final String rawTax = values[SettingKeys.taxRate] ?? '';
    final Rate parsedTax = Rate.parsePercent(rawTax).valueOrNull ?? Rate.zero;
    final String currency = values[SettingKeys.currency] ?? defaultCurrencyCode;
    return BusinessProfile(
      name: values[SettingKeys.businessName] ?? '',
      phone: values[SettingKeys.businessPhone] ?? '',
      address: values[SettingKeys.businessAddress] ?? '',
      currencyCode: currency.isEmpty ? defaultCurrencyCode : currency,
      taxRate: parsedTax,
      receiptFooter: values[SettingKeys.receiptFooter] ?? '',
    );
  }

  /// The rows to persist for this profile.
  Map<String, String> toSettings() => <String, String>{
    SettingKeys.businessName: name,
    SettingKeys.businessPhone: phone,
    SettingKeys.businessAddress: address,
    SettingKeys.currency: currencyCode,
    SettingKeys.taxRate: _taxRateToStorage(taxRate),
    SettingKeys.receiptFooter: receiptFooter,
  };

  /// A flat, JSON-safe view for the audit payload.
  Map<String, Object?> toAuditPayload() => <String, Object?>{
    'name': name,
    'currency': currencyCode,
    'taxBasisPoints': taxRate.basisPoints,
  };

  /// Stable, hashable representation (used by tests and the audit chain).
  String toCanonicalJson() => encodeCanonicalJson(toAuditPayload());

  /// `tax_rate` is stored as a plain percent string so a human can read the
  /// database and `Rate.parsePercent` can round-trip it exactly.
  static String _taxRateToStorage(Rate rate) {
    final int abs = rate.basisPoints.abs();
    final int whole = abs ~/ 100;
    final int fraction = abs % 100;
    final String sign = rate.isNegative ? '-' : '';
    if (fraction == 0) {
      return '$sign$whole';
    }
    return '$sign$whole.${fraction.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      other is BusinessProfile &&
      other.name == name &&
      other.phone == phone &&
      other.address == address &&
      other.currencyCode == currencyCode &&
      other.taxRate == taxRate &&
      other.receiptFooter == receiptFooter;

  @override
  int get hashCode =>
      Object.hash(name, phone, address, currencyCode, taxRate, receiptFooter);

  @override
  String toString() => 'BusinessProfile(name: $name, currency: $currencyCode)';
}
