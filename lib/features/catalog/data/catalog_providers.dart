import 'package:flow/core/database/database_providers.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/utils_providers.dart';
import 'package:flow/features/settings/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/barcode_repository.dart';
import '../domain/category.dart';
import '../domain/category_repository.dart';
import '../domain/product.dart';
import '../domain/product_repository.dart';
import '../domain/product_search_repository.dart';
import '../domain/tier_price_repository.dart';
import '../domain/unit.dart';
import '../domain/unit_repository.dart';
import '../domain/use_cases/convert_quantity.dart';
import '../domain/use_cases/create_barcode.dart';
import '../domain/use_cases/create_category.dart';
import '../domain/use_cases/create_product.dart';
import '../domain/use_cases/create_tier_price.dart';
import '../domain/use_cases/create_unit.dart';
import '../domain/use_cases/disable_barcode.dart';
import '../domain/use_cases/disable_category.dart';
import '../domain/use_cases/disable_product.dart';
import '../domain/use_cases/disable_tier_price.dart';
import '../domain/use_cases/disable_unit.dart';
import '../domain/use_cases/ensure_default_stock_unit.dart';
import '../domain/use_cases/find_barcode_by_code.dart';
import '../domain/use_cases/load_barcodes_for_product.dart';
import '../domain/use_cases/load_categories.dart';
import '../domain/use_cases/load_product_by_id.dart';
import '../domain/use_cases/load_products.dart';
import '../domain/use_cases/load_tier_prices_for_product.dart';
import '../domain/use_cases/load_units.dart';
import '../domain/use_cases/rebuild_product_search_index.dart';
import '../domain/use_cases/search_products.dart';
import '../domain/use_cases/select_price.dart';
import '../domain/use_cases/update_product.dart';
import '../domain/use_cases/update_tier_price.dart';
import 'drift_barcode_repository.dart';
import 'drift_category_repository.dart';
import 'drift_product_repository.dart';
import 'drift_product_search_repository.dart';
import 'drift_tier_price_repository.dart';
import 'drift_unit_repository.dart';

part 'catalog_providers.g.dart';

/// The Drift-backed [CategoryRepository].
///
/// Kept alive so every consumer shares one repository and one audit writer for
/// the whole session.
@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) => DriftCategoryRepository(
  database: ref.watch(appDatabaseProvider),
  unitOfWork: ref.watch(unitOfWorkProvider),
  auditService: ref.watch(auditServiceProvider),
  clock: ref.watch(clockProvider),
);

/// The Drift-backed [UnitRepository].
@Riverpod(keepAlive: true)
UnitRepository unitRepository(Ref ref) => DriftUnitRepository(
  database: ref.watch(appDatabaseProvider),
  unitOfWork: ref.watch(unitOfWorkProvider),
  auditService: ref.watch(auditServiceProvider),
  clock: ref.watch(clockProvider),
);

/// The Drift-backed [ProductRepository].
///
/// The shop currency decides what a stored price means, so the repository also
/// receives the settings use case that reads the business profile.
@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) => DriftProductRepository(
  database: ref.watch(appDatabaseProvider),
  unitOfWork: ref.watch(unitOfWorkProvider),
  auditService: ref.watch(auditServiceProvider),
  clock: ref.watch(clockProvider),
  loadBusinessProfile: ref.watch(loadBusinessProfileProvider),
);

/// The Drift-backed [BarcodeRepository].
///
/// A label is an identity, not a price, so nothing here needs the shop profile.
@Riverpod(keepAlive: true)
BarcodeRepository barcodeRepository(Ref ref) => DriftBarcodeRepository(
  database: ref.watch(appDatabaseProvider),
  unitOfWork: ref.watch(unitOfWorkProvider),
  auditService: ref.watch(auditServiceProvider),
  clock: ref.watch(clockProvider),
);

/// The use case that reads the category tree.
@Riverpod(keepAlive: true)
LoadCategories loadCategories(Ref ref) =>
    LoadCategories(ref.watch(categoryRepositoryProvider));

/// The use case that adds a category.
///
/// It owns identity, so it needs the same clock that seeds the UUID v7 that
/// orders the row.
@Riverpod(keepAlive: true)
CreateCategory createCategory(Ref ref) => CreateCategory(
  ref.watch(categoryRepositoryProvider),
  ref.watch(idGeneratorProvider),
  ref.watch(clockProvider),
);

/// The use case that retires a category.
@Riverpod(keepAlive: true)
DisableCategory disableCategory(Ref ref) =>
    DisableCategory(ref.watch(categoryRepositoryProvider));

/// The use case that reads the units of measure.
@Riverpod(keepAlive: true)
LoadUnits loadUnits(Ref ref) => LoadUnits(ref.watch(unitRepositoryProvider));

/// The use case that adds a unit of measure.
@Riverpod(keepAlive: true)
CreateUnit createUnit(Ref ref) =>
    CreateUnit(ref.watch(unitRepositoryProvider), ref.watch(clockProvider));

/// The use case that retires a unit of measure.
@Riverpod(keepAlive: true)
DisableUnit disableUnit(Ref ref) =>
    DisableUnit(ref.watch(unitRepositoryProvider));

/// The use case that converts a quantity between two units.
@Riverpod(keepAlive: true)
ConvertQuantity convertQuantity(Ref ref) =>
    ConvertQuantity(ref.watch(unitRepositoryProvider));

/// The use case that provisions the default stock unit (`P2-06` follow-up).
///
/// A product cannot be stored without a stock unit, and Phase 2 ships no unit
/// screen, so the form asks this to make sure at least one unit exists. It is
/// idempotent and audited through [CreateUnit], never through a repository of
/// its own.
@Riverpod(keepAlive: true)
EnsureDefaultStockUnit ensureDefaultStockUnit(Ref ref) =>
    EnsureDefaultStockUnit(
      ref.watch(loadUnitsProvider),
      ref.watch(createUnitProvider),
    );

/// The category tree as a value a widget can watch.
///
/// The synchronous [loadCategories] hands out the use case; this provider runs
/// it, so a widget or the router can watch the result without calling into the
/// database itself. Kept alive so a single read serves the whole session.
@Riverpod(keepAlive: true)
Future<Result<List<Category>>> allCategories(Ref ref) =>
    ref.watch(loadCategoriesProvider)();

/// The units of measure as a value a widget can watch.
@Riverpod(keepAlive: true)
Future<Result<List<Unit>>> allUnits(Ref ref) => ref.watch(loadUnitsProvider)();

/// The use case that reads the catalogue.
@Riverpod(keepAlive: true)
LoadProducts loadProducts(Ref ref) =>
    LoadProducts(ref.watch(productRepositoryProvider));

/// The use case that adds a product.
///
/// It owns identity, so it needs the same clock that seeds the UUID v7 that
/// orders the row.
@Riverpod(keepAlive: true)
CreateProduct createProduct(Ref ref) => CreateProduct(
  ref.watch(productRepositoryProvider),
  ref.watch(idGeneratorProvider),
  ref.watch(clockProvider),
);

/// The use case that edits a product.
@Riverpod(keepAlive: true)
UpdateProduct updateProduct(Ref ref) => UpdateProduct(
  ref.watch(productRepositoryProvider),
  ref.watch(clockProvider),
);

/// The use case that retires a product.
@Riverpod(keepAlive: true)
DisableProduct disableProduct(Ref ref) =>
    DisableProduct(ref.watch(productRepositoryProvider));

/// The catalogue as a value a widget can watch.
///
/// The synchronous [loadProducts] hands out the use case; this provider runs it,
/// so a widget can watch the result without calling into the database itself.
@Riverpod(keepAlive: true)
Future<Result<List<Product>>> allProducts(Ref ref) =>
    ref.watch(loadProductsProvider)();

/// The use case that reads one product by id.
///
/// The list can show a product from what it already loaded; the edit form cannot,
/// because a save must send back a complete product — including the price a
/// price-blind role is not allowed to see. This is the read that carries it.
@Riverpod(keepAlive: true)
LoadProductById loadProductById(Ref ref) =>
    LoadProductById(ref.watch(productRepositoryProvider));

/// The use case that reads the labels a product carries.
@Riverpod(keepAlive: true)
LoadBarcodesForProduct loadBarcodesForProduct(Ref ref) =>
    LoadBarcodesForProduct(ref.watch(barcodeRepositoryProvider));

/// The use case that resolves a scanned code.
///
/// It is also how a rejected duplicate is explained: the caller runs it with the
/// code that was refused and reaches the product that already owns it.
@Riverpod(keepAlive: true)
FindBarcodeByCode findBarcodeByCode(Ref ref) =>
    FindBarcodeByCode(ref.watch(barcodeRepositoryProvider));

/// The use case that links a new label to a product.
///
/// It owns identity, so it needs the same clock that seeds the UUID v7 that
/// orders the row.
@Riverpod(keepAlive: true)
CreateBarcode createBarcode(Ref ref) => CreateBarcode(
  ref.watch(barcodeRepositoryProvider),
  ref.watch(idGeneratorProvider),
  ref.watch(clockProvider),
);

/// The use case that retires a label.
@Riverpod(keepAlive: true)
DisableBarcode disableBarcode(Ref ref) =>
    DisableBarcode(ref.watch(barcodeRepositoryProvider));

/// The Drift-backed [TierPriceRepository].
///
/// A band's stored minor units only become a `Money` with the shop currency, so
/// the repository also receives the settings use case that reads the profile.
@Riverpod(keepAlive: true)
TierPriceRepository tierPriceRepository(Ref ref) => DriftTierPriceRepository(
  database: ref.watch(appDatabaseProvider),
  unitOfWork: ref.watch(unitOfWorkProvider),
  auditService: ref.watch(auditServiceProvider),
  clock: ref.watch(clockProvider),
  loadBusinessProfile: ref.watch(loadBusinessProfileProvider),
);

/// The use case that reads the price bands a product carries.
@Riverpod(keepAlive: true)
LoadTierPricesForProduct loadTierPricesForProduct(Ref ref) =>
    LoadTierPricesForProduct(ref.watch(tierPriceRepositoryProvider));

/// The use case that adds a price band.
///
/// It owns identity, so it needs the same clock that seeds the UUID v7 that
/// orders the row.
@Riverpod(keepAlive: true)
CreateTierPrice createTierPrice(Ref ref) => CreateTierPrice(
  ref.watch(tierPriceRepositoryProvider),
  ref.watch(idGeneratorProvider),
  ref.watch(clockProvider),
);

/// The use case that edits a price band.
@Riverpod(keepAlive: true)
UpdateTierPrice updateTierPrice(Ref ref) => UpdateTierPrice(
  ref.watch(tierPriceRepositoryProvider),
  ref.watch(clockProvider),
);

/// The use case that retires a price band.
@Riverpod(keepAlive: true)
DisableTierPrice disableTierPrice(Ref ref) =>
    DisableTierPrice(ref.watch(tierPriceRepositoryProvider));

/// The use case that picks the price for a quantity on a tier.
///
/// It reads the product only for its own sale price, which is the fallback when
/// no band of the requested tier applies.
@Riverpod(keepAlive: true)
SelectPrice selectPrice(Ref ref) => SelectPrice(
  ref.watch(tierPriceRepositoryProvider),
  ref.watch(productRepositoryProvider),
);

/// The Drift-backed [ProductSearchRepository].
///
/// Reading a derived index is not a business write, so unlike the other
/// repositories here it takes no audit service and no clock: a rebuild only
/// re-reads rows `products` already holds. The settings use case is still
/// injected, because a hit reports a price and a price needs a currency.
@Riverpod(keepAlive: true)
ProductSearchRepository productSearchRepository(Ref ref) =>
    DriftProductSearchRepository(
      database: ref.watch(appDatabaseProvider),
      unitOfWork: ref.watch(unitOfWorkProvider),
      loadBusinessProfile: ref.watch(loadBusinessProfileProvider),
    );

/// The use case that answers the quick-search box (`P2-06`).
///
/// It owns the page bounds, so the screen cannot ask for a page the search was
/// never meant to serve.
@Riverpod(keepAlive: true)
SearchProducts searchProducts(Ref ref) =>
    SearchProducts(ref.watch(productSearchRepositoryProvider));

/// The use case that rebuilds the search index from `products` (`P2-06`).
///
/// Kept as a use case rather than as a call on the repository so repairing a
/// degraded index is an explicit decision a screen makes, not something a read
/// can trigger behind the caller's back.
@Riverpod(keepAlive: true)
RebuildProductSearchIndex rebuildProductSearchIndex(Ref ref) =>
    RebuildProductSearchIndex(ref.watch(productSearchRepositoryProvider));
