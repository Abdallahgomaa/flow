import 'package:flow/core/result/result.dart';
import 'package:flow/features/catalog/domain/product_search.dart';
import 'package:flow/features/catalog/domain/product_search_repository.dart';
import 'package:flow/features/catalog/domain/use_cases/rebuild_product_search_index.dart';
import 'package:flow/features/catalog/domain/use_cases/search_products.dart';
import 'package:flutter_test/flutter_test.dart';

/// Covers `P2-06` at the use-case boundary: what the search asks the index for,
/// and what it refuses to ask for at all.
void main() {
  late _RecordingSearchRepository repository;
  late SearchProducts searchProducts;
  late RebuildProductSearchIndex rebuildIndex;

  setUp(() {
    repository = _RecordingSearchRepository();
    searchProducts = SearchProducts(repository);
    rebuildIndex = RebuildProductSearchIndex(repository);
  });

  test('trims the term before asking the index', () async {
    await searchProducts(term: '  milk\n');

    expect(repository.term, 'milk');
    expect(repository.searchCalls, 1);
  });

  test('answers an empty term without reaching the repository', () async {
    final Result<ProductSearchPage> result = await searchProducts(term: '   ');

    expect(repository.searchCalls, 0);
    expect(result.valueOrNull, ProductSearchPage.empty);
  });

  test('bounds a page that is too large and one that is too small', () async {
    await searchProducts(term: 'milk', limit: 5000);
    expect(repository.limit, SearchProducts.maxLimit);

    await searchProducts(term: 'milk', limit: 0);
    expect(repository.limit, 1);

    await searchProducts(term: 'milk', limit: -3);
    expect(repository.limit, 1);
  });

  test('asks for the default page when no size is given', () async {
    await searchProducts(term: 'milk');

    expect(repository.limit, SearchProducts.defaultLimit);
  });

  test('passes the cursor of the previous page on', () async {
    const ProductSearchCursor cursor = ProductSearchCursor(
      name: 'Milk',
      id: 'p1',
    );

    await searchProducts(term: 'milk', after: cursor);

    expect(repository.after, cursor);
  });

  test('returns the page the index answered with', () async {
    repository.page = const ProductSearchPage(
      hits: <ProductSearchHit>[],
      next: ProductSearchCursor(name: 'Milk', id: 'p1'),
    );

    final Result<ProductSearchPage> result = await searchProducts(term: 'milk');

    expect(result.valueOrNull, repository.page);
  });

  test('rebuilding the index is a call on the repository', () async {
    final Result<void> result = await rebuildIndex();

    expect(repository.rebuildCalls, 1);
    expect(result.isOk, isTrue);
  });
}

/// A [ProductSearchRepository] that records what it was asked for instead of
/// answering from a database.
final class _RecordingSearchRepository implements ProductSearchRepository {
  ProductSearchPage page = ProductSearchPage.empty;

  int searchCalls = 0;
  int rebuildCalls = 0;

  String? term;
  int? limit;
  ProductSearchCursor? after;

  @override
  Future<Result<ProductSearchPage>> search({
    required String term,
    required int limit,
    ProductSearchCursor? after,
  }) async {
    searchCalls++;
    this.term = term;
    this.limit = limit;
    this.after = after;
    return Result<ProductSearchPage>.ok(page);
  }

  @override
  Future<Result<void>> rebuild() async {
    rebuildCalls++;
    return const Result<void>.ok(null);
  }
}
