/// A signed, offline licence bound to a single device.
///
/// The licence is a plain value object: everything interesting (verifying the
/// signature, checking the device and the expiry) happens in `LicenseVerifier`
/// and `LicenseService`.
final class License {
  /// Creates a licence.
  const License({
    required this.id,
    required this.product,
    required this.hardwareId,
    required this.issuedAt,
    this.expiresAt,
    this.features = const <String>{},
    this.version = 1,
  });

  /// Reads a licence from the JSON payload it was signed as.
  ///
  /// Throws when the payload is malformed; callers that must not throw use
  /// `LicenseKey.tryDecode`, which maps such failures to `null`.
  factory License.fromPayload(Map<String, dynamic> json) => License(
    version: json['v'] as int? ?? 1,
    id: json['id'] as String,
    product: json['product'] as String,
    hardwareId: json['hwid'] as String,
    issuedAt: DateTime.parse(json['issuedAt'] as String).toUtc(),
    expiresAt: json['expiresAt'] == null
        ? null
        : DateTime.parse(json['expiresAt'] as String).toUtc(),
    features: <String>{
      ...?(json['features'] as List<dynamic>?)?.map(
        (dynamic value) => value as String,
      ),
    },
  );

  /// Payload format version.
  final int version;

  /// Vendor-assigned licence id.
  final String id;

  /// Product this licence is valid for (e.g. `flow-pos`).
  final String product;

  /// The device HWID this licence is bound to.
  final String hardwareId;

  /// When the licence was issued (UTC).
  final DateTime issuedAt;

  /// When it stops being valid (UTC); `null` means perpetual.
  final DateTime? expiresAt;

  /// Feature flags unlocked by the licence.
  final Set<String> features;

  /// Whether the licence never expires.
  bool get isPerpetual => expiresAt == null;

  /// Whether the licence has expired at [nowUtc].
  bool isExpiredAt(DateTime nowUtc) {
    final DateTime? expiry = expiresAt;
    return expiry != null && !nowUtc.isBefore(expiry);
  }

  /// The canonical payload that gets signed and stored.
  Map<String, Object?> toPayload() => <String, Object?>{
    'v': version,
    'id': id,
    'product': product,
    'hwid': hardwareId,
    'issuedAt': issuedAt.toUtc().toIso8601String(),
    'expiresAt': expiresAt?.toUtc().toIso8601String(),
    'features': features.toList()..sort(),
  };
}
