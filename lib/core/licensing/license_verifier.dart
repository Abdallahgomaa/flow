import 'package:cryptography/cryptography.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';

import 'license.dart';
import 'license_key.dart';

/// Verifies a licence key **offline**: signature, product, device, expiry.
///
/// The vendor keeps the private key; the app embeds only the public key, so a
/// licence can be checked locally without any server round-trip.
final class LicenseVerifier {
  /// Creates a verifier for [product], trusting [publicKey].
  LicenseVerifier({
    required this.publicKey,
    required this.product,
    Ed25519? algorithm,
  }) : algorithm = algorithm ?? Ed25519();

  /// The vendor's Ed25519 public key.
  final SimplePublicKey publicKey;

  /// Product id this app accepts.
  final String product;

  /// Signature algorithm (injected for tests).
  final Ed25519 algorithm;

  /// Verifies [key] against [hardwareId] at [nowUtc].
  Future<Result<License>> verify({
    required ParsedLicenseKey key,
    required String hardwareId,
    required DateTime nowUtc,
  }) async {
    final bool signatureValid = await algorithm.verify(
      key.signedPayload,
      signature: Signature(key.signature, publicKey: publicKey),
    );
    if (!signatureValid) {
      return const Result<License>.err(
        CryptoFailure(message: 'the licence signature is not valid'),
      );
    }
    if (key.license.product != product) {
      return const Result<License>.err(
        ValidationFailure(message: 'the licence is for another product'),
      );
    }
    if (key.license.hardwareId != hardwareId) {
      return const Result<License>.err(
        PermissionFailure(
          permission: 'license.device',
          message: 'the licence is bound to another device',
        ),
      );
    }
    if (key.license.isExpiredAt(nowUtc)) {
      return const Result<License>.err(
        PermissionFailure(
          permission: 'license.expired',
          message: 'the licence has expired',
        ),
      );
    }
    return Result<License>.ok(key.license);
  }
}
