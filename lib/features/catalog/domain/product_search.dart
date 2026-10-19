import 'product.dart';

/// One product a search found (`P2-06`).
final class ProductSearchHit {
  /// Creates a hit.
  const ProductSearchHit({required this.product, this.barcode});

  /// The product that matched.
  final Product product;

  /// The barcode the searched term matched, or `null` when the name is what
  /// matched.
  ///
  /// A result keeps this so the screen can say why a row is there: a scan of
  /// `6221000000001` that came back with «Milk» looks like the search ignored
  /// the term unless the label is shown next to it.
  final String? barcode;

  @override
  bool operator ==(Object other) =>
      other is ProductSearchHit &&
      other.product == product &&
      other.barcode == barcode;

  @override
  int get hashCode => Object.hash(product, barcode);

  @override
  String toString() =>
      'ProductSearchHit(product: ${product.id}, barcode: $barcode)';
}

/// Where the next page of a search continues from (`P2-06`).
///
/// The position is the pair `(name, id)` rather than an offset. Those two
/// columns are unique together, so a page boundary is a total order: a product
/// cannot be skipped, and cannot be returned twice either, even while the
/// catalogue is being edited between one page and the next. An offset could do
/// neither, because inserting a product early in the alphabet shifts every later
/// row by one.
final class ProductSearchCursor {
  /// Creates a cursor pointing at one position in the ordering.
  const ProductSearchCursor({required this.name, required this.id});

  /// The name of the last row of the previous page.
  final String name;

  /// The id of the last row of the previous page, which breaks the tie between
  /// two products sharing a name.
  final String id;

  @override
  bool operator ==(Object other) =>
      other is ProductSearchCursor && other.name == name && other.id == id;

  @override
  int get hashCode => Object.hash(name, id);

  @override
  String toString() => 'ProductSearchCursor(name: $name, id: $id)';
}

/// One page of search results (`P2-06`).
final class ProductSearchPage {
  /// Creates a page.
  const ProductSearchPage({required this.hits, this.next});

  /// A page with nothing in it, used when a search never reaches the database.
  static const ProductSearchPage empty = ProductSearchPage(
    hits: <ProductSearchHit>[],
  );

  /// The products on this page, in the order the search defined.
  final List<ProductSearchHit> hits;

  /// Where the next page starts, or `null` when this page is the last one.
  final ProductSearchCursor? next;

  /// Whether this page found nothing at all.
  bool get isEmpty => hits.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is ProductSearchPage &&
      other.next == next &&
      _sameHits(other.hits, hits);

  @override
  int get hashCode => Object.hash(Object.hashAll(hits), next);

  @override
  String toString() => 'ProductSearchPage(${hits.length} hits, next: $next)';

  /// Compares two result lists element by element.
  ///
  /// `listEquals` lives in Flutter, and this file is pure Dart (architecture
  /// rule 3), so the comparison is written out here.
  static bool _sameHits(
    List<ProductSearchHit> first,
    List<ProductSearchHit> second,
  ) {
    if (identical(first, second)) {
      return true;
    }
    if (first.length != second.length) {
      return false;
    }
    for (int index = 0; index < first.length; index++) {
      if (first[index] != second[index]) {
        return false;
      }
    }
    return true;
  }
}
