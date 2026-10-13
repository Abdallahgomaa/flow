/// The identity roles Flow ships with (`P1-01`).
///
/// A role is a named bundle of [Permission]s (see `role_matrix.dart`). Flow
/// ships four built-in roles; custom roles arrive with `P1-14`, which is why
/// authorisation is read through the `RoleMatrix` interface instead of by
/// switching on this enum.
///
/// **Provisional source:** derived from the roadmap's functional areas and
/// approved by the project owner on 2026-10-13 because the PRD is not part of
/// this repository; reconcile with the PRD once available.
library;

import 'permission.dart';

/// A job function a user account can hold.
///
/// The declaration order is intentional: the owner is created first during
/// setup and the remaining roles follow the roadmap order. Never persist the
/// index — persist [code].
enum UserRole {
  /// The privileged account created during setup; holds every permission.
  owner('owner'),

  /// Point-of-sale operator: sells, looks up products/stock/customers.
  cashier('cashier'),

  /// Stock keeper: catalogue, stock levels, suppliers and goods-in.
  inventory('inventory'),

  /// Bookkeeper: money movement, payments, expenses and reports.
  accountant('accountant');

  const UserRole(this.code);

  /// Stable machine-readable identifier, also stored as the role code in the
  /// database (`P1-02`).
  final String code;

  /// Every role keyed by [code], built once for O(1) lookups.
  static final Map<String, UserRole> _byCode = <String, UserRole>{
    for (final UserRole role in UserRole.values) role.code: role,
  };

  /// Resolves a [code] back to its role, or `null` when unknown.
  ///
  /// Custom roles (`P1-14`) are not represented by this enum, so an unknown
  /// code must degrade to `null` rather than throw.
  static UserRole? fromCode(String? code) => _byCode[code];
}
