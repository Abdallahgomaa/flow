import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/uuid_v7.dart';

import '../password_hasher.dart';
import '../user.dart';
import '../user_repository.dart';
import '../user_role.dart';

/// Creates the first account — the owner — on a brand-new installation.
///
/// A fresh database holds no accounts and therefore nobody who could sign in, so
/// the app cannot open on the sign-in screen: it has to ask for the owner first.
/// This use case is that one-time door. It refuses as soon as any account exists,
/// which is what stops a later caller from quietly adding a second owner, and it
/// stores only a salted Argon2id hash produced by [PasswordHasher] — never the
/// secret itself, which never leaves this call.
final class InitializeOwner {
  /// Creates the use case.
  const InitializeOwner(
    this._repository,
    this._hasher,
    this._idGenerator,
    this._clock,
  );

  final UserRepository _repository;
  final PasswordHasher _hasher;
  final UuidV7Generator _idGenerator;
  final Clock _clock;

  /// Audit action recorded for the owner account.
  static const String auditAction = 'user.ownerInitialized';

  /// Failure code used when the login name is missing.
  static const String usernameRequiredCode = 'owner.usernameRequired';

  /// Failure code used when the login name is not a well-formed slug.
  static const String usernameInvalidCode = 'owner.usernameInvalid';

  /// Failure code used when the secret is missing.
  static const String secretRequiredCode = 'owner.secretRequired';

  /// Failure code used when the secret is shorter than [minSecretLength].
  static const String secretTooShortCode = 'owner.secretTooShort';

  /// Failure code used when the installation already has an account.
  static const String alreadyInitialisedCode = 'owner.alreadyInitialised';

  /// Shortest accepted secret.
  ///
  /// A POS password is typed many times a day, but it also guards the whole
  /// business, so a floor is worth the small amount of friction.
  static const int minSecretLength = 8;

  /// Allowed login names, matching `CreateUser` so both entry points agree.
  static final RegExp _usernamePattern = RegExp(r'^[A-Za-z0-9._-]{3,32}$');

  /// Validates the owner fields and stores the first account.
  ///
  /// Returns the stored owner on success, or a [ValidationFailure] naming the
  /// first problem through its code. The disabled state and the credential
  /// columns are decided here, not in the database layer, so the account is
  /// usable by the sign-in screen the moment it is created.
  Future<Result<User>> call({
    required String username,
    required String secret,
  }) async {
    final String login = username.trim();
    if (login.isEmpty) {
      return const Result<User>.err(
        ValidationFailure(
          message: 'Enter a login name.',
          code: usernameRequiredCode,
        ),
      );
    }
    if (!_usernamePattern.hasMatch(login)) {
      return const Result<User>.err(
        ValidationFailure(
          message: 'Use 3 to 32 letters, digits, dots, dashes or underscores.',
          code: usernameInvalidCode,
        ),
      );
    }
    if (secret.isEmpty) {
      return const Result<User>.err(
        ValidationFailure(
          message: 'Enter a password or PIN.',
          code: secretRequiredCode,
        ),
      );
    }
    if (secret.length < minSecretLength) {
      return const Result<User>.err(
        ValidationFailure(
          message: 'Use at least $minSecretLength characters.',
          code: secretTooShortCode,
        ),
      );
    }

    // The door opens exactly once: as soon as an account exists, setup is over.
    final Result<List<User>> accounts = await _repository.readAll();
    final Failure? readFailure = accounts.failureOrNull;
    if (readFailure != null) {
      return Result<User>.err(readFailure);
    }
    if (accounts.valueOrNull?.isNotEmpty ?? false) {
      return const Result<User>.err(
        ValidationFailure(
          message: 'This installation already has an account.',
          code: alreadyInitialisedCode,
        ),
      );
    }

    final Result<String> encoded = await _hasher.hash(secret);
    final Failure? hashFailure = encoded.failureOrNull;
    if (hashFailure != null) {
      return Result<User>.err(hashFailure);
    }
    final String? passwordHash = encoded.valueOrNull;
    if (passwordHash == null) {
      // `hash` only reports a problem through `Err`, which was handled above, so
      // a missing digest means the hasher broke its own contract. Refusing is
      // the only safe answer: an account with no credential could never sign in.
      return const Result<User>.err(
        CryptoFailure(message: 'Could not protect the password.'),
      );
    }

    // There is no separate display-name field yet, so the login name doubles as
    // the name shown in the UI and on receipts until `P1-11` adds editing.
    final User owner = User(
      id: _idGenerator.next(),
      username: login,
      displayName: login,
      roleCode: UserRole.owner.code,
      createdAt: _clock.nowUtc(),
      passwordHash: passwordHash,
    );

    // The audit payload carries identifiers only: the login name is personal
    // data and the credential never enters the trail.
    return _repository.create(
      user: owner,
      action: auditAction,
      payload: <String, Object?>{'id': owner.id, 'roleCode': owner.roleCode},
    );
  }
}
