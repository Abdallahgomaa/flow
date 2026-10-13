/// The public surface of the auth feature.
///
/// Another feature may not reach into `features/auth/data/` or
/// `features/auth/presentation/` directly (`AGENTS.md` §3, enforced by
/// `tool/check_boundaries.dart`); anything it legitimately needs is re-exported
/// here. Pure value types are also reachable straight from
/// `features/auth/domain/`, which is the better choice for a feature's own
/// `domain/` layer because this barrel drags Riverpod in with it.
library;

export 'data/session_notifier.dart';
export 'domain/password_hasher.dart';
export 'domain/permission.dart';
export 'domain/role.dart';
export 'domain/role_matrix.dart';
export 'domain/session_state.dart';
export 'domain/user.dart';
export 'domain/user_role.dart';
