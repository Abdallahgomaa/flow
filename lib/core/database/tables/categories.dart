/// The `categories` table: the product tree (`P2-01`).
///
/// Categories nest through [parentId], which points at another row of this same
/// table; a `null` parent marks a root category. The hierarchy is expressed as a
/// self-reference rather than a separate closure table because the depth a shop
/// actually uses is small, and every read that needs a whole subtree can filter
/// on the flat list.
///
/// Rows are never hard-deleted: removing a parent would orphan its children and
/// its products, so [disabledAt] retires a category instead (AGENTS rule 4).
///
/// `@DataClassName` is required because Drift would otherwise name the generated
/// row class `Category`, which collides with the domain entity of the same name
/// in `features/catalog/domain`.
library;

import 'package:drift/drift.dart';

@DataClassName('CategoryRow')
class Categories extends Table {
  /// Primary key: a UUID v7 produced by the app's id generator.
  TextColumn get id => text()();

  /// The parent category, or `null` when this category is a root.
  ///
  /// The foreign key is enforced by SQLite (`PRAGMA foreign_keys = ON`), so a
  /// category can never point at a parent that does not exist.
  TextColumn get parentId => text().nullable().references(Categories, #id)();

  /// Display name shown in pickers, reports and the product form.
  TextColumn get name => text()();

  /// Manual ordering among siblings; lower values sort first.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// When the category was retired (UTC), or `null` while it is active.
  DateTimeColumn get disabledAt => dateTime().nullable()();

  /// When the category was created (UTC).
  DateTimeColumn get createdAt => dateTime()();

  /// When the category was last modified (UTC), or `null` if never.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
