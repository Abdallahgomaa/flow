import 'package:drift/drift.dart';

import 'tables/app_settings.dart';
import 'tables/audit_checkpoints.dart';
import 'tables/audit_log.dart';
import 'tables/barcodes.dart';
import 'tables/categories.dart';
import 'tables/price_tiers.dart';
import 'tables/products.dart';
import 'tables/roles.dart';
import 'tables/units.dart';
import 'tables/users.dart';

part 'app_database.g.dart';

/// The application's Drift database.
///
/// Owns the schema, the migrations and the connection PRAGMAs. The physical
/// connection is supplied as a [QueryExecutor] (see `DatabaseConnector`) so the
/// engine can differ between the app (SQLCipher) and tests (plain SQLite).
///
/// The catalogue's quick-search index lives in
/// `tables/product_search.drift`. drift only accepts a virtual table declared in
/// a `.drift` file, so it is pulled in with [include] instead of being listed in
/// [tables], and the fts5 module is enabled in the root `build.yaml`.
@DriftDatabase(
  tables: <Type>[
    AppSettings,
    AuditLog,
    AuditCheckpoints,
    Barcodes,
    Categories,
    PriceTiers,
    Products,
    Roles,
    Units,
    Users,
  ],
  include: <String>{'tables/product_search.drift'},
)
class AppDatabase extends _$AppDatabase {
  /// Creates a database over the injected executor [e].
  AppDatabase(super.e);

  /// v2 added `audit_log` (P0-15); v3 added `audit_checkpoints` (P0-16);
  /// v4 adds `roles` and `users` (P1-02); v5 adds `categories` and `units`
  /// (`P2-01`); v6 adds `products` (`P2-02`); v7 adds `barcodes` (`P2-03`);
  /// v8 adds `price_tiers` (`P2-04`); v9 adds `product_search` (`P2-06`).
  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _ensureAppendOnlyGuards();
      // Nothing to index yet, but the triggers have to exist before the first
      // product is inserted.
      await _ensureProductSearchTriggers();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(auditLog);
      }
      if (from < 3) {
        await m.createTable(auditCheckpoints);
      }
      if (from < 4) {
        // Roles before users: `users.role_code` references `roles.code`.
        await m.createTable(roles);
        await m.createTable(users);
      }
      if (from < 5) {
        // Categories own the product tree, units own the carton→piece chain.
        await m.createTable(categories);
        await m.createTable(units);
      }
      if (from < 6) {
        // Products reference both `categories` and `units`, so it comes last.
        await m.createTable(products);
      }
      if (from < 7) {
        // Barcodes reference `products`, so they can only follow them.
        await m.createTable(barcodes);
      }
      if (from < 8) {
        // Price tiers reference `products`, so they can only follow them.
        await m.createTable(priceTiers);
      }
      if (from < 9) {
        // The search index is created empty and then filled from the products a
        // shop already has, so upgrading never loses the ability to search.
        // The triggers are installed after the backfill: an INSERT into an fts5
        // table is what the triggers themselves do, and doing it twice would
        // index the same product twice.
        await m.createTable(productSearch);
        await _backfillProductSearch();
      }
      await _ensureAppendOnlyGuards();
      await _ensureProductSearchTriggers();
    },
    beforeOpen: (OpeningDetails details) async {
      // `foreign_keys` is a per-connection setting; re-assert it here so the
      // invariant holds even if an executor forgets it. Journal mode and
      // `secure_delete` are applied at the connection level (DatabasePragmas).
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Audit tables are append-only (AGENTS rule 4). SQLite has no deny
  /// privilege, so the guarantee is enforced with `BEFORE UPDATE/DELETE`
  /// triggers that abort the offending statement.
  Future<void> _ensureAppendOnlyGuards() async {
    for (final String table in <String>['audit_log', 'audit_checkpoints']) {
      await customStatement(
        'CREATE TRIGGER IF NOT EXISTS ${table}_no_update '
        'BEFORE UPDATE ON $table BEGIN '
        "SELECT RAISE(ABORT, '$table is append-only'); END;",
      );
      await customStatement(
        'CREATE TRIGGER IF NOT EXISTS ${table}_no_delete '
        'BEFORE DELETE ON $table BEGIN '
        "SELECT RAISE(ABORT, '$table is append-only'); END;",
      );
    }
  }

  /// Keeps `product_search` in step with `products`.
  ///
  /// The index is maintained by the database rather than by the repositories:
  /// products are written from several places (and directly in tests), and an
  /// index that has to be remembered at every call site is an index that
  /// eventually goes stale. `AFTER UPDATE OF name` keeps a price edit from
  /// touching the index at all.
  Future<void> _ensureProductSearchTriggers() async {
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS products_search_insert '
      'AFTER INSERT ON products BEGIN '
      'INSERT INTO product_search(rowid, name) VALUES (new.rowid, new.name); '
      'END;',
    );
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS products_search_update '
      'AFTER UPDATE OF name ON products BEGIN '
      'UPDATE product_search SET name = new.name WHERE rowid = new.rowid; '
      'END;',
    );
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS products_search_delete '
      'AFTER DELETE ON products BEGIN '
      'DELETE FROM product_search WHERE rowid = old.rowid; '
      'END;',
    );
  }

  /// Indexes every product for the first time, on the upgrade that adds the
  /// index. Only safe while `product_search` is empty.
  Future<void> _backfillProductSearch() async {
    await customStatement(
      'INSERT INTO product_search(rowid, name) '
      'SELECT rowid, name FROM products;',
    );
  }
}
