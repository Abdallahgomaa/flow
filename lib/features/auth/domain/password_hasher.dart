import 'package:flow/core/result/result.dart';

/// Hashes and verifies the secrets that protect an account: the login password
/// and the quick-unlock PIN (`P1-03`).
///
/// The interface is deliberately narrow and algorithm-agnostic. A caller hands
/// over plaintext exactly once, receives an opaque, self-describing string it
/// can store verbatim, and can later check a candidate against that string.
/// Nothing in `domain` names Argon2id, so the algorithm and its cost parameters
/// can change without touching a use case; the parameters travel *inside* the
/// encoded value, so what was written earlier keeps verifying.
///
/// The cost is what makes guessing expensive, so implementations are
/// deliberately slow (a quarter of a second is a feature, not a bug). Callers
/// must `await` a hasher, must never log the plaintext, and must never store
/// anything but the encoded result.
abstract interface class PasswordHasher {
  /// Failure code returned by [hash] when the secret is blank.
  ///
  /// Storing an empty secret would silently strip an account of its protection,
  /// so it is refused at the boundary instead of trusted to the caller.
  static const String emptySecretCode = 'password.emptySecret';

  /// Failure code returned by [verify] when [encodedHash] cannot be read.
  static const String malformedHashCode = 'password.hashMalformed';

  /// Encodes [secret] with a fresh random salt.
  ///
  /// The result is self-describing: it names the algorithm and its version and
  /// carries the salt and the cost parameters next to the digest, so raising
  /// the defaults later still verifies values written today.
  Future<Result<String>> hash(String secret);

  /// Whether [secret] is the one behind [encodedHash].
  ///
  /// A blank [secret] is a plain `false`: reporting a validation error here
  /// would tell an attacker that the stored secret is empty. An [encodedHash]
  /// that cannot be parsed, on the other hand, is an error, because it means
  /// stored data was damaged rather than merely wrong.
  Future<Result<bool>> verify({
    required String secret,
    required String encodedHash,
  });
}
