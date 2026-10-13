import 'package:flow/core/result/result.dart';

import 'user.dart';

/// Reads and changes user accounts (`P1-02`).
///
/// Every write here is one atomic, audited unit of work: the row change and its
/// audit entry commit together, or not at all (AGENTS rule 3). Accounts are
/// never hard-deleted — [disable] marks them unavailable instead, so sales
/// history and the audit trail keep resolving their author.
abstract interface class UserRepository {
  /// Failure code returned by [create] when the username already exists.
  static const String usernameTakenCode = 'user.usernameTaken';

  /// Failure code returned by [create] when the role does not exist.
  static const String roleUnknownCode = 'user.roleUnknown';

  /// Failure code returned by the reads and [disable] when no row matches.
  static const String notFoundCode = 'user.notFound';

  /// Every account, including disabled ones, oldest first.
  Future<Result<List<User>>> readAll();

  /// The account with [id], or a [NotFoundFailure] carrying [notFoundCode].
  Future<Result<User>> readById(String id);

  /// The account with [username], or a [NotFoundFailure] carrying
  /// [notFoundCode].
  Future<Result<User>> readByUsername(String username);

  /// Inserts [user] and appends one audit row for [action].
  ///
  /// [payload] is recorded verbatim in the audit entry and must stay free of
  /// personal data and secrets, so it never carries [User.username] or a
  /// credential hash.
  Future<Result<User>> create({
    required User user,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  });

  /// Logically disables the account [id] and appends an audit row for [action].
  ///
  /// Disabling an already-disabled account is a no-op and writes no audit
  /// entry, because nothing changed.
  Future<Result<void>> disable({
    required String id,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  });
}
