/// A product category as stored in the `categories` table (`P2-01`).
///
/// Pure Dart: the data layer maps a Drift row onto this entity, so nothing here
/// knows about the database. Categories nest through [parentId]; `null` marks a
/// root. They are never hard-deleted — [disabledAt] retires one while its
/// children, its products and the audit trail keep resolving it.
library;

/// An immutable category record.
final class Category {
  /// Creates a category record.
  const Category({
    required this.id,
    required this.name,
    required this.createdAt,
    this.parentId,
    this.sortOrder = 0,
    this.disabledAt,
    this.updatedAt,
  });

  /// Primary key: a UUID v7 produced by the app's id generator.
  final String id;

  /// Display name shown in pickers, reports and the product form.
  final String name;

  /// When the category was created (UTC).
  final DateTime createdAt;

  /// The parent category, or `null` when this category is a root.
  final String? parentId;

  /// Manual ordering among siblings; lower values sort first.
  final int sortOrder;

  /// When the category was retired (UTC), or `null` while it is active.
  final DateTime? disabledAt;

  /// When the category was last modified (UTC), or `null` if never.
  final DateTime? updatedAt;

  /// Whether this category sits at the top of its tree.
  bool get isRoot => parentId == null;

  /// Whether the category may no longer be assigned to a product.
  bool get isDisabled => disabledAt != null;

  @override
  bool operator ==(Object other) =>
      other is Category &&
      other.id == id &&
      other.name == name &&
      other.parentId == parentId &&
      other.sortOrder == sortOrder &&
      other.disabledAt == disabledAt &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    parentId,
    sortOrder,
    disabledAt,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'Category(id: $id, name: $name, parentId: $parentId, '
      'isDisabled: $isDisabled)';
}
