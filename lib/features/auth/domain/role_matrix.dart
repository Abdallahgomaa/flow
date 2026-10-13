/// The role → permission matrix that authorises every guarded use case
/// (`P1-01`).
///
/// Authorisation is exposed through the [RoleMatrix] interface so that custom
/// roles (`P1-14`) or a stored, per-installation matrix can replace the default
/// without touching a single use case (project rule: depend on abstractions).
///
/// **Provisional source:** the acceptance criterion for `P1-01` is "match the
/// PRD (section 2) matrix cell by cell", but the PRD is not part of this
/// repository. [DefaultRoleMatrix] was therefore derived from the functional
/// areas the roadmap plans to ship and approved by the project owner on
/// 2026-10-13. Reconcile it with the PRD once the document is available; the
/// full table and its per-cell rationale live in `docs/P1-01_permissions.md`.
library;

import 'permission.dart';
import 'user_role.dart';

/// The authorisation contract consumed by use cases.
abstract interface class RoleMatrix {
  /// The permissions [role] holds.
  ///
  /// The returned set is unmodifiable: callers read it, they never mutate it.
  Set<Permission> permissionsFor(UserRole role);

  /// Whether [role] holds [permission].
  bool allows(UserRole role, Permission permission);
}

/// The default four-role matrix shipped with Flow.
final class DefaultRoleMatrix implements RoleMatrix {
  /// Creates the default matrix. Stateless, so a single instance is enough.
  const DefaultRoleMatrix();

  /// Every permission; the setup account is the only role that may change
  /// prices and business configuration or manage users, roles, the licence and
  /// the audit log.
  static const Set<Permission> _owner = <Permission>{
    Permission.saleCreate,
    Permission.saleDiscount,
    Permission.saleRefund,
    Permission.saleVoid,
    Permission.saleHistoryView,
    Permission.catalogProductView,
    Permission.catalogProductManage,
    Permission.catalogPriceManage,
    Permission.catalogCategoryManage,
    Permission.inventoryView,
    Permission.inventoryAdjust,
    Permission.inventoryTransfer,
    Permission.supplierManage,
    Permission.purchaseCreate,
    Permission.purchaseReceive,
    Permission.purchasePay,
    Permission.customerView,
    Permission.customerManage,
    Permission.customerPayment,
    Permission.expenseManage,
    Permission.reportSalesView,
    Permission.reportInventoryView,
    Permission.reportFinanceView,
    Permission.reportExport,
    Permission.settingsManage,
    Permission.userManage,
    Permission.roleManage,
    Permission.backupManage,
    Permission.auditView,
    Permission.licenseManage,
    Permission.printerConfigure,
  };

  /// The selling loop only: create sales, apply the permitted discount, look up
  /// catalogue/stock/customers, register a new customer and configure the
  /// printer. Refunds, voids, prices, stock adjustments and every report are
  /// withheld.
  static const Set<Permission> _cashier = <Permission>{
    Permission.saleCreate,
    Permission.saleDiscount,
    Permission.saleHistoryView,
    Permission.catalogProductView,
    Permission.inventoryView,
    Permission.customerView,
    Permission.customerManage,
    Permission.printerConfigure,
  };

  /// Goods and stock: maintain products, categories and suppliers, create and
  /// receive purchase orders, adjust and transfer stock, and read/export stock
  /// reports. Pricing, selling, paying and administration are withheld.
  static const Set<Permission> _inventory = <Permission>{
    Permission.catalogProductView,
    Permission.catalogProductManage,
    Permission.catalogCategoryManage,
    Permission.inventoryView,
    Permission.inventoryAdjust,
    Permission.inventoryTransfer,
    Permission.supplierManage,
    Permission.purchaseCreate,
    Permission.purchaseReceive,
    Permission.reportInventoryView,
    Permission.reportExport,
  };

  /// Money and reporting: refunds, sales history, supplier and customer
  /// payments, expenses, every report plus export, backups and the audit log.
  /// Selling, pricing and user administration are withheld.
  static const Set<Permission> _accountant = <Permission>{
    Permission.saleRefund,
    Permission.saleHistoryView,
    Permission.catalogProductView,
    Permission.inventoryView,
    Permission.supplierManage,
    Permission.purchaseCreate,
    Permission.purchasePay,
    Permission.customerView,
    Permission.customerManage,
    Permission.customerPayment,
    Permission.expenseManage,
    Permission.reportSalesView,
    Permission.reportInventoryView,
    Permission.reportFinanceView,
    Permission.reportExport,
    Permission.backupManage,
    Permission.auditView,
  };

  // A switch expression (not a map lookup) on purpose: it is exhaustive, so
  // adding a new [UserRole] becomes a compile-time error here instead of
  // silently granting that role no permissions.
  @override
  Set<Permission> permissionsFor(UserRole role) => switch (role) {
    UserRole.owner => _owner,
    UserRole.cashier => _cashier,
    UserRole.inventory => _inventory,
    UserRole.accountant => _accountant,
  };

  @override
  bool allows(UserRole role, Permission permission) =>
      permissionsFor(role).contains(permission);
}
