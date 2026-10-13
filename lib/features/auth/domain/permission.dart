/// The functional permissions Flow checks before an operation is allowed
/// (`P1-01`).
///
/// A permission is the *unit of authorisation*: a guarded use case asks the
/// role matrix whether the current role holds the required permission and
/// rejects the call otherwise (see the project rule "permission and PIN checks
/// live inside use cases, never only in the UI").
///
/// Every value carries a stable [code] used in audit entries and in
/// `PermissionFailure`, so authorisation is never expressed with magic strings.
///
/// **Provisional source:** the acceptance criterion for `P1-01` is "match the
/// PRD (section 2) matrix cell by cell", but the PRD is not part of this
/// repository. The set below was therefore derived from the functional areas
/// the roadmap already plans to ship and approved by the project owner on
/// 2026-10-13; it must be reconciled with the PRD once that document is
/// available. See `docs/P1-01_permissions.md`.
library;

/// A single thing a user may be allowed to do.
///
/// The declaration order merely groups values by functional area (sales,
/// catalogue, inventory, purchasing, customers, finance, reporting,
/// administration) to keep the list readable; the enum has no ordering
/// semantics. Never persist the index — persist [code].
enum Permission {
  // ── Sales / point of sale ────────────────────────────────────────────────
  /// Ring up a sale and take payment.
  saleCreate('sale.create'),

  /// Apply a discount to a sale line or the whole sale.
  saleDiscount('sale.discount'),

  /// Return goods and refund money.
  saleRefund('sale.refund'),

  /// Void/cancel an already-issued sale.
  saleVoid('sale.void'),

  /// Browse previously issued sales.
  saleHistoryView('sale.history.view'),

  // ── Catalogue ───────────────────────────────────────────────────────────
  /// Browse products and their prices.
  catalogProductView('catalog.product.view'),

  /// Create and edit products (names, units, barcodes...).
  catalogProductManage('catalog.product.manage'),

  /// Change selling/purchase prices.
  catalogPriceManage('catalog.price.manage'),

  /// Manage categories and units of measure.
  catalogCategoryManage('catalog.category.manage'),

  // ── Inventory ───────────────────────────────────────────────────────────
  /// Browse stock levels and movements.
  inventoryView('inventory.view'),

  /// Adjust stock (stock counts, shrinkage, corrections).
  inventoryAdjust('inventory.adjust'),

  /// Transfer stock between warehouses/locations.
  inventoryTransfer('inventory.transfer'),

  // ── Purchasing ──────────────────────────────────────────────────────────
  /// Create and edit supplier records.
  supplierManage('supplier.manage'),

  /// Create purchase orders.
  purchaseCreate('purchase.create'),

  /// Receive goods against a purchase order.
  purchaseReceive('purchase.receive'),

  /// Pay suppliers / settle purchase balances.
  purchasePay('purchase.pay'),

  // ── Customers ───────────────────────────────────────────────────────────
  /// Browse customer records and balances.
  customerView('customer.view'),

  /// Create and edit customer records.
  customerManage('customer.manage'),

  /// Collect payments from customers / settle their balances.
  customerPayment('customer.payment'),

  // ── Finance ─────────────────────────────────────────────────────────────
  /// Record and edit expenses.
  expenseManage('expense.manage'),

  // ── Reporting ───────────────────────────────────────────────────────────
  /// View sales reports.
  reportSalesView('report.sales.view'),

  /// View stock/inventory reports.
  reportInventoryView('report.inventory.view'),

  /// View financial reports (profit, expenses, receivables...).
  reportFinanceView('report.finance.view'),

  /// Export a report to a file.
  reportExport('report.export'),

  // ── Administration ──────────────────────────────────────────────────────
  /// Change business settings (profile, currency, tax, industry mode).
  settingsManage('settings.manage'),

  /// Create, edit and disable user accounts.
  userManage('user.manage'),

  /// Define custom roles and their permissions.
  roleManage('role.manage'),

  /// Create and restore database backups.
  backupManage('backup.manage'),

  /// Read the audit log.
  auditView('audit.view'),

  /// Manage the device licence / activation.
  licenseManage('license.manage'),

  /// Configure receipt printers and other peripherals.
  printerConfigure('printer.configure');

  const Permission(this.code);

  /// Stable machine-readable identifier (e.g. `sale.create`).
  ///
  /// This is the value to persist and to hand to `PermissionFailure`.
  final String code;

  /// Every permission keyed by [code], built once for O(1) lookups.
  static final Map<String, Permission> _byCode = <String, Permission>{
    for (final Permission permission in Permission.values)
      permission.code: permission,
  };

  /// Resolves a [code] back to its permission, or `null` when unknown.
  ///
  /// Used when reading persisted data (roles are user-editable from `P1-14`
  /// onwards), so an unrecognised code must degrade to `null` rather than
  /// throw.
  static Permission? fromCode(String? code) => _byCode[code];
}
