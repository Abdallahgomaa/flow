import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/logger.dart';

import '../domain/password_hasher.dart';

/// Argon2id-backed [PasswordHasher] (`P1-03`), the only place a secret becomes
/// something storable.
///
/// Argon2id is the password-hashing winner of the Password Hashing Competition
/// and the current OWASP recommendation. It is *memory-hard*, which is what
/// makes parallel guessing on GPUs and ASICs expensive — a plain SHA-256 would
/// run billions of candidates per second and is deliberately not used here.
///
/// ## Why the parameters live inside the encoded string
///
/// A hash is worthless if it cannot be re-proved later. The cost parameters are
/// therefore serialised into the PHC string
/// (`$argon2id$v=19$m=…,t=…,p=…$salt$digest`), so [verify] always re-derives
/// with the parameters the value was *written* with. Raising the defaults for
/// new secrets never invalidates the old ones, and a login can opportunistically
/// re-hash an outdated value after a successful check.
///
/// ## Calibration
///
/// [defaultMemoryKiB] and [defaultIterations] were measured on the reference
/// machine (a throwaway probe, recorded in `EXECUTION_STATE.md`) to land near the
/// 250 ms budget of `P1-03`. Tests inject far cheaper parameters so the suite
/// stays fast — the same seam `KeyManager` exposes.
///
/// ## Thread of execution
///
/// Deriving is CPU-bound and blocks the caller for the full cost, exactly as
/// `KeyManager` already does when it unwraps the data-encryption key. Callers
/// on the UI isolate must show progress and treat the work as awaited (the
/// login flow in `P1-11` does); they must never `await` it inside a build.
final class Argon2PasswordHasher implements PasswordHasher {
  /// Creates a hasher over the calibrated production cost.
  ///
  /// [random] is injectable so a test can make the salt reproducible; production
  /// always uses [Random.secure].
  Argon2PasswordHasher({
    this.memoryKiB = defaultMemoryKiB,
    this.iterations = defaultIterations,
    this.parallelism = defaultParallelism,
    this.hashLength = defaultHashLength,
    this.saltLength = defaultSaltLength,
    Random? random,
  }) : _random = random ?? Random.secure();

  /// Memory cost in KiB (16 MiB), calibrated to ≈250 ms on the reference machine.
  static const int defaultMemoryKiB = 16384;

  /// Time cost: how many passes over the memory block.
  static const int defaultIterations = 2;

  /// Lanes: how much parallelism a *legitimate* host may use. An attacker with
  /// more cores gains far less than a low number of memory passes would allow.
  static const int defaultParallelism = 1;

  /// Digest length in bytes (256 bits). 32 bytes is the Argon2 recommendation.
  static const int defaultHashLength = 32;

  /// Salt length in bytes (128 bits), the RFC 9106 recommendation.
  static const int defaultSaltLength = 16;

  /// Algorithm identifier written into every encoded hash.
  static const String algorithmId = 'argon2id';

  /// Argon2 version written into every encoded hash.
  static const int version = 19;

  /// Failure code when Argon2id could not run while hashing.
  static const String hashFailedCode = 'password.hashFailed';

  /// Failure code when Argon2id could not run while verifying.
  static const String verifyFailedCode = 'password.verifyFailed';

  /// Prefix of every encoded hash, for example `$argon2id$v=19$`.
  ///
  /// Written as a literal so it can be `const`. [_decode] separately validates
  /// the algorithm and version parts, and the round-trip tests would fail
  /// immediately if this ever drifted from [algorithmId] / [version].
  static const String prefix = r'$argon2id$v=19$';

  static const String _logName = 'auth.password_hasher';

  /// Memory cost in KiB used for *new* hashes.
  final int memoryKiB;

  /// Passes over the memory block used for *new* hashes.
  final int iterations;

  /// Lanes used for *new* hashes.
  final int parallelism;

  /// Digest length in bytes used for *new* hashes.
  final int hashLength;

  /// Salt length in bytes used for *new* hashes.
  final int saltLength;

  final Random _random;

  @override
  Future<Result<String>> hash(String secret) async {
    if (secret.isEmpty) {
      return const Result<String>.err(
        ValidationFailure(
          message: 'Enter a password or PIN.',
          code: PasswordHasher.emptySecretCode,
        ),
      );
    }

    try {
      final Uint8List salt = _randomBytes(saltLength);
      final List<int> digest = await _derive(
        secret: secret,
        salt: salt,
        memoryKiB: memoryKiB,
        iterations: iterations,
        parallelism: parallelism,
        hashLength: hashLength,
      );
      return Result<String>.ok(_encode(salt: salt, digest: digest));
    } on Object catch (error, stackTrace) {
      // Deliberately anonymous: no secret, no hash and no salt reaches the log.
      AppLogger.instance.error(
        'Failed to hash a secret',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<String>.err(
        CryptoFailure(
          message: 'Could not secure the secret.',
          code: hashFailedCode,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> verify({
    required String secret,
    required String encodedHash,
  }) async {
    if (secret.isEmpty) {
      // Nothing can match a blank secret; saying so as a plain mismatch avoids
      // revealing whether the stored value exists at all.
      return const Result<bool>.ok(false);
    }

    final _EncodedHash stored;
    try {
      stored = _decode(encodedHash);
    } on FormatException {
      return const Result<bool>.err(
        CryptoFailure(
          message: 'The stored secret cannot be read.',
          code: PasswordHasher.malformedHashCode,
        ),
      );
    }

    try {
      final List<int> digest = await _derive(
        secret: secret,
        salt: stored.salt,
        memoryKiB: stored.memoryKiB,
        iterations: stored.iterations,
        parallelism: stored.parallelism,
        // The stored digest length is authoritative, so a value written under a
        // different configuration still verifies byte for byte.
        hashLength: stored.digest.length,
      );
      return Result<bool>.ok(_constantTimeEquals(digest, stored.digest));
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to verify a secret',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<bool>.err(
        CryptoFailure(
          message: 'Could not check the secret.',
          code: verifyFailedCode,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Runs Argon2id with explicit parameters and returns the raw digest.
  ///
  /// The parameters are passed in rather than read from the fields because
  /// [verify] must use the cost recorded inside the stored hash, not today's
  /// defaults.
  static Future<List<int>> _derive({
    required String secret,
    required List<int> salt,
    required int memoryKiB,
    required int iterations,
    required int parallelism,
    required int hashLength,
  }) async {
    final Argon2id kdf = Argon2id(
      memory: memoryKiB,
      parallelism: parallelism,
      iterations: iterations,
      hashLength: hashLength,
    );
    final SecretKey key = await kdf.deriveKey(
      secretKey: SecretKey(utf8.encode(secret)),
      nonce: salt,
    );
    return key.extractBytes();
  }

  /// Builds the PHC string:
  /// `$argon2id$v=19$m=<KiB>,t=<iterations>,p=<lanes>$<salt>$<digest>`.
  String _encode({required List<int> salt, required List<int> digest}) =>
      '$prefix'
      'm=$memoryKiB,t=$iterations,p=$parallelism'
      '\$${_base64(salt)}\$${_base64(digest)}';

  /// Parses a PHC `argon2id` string, throwing [FormatException] when it does not
  /// match the shape [hash] writes (or names another algorithm or version).
  static _EncodedHash _decode(String encoded) {
    final List<String> parts = encoded.split(r'$');
    // A PHC string begins with '$', so the first element of the split is empty.
    if (parts.length != 6 ||
        parts[0].isNotEmpty ||
        parts[1] != algorithmId ||
        parts[2] != 'v=$version') {
      throw const FormatException('Unsupported hash format.');
    }

    final Map<String, String> parameters = <String, String>{};
    for (final String pair in parts[3].split(',')) {
      final int separator = pair.indexOf('=');
      if (separator <= 0 || separator == pair.length - 1) {
        throw const FormatException('Malformed cost parameters.');
      }
      parameters[pair.substring(0, separator)] = pair.substring(separator + 1);
    }

    final int? memoryKiB = int.tryParse(parameters['m'] ?? '');
    final int? iterations = int.tryParse(parameters['t'] ?? '');
    final int? parallelism = int.tryParse(parameters['p'] ?? '');
    if (memoryKiB == null ||
        iterations == null ||
        parallelism == null ||
        memoryKiB <= 0 ||
        iterations <= 0 ||
        parallelism <= 0) {
      throw const FormatException('Malformed cost parameters.');
    }

    final List<int> salt = _unbase64(parts[4]);
    final List<int> digest = _unbase64(parts[5]);
    if (salt.isEmpty || digest.isEmpty) {
      throw const FormatException('Empty salt or digest.');
    }

    return _EncodedHash(
      memoryKiB: memoryKiB,
      iterations: iterations,
      parallelism: parallelism,
      salt: salt,
      digest: digest,
    );
  }

  /// Compares two digests without revealing *where* they first differ.
  ///
  /// A short-circuiting comparison would leak a prefix oracle through timing,
  /// which is precisely the leak a deliberately slow hash exists to close.
  static bool _constantTimeEquals(List<int> left, List<int> right) {
    if (left.length != right.length) {
      return false;
    }
    int difference = 0;
    for (int index = 0; index < left.length; index++) {
      difference |= left[index] ^ right[index];
    }
    return difference == 0;
  }

  /// Standard base64 without the `=` padding, as the PHC format requires.
  static String _base64(List<int> bytes) =>
      base64.encode(bytes).replaceAll('=', '');

  /// Reads unpadded standard base64, restoring the padding [base64.decode] wants.
  static List<int> _unbase64(String value) {
    final int remainder = value.length % 4;
    final String padded = remainder == 0
        ? value
        : value.padRight(value.length + 4 - remainder, '=');
    return base64.decode(padded);
  }

  /// [length] cryptographically secure random bytes.
  Uint8List _randomBytes(int length) {
    final Uint8List bytes = Uint8List(length);
    for (int index = 0; index < length; index++) {
      bytes[index] = _random.nextInt(256);
    }
    return bytes;
  }
}

/// A parsed `argon2id` PHC string: the cost parameters, the salt and the digest
/// that were recovered from a stored value.
final class _EncodedHash {
  const _EncodedHash({
    required this.memoryKiB,
    required this.iterations,
    required this.parallelism,
    required this.salt,
    required this.digest,
  });

  final int memoryKiB;
  final int iterations;
  final int parallelism;
  final List<int> salt;
  final List<int> digest;
}
