import 'package:flow/features/catalog/domain/category.dart';
import 'package:flow/features/catalog/domain/category_tree.dart';
import 'package:flutter_test/flutter_test.dart';

/// `CategoryTree.build` turns the flat table into the forest the UI walks. These
/// tests pin the shape it must always produce, including for a catalogue that
/// was corrupted by a bad import (`P2-01`).
void main() {
  final DateTime createdAt = DateTime.utc(2026, 5, 1);

  Category row(String id, {String? parentId, int sortOrder = 0}) => Category(
    id: id,
    name: id,
    createdAt: createdAt,
    parentId: parentId,
    sortOrder: sortOrder,
  );

  /// Flattens a forest into the ids it holds, depth first.
  List<String> ids(List<CategoryNode> nodes) => <String>[
    for (final CategoryNode node in nodes) ...<String>[
      node.category.id,
      ...ids(node.children),
    ],
  ];

  test('an empty catalogue builds an empty forest', () {
    expect(CategoryTree.build(<Category>[]), isEmpty);
  });

  test('children nest under their parent', () {
    final List<CategoryNode> forest = CategoryTree.build(<Category>[
      row('food'),
      row('drinks'),
      row('rice', parentId: 'food'),
      row('basmati', parentId: 'rice'),
      row('water', parentId: 'drinks'),
    ]);

    expect(ids(forest), <String>['food', 'rice', 'basmati', 'drinks', 'water']);
  });

  test('siblings keep the order the catalogue supplied', () {
    // Ordering is the repository's job (`readAll` sorts by sort order then
    // name); the tree only nests, so it must not reorder anything.
    final List<CategoryNode> forest = CategoryTree.build(<Category>[
      row('drinks', sortOrder: 0),
      row('food', sortOrder: 1),
    ]);

    expect(ids(forest), <String>['drinks', 'food']);
  });

  test('a row whose parent is missing becomes a root', () {
    final List<CategoryNode> forest = CategoryTree.build(<Category>[
      row('rice', parentId: 'ghost'),
    ]);

    expect(ids(forest), <String>['rice']);
  });

  test('rows caught in a parent loop are kept, never dropped', () {
    final List<CategoryNode> forest = CategoryTree.build(<Category>[
      row('a', parentId: 'b'),
      row('b', parentId: 'a'),
    ]);

    expect(ids(forest)..sort(), <String>['a', 'b']);
  });

  test('every row appears exactly once, even in a corrupt catalogue', () {
    final List<Category> rows = <Category>[
      row('food'),
      row('rice', parentId: 'food'),
      row('orphan', parentId: 'missing'),
      row('a', parentId: 'b'),
      row('b', parentId: 'a'),
    ];

    final List<String> flattened = ids(CategoryTree.build(rows));

    expect(flattened, hasLength(rows.length));
    expect(
      flattened.toSet(),
      rows.map((Category category) => category.id).toSet(),
    );
  });
}
