import 'package:flow/core/result/result.dart';

import 'role.dart';

/// Reads and changes role records (`P1-02`).
///
/// Every write here is one atomic, audited unit of work: the row change and its
/// audit entry commit together, or not at all (AGENTS rule 3). Roles are never
/// hard-deleted — [disable] marks them unavailable instead, so existing users
/// and the audit trail keep resolving their `role_code`.
abstract interface class RoleRepository {
  /// Failure code returned by [create] when the role code already exists.
  static const String codeTakenCode = 'role.codeTaken';

  /// Failure code returned by [disable] for a built-in role.
  static const String builtInCode = 'role.builtIn';

  /// Failure code returned by [readByCode] and [disable] when no row matches.
  static const String notFoundCode = 'role.notFound';

  /// Every role, including disabled ones, oldest first.
  Future<Result<List<Role>>> readAll();

  /// The role with [code], or a [NotFoundFailure] carrying [notFoundCode].
  Future<Result<Role>> readByCode(String code);

  /// Inserts [role] and appends one audit row for [action].
  ///
  /// [payload] is recorded verbatim in the audit entry and must stay free of
  /// personal data.
  Future<Result<Role>> create({
    required Role role,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  });

  /// Logically disables the role with [code] and appends an audit row.
  ///
  /// Disabling an already-disabled role is a no-op and writes no audit entry,
  /// because nothing changed. Built-in roles are refused with [builtInCode].
  Future<Result<void>> disable({
    required String code,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  });
}
