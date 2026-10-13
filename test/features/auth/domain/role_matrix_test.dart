import 'package:flow/features/auth/domain/permission.dart';
import 'package:flow/features/auth/domain/role_matrix.dart';
import 'package:flow/features/auth/domain/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

/// An independent restatement of the intended matrix, so this file is a real
/// oracle: if [DefaultRoleMatrix] changes, these expectations must be updated
/// deliberately (the provisional matrix is documented in
/// `docs/P1-01_permissions.md`).
const Map<UserRole, Set<Permission>> expected = <UserRole, Set<Permission>>{
  UserRole.owner: <Permission>{
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
  },
  UserRole.cashier: <Permission>{
    Permission.saleCreate,
    Permission.saleDiscount,
    Permission.saleHistoryView,
    Permission.catalogProductView,
    Permission.inventoryView,
    Permission.customerView,
    Permission.customerManage,
    Permission.printerConfigure,
  },
  UserRole.inventory: <Permission>{
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
  },
  UserRole.accountant: <Permission>{
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
  },
};

void main() {
  const RoleMatrix matrix = DefaultRoleMatrix();

  test('the owner holds every permission', () {
    expect(
      matrix.permissionsFor(UserRole.owner),
      unorderedEquals(Permission.values),
    );
  });

  test('the default matrix covers every built-in role', () {
    for (final UserRole role in UserRole.values) {
      expect(expected.keys, contains(role));
    }
  });

  group('permissionsFor', () {
    for (final MapEntry<UserRole, Set<Permission>> entry in expected.entries) {
      test('${entry.key.code} grants exactly its expected set', () {
        expect(
          matrix.permissionsFor(entry.key),
          unorderedEquals(entry.value),
          reason: 'role: ${entry.key.code}',
        );
      });
    }
  });

  // One test per cell of the role × permission table: every role is checked
  // against every permission, so a granted or denied cell can never drift
  // silently.
  group('every matrix cell', () {
    for (final MapEntry<UserRole, Set<Permission>> entry in expected.entries) {
      for (final Permission permission in Permission.values) {
        final bool granted = entry.value.contains(permission);
        test(
          '${entry.key.code} ${granted ? 'holds' : 'lacks'} ${permission.code}',
          () {
            expect(matrix.allows(entry.key, permission), granted);
          },
        );
      }
    }
  });

  test('the returned sets cannot be mutated by callers', () {
    expect(
      () => matrix.permissionsFor(UserRole.cashier).add(Permission.saleVoid),
      throwsUnsupportedError,
    );
  });
}
