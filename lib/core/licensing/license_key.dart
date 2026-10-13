import 'dart:convert';

import 'package:flow/core/utils/canonical_json.dart';

import 'license.dart';

/// A decoded licence key plus the exact bytes its signature covers.
final class ParsedLicenseKey {
  /// Creates a parsed key.
  const ParsedLicenseKey({
    required this.license,
    required this.signedPayload,
    required this.signature,
  });

  /// The licence the key describes.
  final License license;

  /// The bytes the vendor signed (the decoded payload segment).
  final List<int> signedPayload;

  /// The Ed25519 signature bytes.
  final List<int> signature;
}

/// Wire format of a licence key.
///
/// `FLOW1.<base64url(payload)>.<base64url(signature)>` — the signature covers
/// the **encoded payload segment**, so verification never has to re-serialise
/// JSON.
abstract final class LicenseKey {
  /// Format prefix / version tag.
  static const String prefix = 'FLOW1';

  /// The bytes a signature must cover for [license].
  static List<int> signedBytes(License license) =>
      utf8.encode(encodeCanonicalJson(license.toPayload()));

  /// Serialises [license] with its Ed25519 [signature].
  static String encode({
    required License license,
    required List<int> signature,
  }) => '$prefix.${_encode(signedBytes(license))}.${_encode(signature)}';

  /// Parses [raw]; returns `null` when the key is malformed.
  static ParsedLicenseKey? tryDecode(String raw) {
    final List<String> parts = raw.trim().split('.');
    if (parts.length != 3 || parts.first != prefix) {
      return null;
    }
    try {
      final List<int> payload = _decode(parts[1]);
      final Object? decoded = jsonDecode(utf8.decode(payload));
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return ParsedLicenseKey(
        license: License.fromPayload(decoded),
        signedPayload: payload,
        signature: _decode(parts[2]),
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  static String _encode(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

  static List<int> _decode(String value) =>
      base64Url.decode(value + '=' * ((4 - value.length % 4) % 4));
}
