import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';

import '../password_hasher.dart';
import '../user.dart';
import '../user_repository.dart';

/// Authenticates an operator against a stored password or PIN.
///
/// The sign-in screen collects one username and one secret; this use case
/// answers with the authenticated [User] — ready to hand to the session — or
/// with a [Failure] the screen turns into a localised message.
///
/// A single secret field is deliberate. A POS account may hold a long password,
/// a short PIN, or both, so the secret is checked against the password first and
/// against the PIN second; the operator never has to declare which one they are
/// typing.
///
/// Nothing is written and nothing is audited here: signing in changes no row.
/// Throttling and recording failed attempts belong to `P1-08`.
final class SignIn {
  /// Creates the use case.
  const SignIn(this._users, this._hasher);

  final UserRepository _users;
  final PasswordHasher _hasher;

  /// Failure code used when the login name is missing.
  static const String usernameRequiredCode = 'signIn.usernameRequired';

  /// Failure code used when the secret is missing.
  static const String secretRequiredCode = 'signIn.secretRequired';

  /// Failure code used for an unknown account or a wrong secret.
  ///
  /// Both situations share one code on purpose: the screen must never let a
  /// caller learn whether a login name exists.
  static const String invalidCredentialsCode = 'signIn.invalidCredentials';

  /// Failure code used when a correct secret is supplied for a disabled account.
  static const String accountDisabledCode = 'signIn.accountDisabled';

  /// Signs in as [username] with [secret].
  ///
  /// The order of the checks is the security contract of this use case: the
  /// account is looked up, the secret is verified, and only then is the disabled
  /// state reported. Somebody who cannot produce the account's secret therefore
  /// learns nothing about whether the account exists or is disabled.
  Future<Result<User>> call({
    required String username,
    required String secret,
  }) async {
    final String login = username.trim();
    if (login.isEmpty) {
      return const Result<User>.err(
        ValidationFailure(
          message: 'Enter your login name.',
          code: usernameRequiredCode,
        ),
      );
    }
    if (secret.isEmpty) {
      return const Result<User>.err(
        ValidationFailure(
          message: 'Enter your password or PIN.',
          code: secretRequiredCode,
        ),
      );
    }

    final Result<User> found = await _users.readByUsername(login);

    // A real storage or crypto problem must not masquerade as a wrong secret, so
    // only the repository's "no such account" is folded into the opaque
    // credentials failure below.
    final Failure? lookupFailure = found.failureOrNull;
    if (lookupFailure != null &&
        lookupFailure.code != UserRepository.notFoundCode) {
      return Result<User>.err(lookupFailure);
    }

    final User? account = switch (found) {
      Ok<User>(:final User value) => value,
      Err<User>() => null,
    };
    if (account == null) {
      return const Result<User>.err(
        ValidationFailure(
          message: 'Unknown login name or wrong password.',
          code: invalidCredentialsCode,
        ),
      );
    }

    if (!await _holdsSecret(account, secret)) {
      return const Result<User>.err(
        ValidationFailure(
          message: 'Unknown login name or wrong password.',
          code: invalidCredentialsCode,
        ),
      );
    }

    // Identity is proven at this point, so naming the disabled state reveals
    // nothing the caller did not already know.
    if (account.isDisabled) {
      return const Result<User>.err(
        PermissionFailure(
          permission: 'auth.signIn',
          message: 'This account is disabled.',
          code: accountDisabledCode,
        ),
      );
    }

    return Result<User>.ok(account);
  }

  /// Whether [secret] matches any credential [account] holds.
  ///
  /// A wrong secret, a missing credential and an unusable stored hash are all
  /// answered the same way — "not this account's secret" — because a caller who
  /// cannot prove identity must not be able to probe what the account stores.
  Future<bool> _holdsSecret(User account, String secret) async {
    final List<String?> encodedHashes = <String?>[
      account.passwordHash,
      account.pinHash,
    ];

    for (final String? encodedHash in encodedHashes) {
      if (encodedHash == null) {
        continue;
      }
      final Result<bool> verified = await _hasher.verify(
        secret: secret,
        encodedHash: encodedHash,
      );
      if (verified case Ok<bool>(value: true)) {
        return true;
      }
    }

    return false;
  }
}
