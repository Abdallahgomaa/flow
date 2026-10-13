/// A role as stored in the `roles` table (`P1-02`).
///
/// Pure Dart: the data layer maps a Drift row to this entity, so nothing here
/// knows about the database. Roles are never hard-deleted; [disabledAt] marks a
/// role that must no longer be assigned, which keeps `users.role_code` (and the
/// audit trail) resolvable forever.
library;

/// An immutable role record.
final class Role {
  /// Creates a role record.
  const Role({
    required this.code,
    required this.name,
    required this.createdAt,
    this.description,
    this.isBuiltIn = false,
    this.disabledAt,
    this.updatedAt,
  });

  /// Stable identifier: a `UserRole.code` for the built-in roles
  /// (`owner`, `cashier`, `inventory`, `accountant`), or a slug for a custom
  /// role created in `P1-14`. This is the value stored on `users.role_code`.
  final String code;

  /// Human-readable name shown in the UI.
  final String name;

  /// When the role was created (UTC).
  final DateTime createdAt;

  /// Optional explanation of what the role is for.
  final String? description;

  /// Whether the role ships with Flow, and therefore can never be disabled.
  final bool isBuiltIn;

  /// When the role was disabled (UTC), or `null` while it is active.
  final DateTime? disabledAt;

  /// When the role was last modified (UTC), or `null` if never.
  final DateTime? updatedAt;

  /// Whether the role may no longer be assigned to a user.
  bool get isDisabled => disabledAt != null;

  @override
  bool operator ==(Object other) =>
      other is Role &&
      other.code == code &&
      other.name == name &&
      other.description == description &&
      other.isBuiltIn == isBuiltIn &&
      other.disabledAt == disabledAt &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    code,
    name,
    description,
    isBuiltIn,
    disabledAt,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'Role(code: $code, name: $name, isBuiltIn: $isBuiltIn, '
      'isDisabled: $isDisabled)';
}
