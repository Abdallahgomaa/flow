/// The catalogue's screen-facing providers (`P2-05`).
///
/// These sit between the closed use cases and the screens. They exist so a
/// widget never assembles business data itself: they resolve the labels the list
/// needs, and they apply the price-visibility rule once, through
/// [ProductView], instead of leaving it to each widget to remember.
///
/// They are deliberately **not** kept alive. Leaving the products destination
/// disposes them, and coming back re-reads the database, which is what makes the
/// wiring verifiably live rather than a cached copy that happens to look right.
/// The permission checks alone are kept alive, because they are cheap and change
/// only when the session does.
library;

import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/features/auth/auth.dart';
import 'package:flow/features/settings/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/catalog_providers.dart';
import '../domain/barcode.dart';
import '../domain/category.dart';
import '../domain/price_tier.dart';
import '../domain/product.dart';
import '../domain/product_repository.dart';
import '../domain/unit.dart';
import 'product_view.dart';

part 'catalog_ui_providers.g.dart';

/// Failure used when a product that was listed cannot be found any more.
const NotFoundFailure _productGone = NotFoundFailure(
  message: 'That product no longer exists.',
  code: ProductRepository.notFoundCode,
);

/// Failure used when a role tries to reach data it may not manage.
PermissionFailure get _notAllowed => PermissionFailure(
  message: 'You do not have permission to do that.',
  permission: Permission.catalogProductManage.code,
);

/// Whether the signed-in role may browse the catalogue at all.
///
/// The shell decides what to render and this decides what to offer; neither is
/// the security boundary on its own, which is why the data layer re-checks.
@Riverpod(keepAlive: true)
bool canViewProducts(Ref ref) => ref
    .watch(sessionPermissionsProvider)
    .contains(Permission.catalogProductView);

/// Whether the signed-in role may create and edit products.
@Riverpod(keepAlive: true)
bool canManageProducts(Ref ref) => ref
    .watch(sessionPermissionsProvider)
    .contains(Permission.catalogProductManage);

/// Whether the signed-in role may see selling and cost prices.
///
/// It is a permission of its own (`catalogPriceManage`) rather than a side
/// effect of managing products, because the two genuinely differ: the stock
/// specialist maintains the catalogue without ever seeing what it is worth.
@Riverpod(keepAlive: true)
bool canViewPrices(Ref ref) => ref
    .watch(sessionPermissionsProvider)
    .contains(Permission.catalogPriceManage);

/// The catalogue for the list screen, with the price rule already applied.
///
/// The product read is the one that can fail the screen. The category and unit
/// lookups are treated as decoration: if they fail the list still renders, just
/// without labels, because a product with no category name is far better than an
/// empty screen.
@riverpod
Future<Result<List<ProductView>>> productList(Ref ref) async {
  final bool showPrices = ref.watch(canViewPricesProvider);

  final Result<List<Product>> products = await ref.watch(
    allProductsProvider.future,
  );
  final List<Product>? rows = products.valueOrNull;
  if (rows == null) {
    return Result<List<ProductView>>.err(products.failureOrNull!);
  }

  final Map<String, String> categories = _names<Category>(
    (await ref.watch(allCategoriesProvider.future)).valueOrNull,
    (Category category) => category.id,
    (Category category) => category.name,
  );
  final Map<String, String> units = _names<Unit>(
    (await ref.watch(allUnitsProvider.future)).valueOrNull,
    (Unit unit) => unit.code,
    (Unit unit) => unit.name,
  );

  return Result<List<ProductView>>.ok(<ProductView>[
    for (final Product product in rows)
      ProductView.from(
        product,
        showPrices: showPrices,
        categoryName: _lookup(categories, product.categoryId),
        stockUnitName: _lookup(units, product.stockUnitCode),
        purchaseUnitName: _lookup(units, product.purchaseUnitCode),
      ),
  ]);
}

/// One product for the details screen, carrying the same price rule.
///
/// It reads from the list rather than opening a second read of its own: the
/// product the user tapped is the product the screen shows, and the price rule
/// stays in exactly one place.
@riverpod
Future<Result<ProductView>> productDetail(Ref ref, String id) async {
  final Result<List<ProductView>> all = await ref.watch(
    productListProvider.future,
  );

  return all.flatMap((List<ProductView> views) {
    for (final ProductView view in views) {
      if (view.id == id) {
        return Result<ProductView>.ok(view);
      }
    }
    return const Result<ProductView>.err(_productGone);
  });
}

/// The price bands of one product, with the price rule applied.
@riverpod
Future<Result<List<TierPriceView>>> productTierPrices(
  Ref ref,
  String productId,
) async {
  final bool showPrices = ref.watch(canViewPricesProvider);

  final Result<List<TierPrice>> bands = await ref.watch(
    loadTierPricesForProductProvider,
  )(productId);

  return bands.map(
    (List<TierPrice> list) => <TierPriceView>[
      for (final TierPrice band in list)
        TierPriceView.from(band, showPrices: showPrices),
    ],
  );
}

/// The labels a product carries. A barcode holds no money, so it needs no rule.
@riverpod
Future<Result<List<Barcode>>> productBarcodes(Ref ref, String productId) =>
    ref.watch(loadBarcodesForProductProvider)(productId);

/// The stored product behind an edit, for the save path only.
///
/// It exists so a save can carry values the editor was not allowed to see —
/// above all the price — through untouched, since the update use case requires
/// one. The gate is not the UI: without `catalogProductManage` this refuses,
/// so the privileged read cannot be reached at all. A screen must never render a
/// field of this object; display goes through [ProductView].
@riverpod
Future<Result<Product>> productForEdit(Ref ref, String id) async {
  if (!ref.watch(canManageProductsProvider)) {
    return Result<Product>.err(_notAllowed);
  }
  return ref.watch(loadProductByIdProvider)(id);
}

/// The currency the shop prices in.
///
/// Money is stored as minor units and the currency is deliberately never a
/// column, so a screen that turns typed text into money has to ask. It is read
/// from the business profile rather than cached, for the same reason the
/// repositories do not cache it: changing the setting must change the money.
@riverpod
Future<Result<Currency>> shopCurrency(Ref ref) async {
  final Result<BusinessProfile> profile = await ref.watch(
    loadBusinessProfileProvider,
  )();

  return profile.map(
    (BusinessProfile value) => _currencyByCode(value.currencyCode),
  );
}

/// Everything the create form needs before it can render.
@riverpod
Future<Result<ProductFormData>> newProductForm(Ref ref) =>
    _formData(ref, productId: null);

/// Everything the edit form needs before it can render.
///
/// Two providers rather than one family keyed on a nullable id: a form that
/// creates has no product to read, and saying that in the type is clearer than a
/// `null` that happens to mean "not editing".
@riverpod
Future<Result<ProductFormData>> editProductForm(Ref ref, String productId) =>
    _formData(ref, productId: productId);

/// Builds a form's inputs: the shop's currency, the option lists, and — when
/// there is one to edit — the product itself.
///
/// The product read is the one thing that fails for a missing product; a missing
/// category list is decoration, so a catalogue with no categories still lets a
/// product be created. The stock unit is different: it is a required column with
/// a foreign key behind it, so before the lists are read the form makes sure the
/// shop owns at least one unit (`P2-06` follow-up). That call is idempotent and
/// writes nothing once a unit exists.
Future<Result<ProductFormData>> _formData(
  Ref ref, {
  required String? productId,
}) async {
  final Result<Currency> currency = await ref.watch(
    shopCurrencyProvider.future,
  );
  final Currency? shopCurrency = currency.valueOrNull;
  if (shopCurrency == null) {
    return Result<ProductFormData>.err(currency.failureOrNull!);
  }

  final Result<void> provisioned = await ref.watch(
    ensureDefaultStockUnitProvider,
  )();
  if (provisioned case Err<void>(:final Failure failure)) {
    return Result<ProductFormData>.err(failure);
  }

  final List<Category> categories =
      (await ref.watch(allCategoriesProvider.future)).valueOrNull ??
      const <Category>[];
  final List<Unit> units =
      (await ref.watch(allUnitsProvider.future)).valueOrNull ?? const <Unit>[];

  if (productId == null) {
    return Result<ProductFormData>.ok(
      ProductFormData(
        currency: shopCurrency,
        categories: categories,
        units: units,
      ),
    );
  }

  final Result<ProductView> product = await ref.watch(
    productDetailProvider(productId).future,
  );

  return product.map(
    (ProductView value) => ProductFormData(
      currency: shopCurrency,
      categories: categories,
      units: units,
      product: value,
    ),
  );
}

/// Maps a list of entities to `key → label`, or an empty map when it is absent.
Map<String, String> _names<T>(
  List<T>? items,
  String Function(T item) key,
  String Function(T item) label,
) {
  if (items == null) {
    return const <String, String>{};
  }
  return <String, String>{for (final T item in items) key(item): label(item)};
}

/// Looks a label up, treating a missing id and a missing label the same way.
String? _lookup(Map<String, String> labels, String? id) =>
    id == null ? null : labels[id];

/// Looks a currency up by its ISO code.
///
/// It falls back to USD exactly the way the repositories do, so a corrupt
/// setting degrades to a usable screen instead of a crash.
Currency _currencyByCode(String code) => Currency.predefined.firstWhere(
  (Currency candidate) => candidate.code == code,
  orElse: () => Currency.usd,
);
