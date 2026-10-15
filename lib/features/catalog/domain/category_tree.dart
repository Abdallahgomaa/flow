/// Nests a flat list of categories into the tree the UI shows (`P2-01`).
///
/// The nesting lives in `domain/` rather than in a widget so the ordering and
/// the handling of orphans and loops are testable as plain data.
library;

import 'category.dart';

/// One node of a category forest.
final class CategoryNode {
  /// Creates a node.
  const CategoryNode({required this.category, required this.children});

  /// The category at this node.
  final Category category;

  /// The nodes hanging directly off [category], in display order.
  final List<CategoryNode> children;

  @override
  String toString() =>
      'CategoryNode(${category.name}, ${children.length} children)';
}

/// Builds forests of [CategoryNode] out of a flat list.
abstract final class CategoryTree {
  const CategoryTree._();

  /// Nests [categories] into roots plus descendants.
  ///
  /// Siblings keep the incoming order, which the repository has already sorted
  /// by `sortOrder` and then by name. A category whose parent is missing from
  /// [categories], or that is trapped in a parent loop, is returned as a root
  /// instead of being dropped, so a corrupt row can never hide data or make the
  /// builder recurse forever.
  static List<CategoryNode> build(List<Category> categories) {
    final Map<String, Category> byId = <String, Category>{
      for (final Category category in categories) category.id: category,
    };
    final Map<String, List<Category>> childrenOf = <String, List<Category>>{};
    final List<Category> roots = <Category>[];
    for (final Category category in categories) {
      final String? parentId = category.parentId;
      if (parentId == null || !byId.containsKey(parentId)) {
        roots.add(category);
      } else {
        childrenOf.putIfAbsent(parentId, () => <Category>[]).add(category);
      }
    }

    final Set<String> visited = <String>{};

    CategoryNode visit(Category category) {
      visited.add(category.id);
      final List<CategoryNode> children = <CategoryNode>[];
      for (final Category child
          in childrenOf[category.id] ?? const <Category>[]) {
        // A child that is already placed would close a loop; it stays out of
        // this branch and is promoted to a root by the second pass below.
        if (!visited.contains(child.id)) {
          children.add(visit(child));
        }
      }
      return CategoryNode(category: category, children: children);
    }

    final List<CategoryNode> forest = <CategoryNode>[];
    for (final Category root in roots) {
      if (!visited.contains(root.id)) {
        forest.add(visit(root));
      }
    }
    for (final Category category in categories) {
      if (!visited.contains(category.id)) {
        forest.add(visit(category));
      }
    }
    return forest;
  }
}
