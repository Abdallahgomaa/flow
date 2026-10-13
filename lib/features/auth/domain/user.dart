/// A user account as stored in the `users` table (`P1-02`).
///
/// Pure Dart: the data layer maps a Drift row to this entity. The credential
/// fields ([passwordHash], [pinHash]) are opaque Argon2id PHC strings filled in
/// by `P1-03`; they are never logged and never leave the data layer.
library;

/// An immutable user account record.
final class User {
  /// Creates a user account record.
  const User({
    required this.id,
    required this.username,
    required this.displayName,
    required this.roleCode,
    required this.createdAt,
    this.passwordHash,
    this.pinHash,
    this.disabledAt,
    this.updatedAt,
  });

  /// Primary key: a UUID v7 produced by the app's id generator.
  final String id;

  /// Unique login name.
  final String username;

  /// Name shown in the UI and on receipts.
  final String displayName;

  /// The role this account holds; a `roles.code` value.
  final String roleCode;

  /// When the account was created (UTC).
  final DateTime createdAt;

  /// Argon2id hash of the login password (`P1-03`); `null` until one is set.
  final String? passwordHash;

  /// Argon2id hash of the quick-unlock PIN (`P1-03`); `null` until one is set.
  final String? pinHash;

  /// When the account was disabled (UTC), or `null` while it is active.
  final DateTime? disabledAt;

  /// When the account was last modified (UTC), or `null` if never.
  final DateTime? updatedAt;

  /// Whether the account may no longer sign in.
  bool get isDisabled => disabledAt != null;

  /// Whether the account already has a login password.
  bool get hasPassword => passwordHash != null;

  /// Whether the account already has a quick-unlock PIN.
  bool get hasPin => pinHash != null;

  @override
  bool operator ==(Object other) =>
      other is User &&
      other.id == id &&
      other.username == username &&
      other.displayName == displayName &&
      other.roleCode == roleCode &&
      other.createdAt == createdAt &&
      other.passwordHash == passwordHash &&
      other.pinHash == pinHash &&
      other.disabledAt == disabledAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    username,
    displayName,
    roleCode,
    createdAt,
    passwordHash,
    pinHash,
    disabledAt,
    updatedAt,
  );

  @override
  String toString() =>
      'User(id: $id, username: $username, roleCode: $roleCode, '
      'isDisabled: $isDisabled)';
}
