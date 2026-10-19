// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Drift-backed [CategoryRepository].
///
/// Kept alive so every consumer shares one repository and one audit writer for
/// the whole session.

@ProviderFor(categoryRepository)
final categoryRepositoryProvider = CategoryRepositoryProvider._();

/// The Drift-backed [CategoryRepository].
///
/// Kept alive so every consumer shares one repository and one audit writer for
/// the whole session.

final class CategoryRepositoryProvider
    extends
        $FunctionalProvider<
          CategoryRepository,
          CategoryRepository,
          CategoryRepository
        >
    with $Provider<CategoryRepository> {
  /// The Drift-backed [CategoryRepository].
  ///
  /// Kept alive so every consumer shares one repository and one audit writer for
  /// the whole session.
  CategoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryRepository create(Ref ref) {
    return categoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryRepository>(value),
    );
  }
}

String _$categoryRepositoryHash() =>
    r'98066ab85312b49c4aff704030c38f1e41ae3804';

/// The Drift-backed [UnitRepository].

@ProviderFor(unitRepository)
final unitRepositoryProvider = UnitRepositoryProvider._();

/// The Drift-backed [UnitRepository].

final class UnitRepositoryProvider
    extends $FunctionalProvider<UnitRepository, UnitRepository, UnitRepository>
    with $Provider<UnitRepository> {
  /// The Drift-backed [UnitRepository].
  UnitRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unitRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unitRepositoryHash();

  @$internal
  @override
  $ProviderElement<UnitRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UnitRepository create(Ref ref) {
    return unitRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnitRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnitRepository>(value),
    );
  }
}

String _$unitRepositoryHash() => r'52e40a0410dccc47cd93e0f7f3fea3111ba21aa5';

/// The Drift-backed [ProductRepository].
///
/// The shop currency decides what a stored price means, so the repository also
/// receives the settings use case that reads the business profile.

@ProviderFor(productRepository)
final productRepositoryProvider = ProductRepositoryProvider._();

/// The Drift-backed [ProductRepository].
///
/// The shop currency decides what a stored price means, so the repository also
/// receives the settings use case that reads the business profile.

final class ProductRepositoryProvider
    extends
        $FunctionalProvider<
          ProductRepository,
          ProductRepository,
          ProductRepository
        >
    with $Provider<ProductRepository> {
  /// The Drift-backed [ProductRepository].
  ///
  /// The shop currency decides what a stored price means, so the repository also
  /// receives the settings use case that reads the business profile.
  ProductRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductRepository create(Ref ref) {
    return productRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductRepository>(value),
    );
  }
}

String _$productRepositoryHash() => r'50faba0df9a01b5ec1a0a88390c63f9ff7f8de01';

/// The Drift-backed [BarcodeRepository].
///
/// A label is an identity, not a price, so nothing here needs the shop profile.

@ProviderFor(barcodeRepository)
final barcodeRepositoryProvider = BarcodeRepositoryProvider._();

/// The Drift-backed [BarcodeRepository].
///
/// A label is an identity, not a price, so nothing here needs the shop profile.

final class BarcodeRepositoryProvider
    extends
        $FunctionalProvider<
          BarcodeRepository,
          BarcodeRepository,
          BarcodeRepository
        >
    with $Provider<BarcodeRepository> {
  /// The Drift-backed [BarcodeRepository].
  ///
  /// A label is an identity, not a price, so nothing here needs the shop profile.
  BarcodeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'barcodeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$barcodeRepositoryHash();

  @$internal
  @override
  $ProviderElement<BarcodeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BarcodeRepository create(Ref ref) {
    return barcodeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BarcodeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BarcodeRepository>(value),
    );
  }
}

String _$barcodeRepositoryHash() => r'57c3be1d9ba02ae30476b8041d8b83faabedba38';

/// The use case that reads the category tree.

@ProviderFor(loadCategories)
final loadCategoriesProvider = LoadCategoriesProvider._();

/// The use case that reads the category tree.

final class LoadCategoriesProvider
    extends $FunctionalProvider<LoadCategories, LoadCategories, LoadCategories>
    with $Provider<LoadCategories> {
  /// The use case that reads the category tree.
  LoadCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadCategoriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadCategoriesHash();

  @$internal
  @override
  $ProviderElement<LoadCategories> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadCategories create(Ref ref) {
    return loadCategories(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadCategories value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadCategories>(value),
    );
  }
}

String _$loadCategoriesHash() => r'85cefd00fad928b5413983887c932b9e74e3c4e9';

/// The use case that adds a category.
///
/// It owns identity, so it needs the same clock that seeds the UUID v7 that
/// orders the row.

@ProviderFor(createCategory)
final createCategoryProvider = CreateCategoryProvider._();

/// The use case that adds a category.
///
/// It owns identity, so it needs the same clock that seeds the UUID v7 that
/// orders the row.

final class CreateCategoryProvider
    extends $FunctionalProvider<CreateCategory, CreateCategory, CreateCategory>
    with $Provider<CreateCategory> {
  /// The use case that adds a category.
  ///
  /// It owns identity, so it needs the same clock that seeds the UUID v7 that
  /// orders the row.
  CreateCategoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createCategoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createCategoryHash();

  @$internal
  @override
  $ProviderElement<CreateCategory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateCategory create(Ref ref) {
    return createCategory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateCategory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateCategory>(value),
    );
  }
}

String _$createCategoryHash() => r'af1a8b18804fe3d75a8cfbefc4081fd36419624c';

/// The use case that retires a category.

@ProviderFor(disableCategory)
final disableCategoryProvider = DisableCategoryProvider._();

/// The use case that retires a category.

final class DisableCategoryProvider
    extends
        $FunctionalProvider<DisableCategory, DisableCategory, DisableCategory>
    with $Provider<DisableCategory> {
  /// The use case that retires a category.
  DisableCategoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'disableCategoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$disableCategoryHash();

  @$internal
  @override
  $ProviderElement<DisableCategory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DisableCategory create(Ref ref) {
    return disableCategory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DisableCategory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DisableCategory>(value),
    );
  }
}

String _$disableCategoryHash() => r'a666c61534afc0afc8de6d60a8e5d341dad2ef16';

/// The use case that reads the units of measure.

@ProviderFor(loadUnits)
final loadUnitsProvider = LoadUnitsProvider._();

/// The use case that reads the units of measure.

final class LoadUnitsProvider
    extends $FunctionalProvider<LoadUnits, LoadUnits, LoadUnits>
    with $Provider<LoadUnits> {
  /// The use case that reads the units of measure.
  LoadUnitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadUnitsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadUnitsHash();

  @$internal
  @override
  $ProviderElement<LoadUnits> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadUnits create(Ref ref) {
    return loadUnits(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadUnits value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadUnits>(value),
    );
  }
}

String _$loadUnitsHash() => r'd487f2058ab104570886bef8d765ad882debbb63';

/// The use case that adds a unit of measure.

@ProviderFor(createUnit)
final createUnitProvider = CreateUnitProvider._();

/// The use case that adds a unit of measure.

final class CreateUnitProvider
    extends $FunctionalProvider<CreateUnit, CreateUnit, CreateUnit>
    with $Provider<CreateUnit> {
  /// The use case that adds a unit of measure.
  CreateUnitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createUnitProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createUnitHash();

  @$internal
  @override
  $ProviderElement<CreateUnit> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateUnit create(Ref ref) {
    return createUnit(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateUnit value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateUnit>(value),
    );
  }
}

String _$createUnitHash() => r'84f236f4b618b692594b6f1b26ba91a9c495e1fe';

/// The use case that retires a unit of measure.

@ProviderFor(disableUnit)
final disableUnitProvider = DisableUnitProvider._();

/// The use case that retires a unit of measure.

final class DisableUnitProvider
    extends $FunctionalProvider<DisableUnit, DisableUnit, DisableUnit>
    with $Provider<DisableUnit> {
  /// The use case that retires a unit of measure.
  DisableUnitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'disableUnitProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$disableUnitHash();

  @$internal
  @override
  $ProviderElement<DisableUnit> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DisableUnit create(Ref ref) {
    return disableUnit(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DisableUnit value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DisableUnit>(value),
    );
  }
}

String _$disableUnitHash() => r'3fe32092e807144f2c57e67e222b7e77b892b6b0';

/// The use case that converts a quantity between two units.

@ProviderFor(convertQuantity)
final convertQuantityProvider = ConvertQuantityProvider._();

/// The use case that converts a quantity between two units.

final class ConvertQuantityProvider
    extends
        $FunctionalProvider<ConvertQuantity, ConvertQuantity, ConvertQuantity>
    with $Provider<ConvertQuantity> {
  /// The use case that converts a quantity between two units.
  ConvertQuantityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'convertQuantityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$convertQuantityHash();

  @$internal
  @override
  $ProviderElement<ConvertQuantity> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ConvertQuantity create(Ref ref) {
    return convertQuantity(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConvertQuantity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConvertQuantity>(value),
    );
  }
}

String _$convertQuantityHash() => r'eaa9d27c65bd35bafb8469fff41759059530ae03';

/// The use case that provisions the default stock unit (`P2-06` follow-up).
///
/// A product cannot be stored without a stock unit, and Phase 2 ships no unit
/// screen, so the form asks this to make sure at least one unit exists. It is
/// idempotent and audited through [CreateUnit], never through a repository of
/// its own.

@ProviderFor(ensureDefaultStockUnit)
final ensureDefaultStockUnitProvider = EnsureDefaultStockUnitProvider._();

/// The use case that provisions the default stock unit (`P2-06` follow-up).
///
/// A product cannot be stored without a stock unit, and Phase 2 ships no unit
/// screen, so the form asks this to make sure at least one unit exists. It is
/// idempotent and audited through [CreateUnit], never through a repository of
/// its own.

final class EnsureDefaultStockUnitProvider
    extends
        $FunctionalProvider<
          EnsureDefaultStockUnit,
          EnsureDefaultStockUnit,
          EnsureDefaultStockUnit
        >
    with $Provider<EnsureDefaultStockUnit> {
  /// The use case that provisions the default stock unit (`P2-06` follow-up).
  ///
  /// A product cannot be stored without a stock unit, and Phase 2 ships no unit
  /// screen, so the form asks this to make sure at least one unit exists. It is
  /// idempotent and audited through [CreateUnit], never through a repository of
  /// its own.
  EnsureDefaultStockUnitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ensureDefaultStockUnitProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ensureDefaultStockUnitHash();

  @$internal
  @override
  $ProviderElement<EnsureDefaultStockUnit> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EnsureDefaultStockUnit create(Ref ref) {
    return ensureDefaultStockUnit(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EnsureDefaultStockUnit value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EnsureDefaultStockUnit>(value),
    );
  }
}

String _$ensureDefaultStockUnitHash() =>
    r'2db8641b5614581533d257b036d6d440577f1c44';

/// The category tree as a value a widget can watch.
///
/// The synchronous [loadCategories] hands out the use case; this provider runs
/// it, so a widget or the router can watch the result without calling into the
/// database itself. Kept alive so a single read serves the whole session.

@ProviderFor(allCategories)
final allCategoriesProvider = AllCategoriesProvider._();

/// The category tree as a value a widget can watch.
///
/// The synchronous [loadCategories] hands out the use case; this provider runs
/// it, so a widget or the router can watch the result without calling into the
/// database itself. Kept alive so a single read serves the whole session.

final class AllCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<List<Category>>>,
          Result<List<Category>>,
          FutureOr<Result<List<Category>>>
        >
    with
        $FutureModifier<Result<List<Category>>>,
        $FutureProvider<Result<List<Category>>> {
  /// The category tree as a value a widget can watch.
  ///
  /// The synchronous [loadCategories] hands out the use case; this provider runs
  /// it, so a widget or the router can watch the result without calling into the
  /// database itself. Kept alive so a single read serves the whole session.
  AllCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allCategoriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<Result<List<Category>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<List<Category>>> create(Ref ref) {
    return allCategories(ref);
  }
}

String _$allCategoriesHash() => r'007bb57a1c760fd78ca1a5e1c23d774c1bab8e31';

/// The units of measure as a value a widget can watch.

@ProviderFor(allUnits)
final allUnitsProvider = AllUnitsProvider._();

/// The units of measure as a value a widget can watch.

final class AllUnitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<List<Unit>>>,
          Result<List<Unit>>,
          FutureOr<Result<List<Unit>>>
        >
    with
        $FutureModifier<Result<List<Unit>>>,
        $FutureProvider<Result<List<Unit>>> {
  /// The units of measure as a value a widget can watch.
  AllUnitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allUnitsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allUnitsHash();

  @$internal
  @override
  $FutureProviderElement<Result<List<Unit>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<List<Unit>>> create(Ref ref) {
    return allUnits(ref);
  }
}

String _$allUnitsHash() => r'ca9f2c6e8851e9ca4de3775a8dac8ebdf71b5b5f';

/// The use case that reads the catalogue.

@ProviderFor(loadProducts)
final loadProductsProvider = LoadProductsProvider._();

/// The use case that reads the catalogue.

final class LoadProductsProvider
    extends $FunctionalProvider<LoadProducts, LoadProducts, LoadProducts>
    with $Provider<LoadProducts> {
  /// The use case that reads the catalogue.
  LoadProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadProductsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadProductsHash();

  @$internal
  @override
  $ProviderElement<LoadProducts> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadProducts create(Ref ref) {
    return loadProducts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadProducts value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadProducts>(value),
    );
  }
}

String _$loadProductsHash() => r'34b30bcbf4751b5aea5b370d14a12f0d07efd210';

/// The use case that adds a product.
///
/// It owns identity, so it needs the same clock that seeds the UUID v7 that
/// orders the row.

@ProviderFor(createProduct)
final createProductProvider = CreateProductProvider._();

/// The use case that adds a product.
///
/// It owns identity, so it needs the same clock that seeds the UUID v7 that
/// orders the row.

final class CreateProductProvider
    extends $FunctionalProvider<CreateProduct, CreateProduct, CreateProduct>
    with $Provider<CreateProduct> {
  /// The use case that adds a product.
  ///
  /// It owns identity, so it needs the same clock that seeds the UUID v7 that
  /// orders the row.
  CreateProductProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createProductProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createProductHash();

  @$internal
  @override
  $ProviderElement<CreateProduct> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateProduct create(Ref ref) {
    return createProduct(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateProduct value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateProduct>(value),
    );
  }
}

String _$createProductHash() => r'b4b6946e5713d5b8938bacccbda0148f714c6b59';

/// The use case that edits a product.

@ProviderFor(updateProduct)
final updateProductProvider = UpdateProductProvider._();

/// The use case that edits a product.

final class UpdateProductProvider
    extends $FunctionalProvider<UpdateProduct, UpdateProduct, UpdateProduct>
    with $Provider<UpdateProduct> {
  /// The use case that edits a product.
  UpdateProductProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateProductProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateProductHash();

  @$internal
  @override
  $ProviderElement<UpdateProduct> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateProduct create(Ref ref) {
    return updateProduct(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateProduct value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateProduct>(value),
    );
  }
}

String _$updateProductHash() => r'841777247ba77568b3cc880c1605c9eb08ca8e10';

/// The use case that retires a product.

@ProviderFor(disableProduct)
final disableProductProvider = DisableProductProvider._();

/// The use case that retires a product.

final class DisableProductProvider
    extends $FunctionalProvider<DisableProduct, DisableProduct, DisableProduct>
    with $Provider<DisableProduct> {
  /// The use case that retires a product.
  DisableProductProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'disableProductProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$disableProductHash();

  @$internal
  @override
  $ProviderElement<DisableProduct> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DisableProduct create(Ref ref) {
    return disableProduct(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DisableProduct value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DisableProduct>(value),
    );
  }
}

String _$disableProductHash() => r'68763b94de645868a40a3f8a961350d506e59b4c';

/// The catalogue as a value a widget can watch.
///
/// The synchronous [loadProducts] hands out the use case; this provider runs it,
/// so a widget can watch the result without calling into the database itself.

@ProviderFor(allProducts)
final allProductsProvider = AllProductsProvider._();

/// The catalogue as a value a widget can watch.
///
/// The synchronous [loadProducts] hands out the use case; this provider runs it,
/// so a widget can watch the result without calling into the database itself.

final class AllProductsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<List<Product>>>,
          Result<List<Product>>,
          FutureOr<Result<List<Product>>>
        >
    with
        $FutureModifier<Result<List<Product>>>,
        $FutureProvider<Result<List<Product>>> {
  /// The catalogue as a value a widget can watch.
  ///
  /// The synchronous [loadProducts] hands out the use case; this provider runs it,
  /// so a widget can watch the result without calling into the database itself.
  AllProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allProductsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allProductsHash();

  @$internal
  @override
  $FutureProviderElement<Result<List<Product>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<List<Product>>> create(Ref ref) {
    return allProducts(ref);
  }
}

String _$allProductsHash() => r'36e3f275e0477721ceafbfa668158b636d4ae8b4';

/// The use case that reads one product by id.
///
/// The list can show a product from what it already loaded; the edit form cannot,
/// because a save must send back a complete product — including the price a
/// price-blind role is not allowed to see. This is the read that carries it.

@ProviderFor(loadProductById)
final loadProductByIdProvider = LoadProductByIdProvider._();

/// The use case that reads one product by id.
///
/// The list can show a product from what it already loaded; the edit form cannot,
/// because a save must send back a complete product — including the price a
/// price-blind role is not allowed to see. This is the read that carries it.

final class LoadProductByIdProvider
    extends
        $FunctionalProvider<LoadProductById, LoadProductById, LoadProductById>
    with $Provider<LoadProductById> {
  /// The use case that reads one product by id.
  ///
  /// The list can show a product from what it already loaded; the edit form cannot,
  /// because a save must send back a complete product — including the price a
  /// price-blind role is not allowed to see. This is the read that carries it.
  LoadProductByIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadProductByIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadProductByIdHash();

  @$internal
  @override
  $ProviderElement<LoadProductById> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadProductById create(Ref ref) {
    return loadProductById(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadProductById value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadProductById>(value),
    );
  }
}

String _$loadProductByIdHash() => r'fc41370518ddc1cdaeb86e2768e8851c8ba75fae';

/// The use case that reads the labels a product carries.

@ProviderFor(loadBarcodesForProduct)
final loadBarcodesForProductProvider = LoadBarcodesForProductProvider._();

/// The use case that reads the labels a product carries.

final class LoadBarcodesForProductProvider
    extends
        $FunctionalProvider<
          LoadBarcodesForProduct,
          LoadBarcodesForProduct,
          LoadBarcodesForProduct
        >
    with $Provider<LoadBarcodesForProduct> {
  /// The use case that reads the labels a product carries.
  LoadBarcodesForProductProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadBarcodesForProductProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadBarcodesForProductHash();

  @$internal
  @override
  $ProviderElement<LoadBarcodesForProduct> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoadBarcodesForProduct create(Ref ref) {
    return loadBarcodesForProduct(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadBarcodesForProduct value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadBarcodesForProduct>(value),
    );
  }
}

String _$loadBarcodesForProductHash() =>
    r'c4f2f4360a9ce61ea39bdc445380faec6f69f2be';

/// The use case that resolves a scanned code.
///
/// It is also how a rejected duplicate is explained: the caller runs it with the
/// code that was refused and reaches the product that already owns it.

@ProviderFor(findBarcodeByCode)
final findBarcodeByCodeProvider = FindBarcodeByCodeProvider._();

/// The use case that resolves a scanned code.
///
/// It is also how a rejected duplicate is explained: the caller runs it with the
/// code that was refused and reaches the product that already owns it.

final class FindBarcodeByCodeProvider
    extends
        $FunctionalProvider<
          FindBarcodeByCode,
          FindBarcodeByCode,
          FindBarcodeByCode
        >
    with $Provider<FindBarcodeByCode> {
  /// The use case that resolves a scanned code.
  ///
  /// It is also how a rejected duplicate is explained: the caller runs it with the
  /// code that was refused and reaches the product that already owns it.
  FindBarcodeByCodeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'findBarcodeByCodeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$findBarcodeByCodeHash();

  @$internal
  @override
  $ProviderElement<FindBarcodeByCode> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FindBarcodeByCode create(Ref ref) {
    return findBarcodeByCode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FindBarcodeByCode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FindBarcodeByCode>(value),
    );
  }
}

String _$findBarcodeByCodeHash() => r'7e9c08869f4bafc9d475f821ca7d9b48da9c1d6d';

/// The use case that links a new label to a product.
///
/// It owns identity, so it needs the same clock that seeds the UUID v7 that
/// orders the row.

@ProviderFor(createBarcode)
final createBarcodeProvider = CreateBarcodeProvider._();

/// The use case that links a new label to a product.
///
/// It owns identity, so it needs the same clock that seeds the UUID v7 that
/// orders the row.

final class CreateBarcodeProvider
    extends $FunctionalProvider<CreateBarcode, CreateBarcode, CreateBarcode>
    with $Provider<CreateBarcode> {
  /// The use case that links a new label to a product.
  ///
  /// It owns identity, so it needs the same clock that seeds the UUID v7 that
  /// orders the row.
  CreateBarcodeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createBarcodeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createBarcodeHash();

  @$internal
  @override
  $ProviderElement<CreateBarcode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateBarcode create(Ref ref) {
    return createBarcode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateBarcode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateBarcode>(value),
    );
  }
}

String _$createBarcodeHash() => r'f35ff4f64d3d9a6f9440a7cf27cbd193fe92afcd';

/// The use case that retires a label.

@ProviderFor(disableBarcode)
final disableBarcodeProvider = DisableBarcodeProvider._();

/// The use case that retires a label.

final class DisableBarcodeProvider
    extends $FunctionalProvider<DisableBarcode, DisableBarcode, DisableBarcode>
    with $Provider<DisableBarcode> {
  /// The use case that retires a label.
  DisableBarcodeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'disableBarcodeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$disableBarcodeHash();

  @$internal
  @override
  $ProviderElement<DisableBarcode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DisableBarcode create(Ref ref) {
    return disableBarcode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DisableBarcode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DisableBarcode>(value),
    );
  }
}

String _$disableBarcodeHash() => r'3642e753284ee8f62031d6b56c73e9c4bd7e0355';

/// The Drift-backed [TierPriceRepository].
///
/// A band's stored minor units only become a `Money` with the shop currency, so
/// the repository also receives the settings use case that reads the profile.

@ProviderFor(tierPriceRepository)
final tierPriceRepositoryProvider = TierPriceRepositoryProvider._();

/// The Drift-backed [TierPriceRepository].
///
/// A band's stored minor units only become a `Money` with the shop currency, so
/// the repository also receives the settings use case that reads the profile.

final class TierPriceRepositoryProvider
    extends
        $FunctionalProvider<
          TierPriceRepository,
          TierPriceRepository,
          TierPriceRepository
        >
    with $Provider<TierPriceRepository> {
  /// The Drift-backed [TierPriceRepository].
  ///
  /// A band's stored minor units only become a `Money` with the shop currency, so
  /// the repository also receives the settings use case that reads the profile.
  TierPriceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tierPriceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tierPriceRepositoryHash();

  @$internal
  @override
  $ProviderElement<TierPriceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TierPriceRepository create(Ref ref) {
    return tierPriceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TierPriceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TierPriceRepository>(value),
    );
  }
}

String _$tierPriceRepositoryHash() =>
    r'2098d22386ea4698027cebe348a0948482a0bbfb';

/// The use case that reads the price bands a product carries.

@ProviderFor(loadTierPricesForProduct)
final loadTierPricesForProductProvider = LoadTierPricesForProductProvider._();

/// The use case that reads the price bands a product carries.

final class LoadTierPricesForProductProvider
    extends
        $FunctionalProvider<
          LoadTierPricesForProduct,
          LoadTierPricesForProduct,
          LoadTierPricesForProduct
        >
    with $Provider<LoadTierPricesForProduct> {
  /// The use case that reads the price bands a product carries.
  LoadTierPricesForProductProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadTierPricesForProductProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadTierPricesForProductHash();

  @$internal
  @override
  $ProviderElement<LoadTierPricesForProduct> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoadTierPricesForProduct create(Ref ref) {
    return loadTierPricesForProduct(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadTierPricesForProduct value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadTierPricesForProduct>(value),
    );
  }
}

String _$loadTierPricesForProductHash() =>
    r'e5a268321548a7ad6e152d2b12236f85e6abcece';

/// The use case that adds a price band.
///
/// It owns identity, so it needs the same clock that seeds the UUID v7 that
/// orders the row.

@ProviderFor(createTierPrice)
final createTierPriceProvider = CreateTierPriceProvider._();

/// The use case that adds a price band.
///
/// It owns identity, so it needs the same clock that seeds the UUID v7 that
/// orders the row.

final class CreateTierPriceProvider
    extends
        $FunctionalProvider<CreateTierPrice, CreateTierPrice, CreateTierPrice>
    with $Provider<CreateTierPrice> {
  /// The use case that adds a price band.
  ///
  /// It owns identity, so it needs the same clock that seeds the UUID v7 that
  /// orders the row.
  CreateTierPriceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createTierPriceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createTierPriceHash();

  @$internal
  @override
  $ProviderElement<CreateTierPrice> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateTierPrice create(Ref ref) {
    return createTierPrice(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateTierPrice value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateTierPrice>(value),
    );
  }
}

String _$createTierPriceHash() => r'c27068833b8e0c6e99ab79d23f0642f1197ec3c7';

/// The use case that edits a price band.

@ProviderFor(updateTierPrice)
final updateTierPriceProvider = UpdateTierPriceProvider._();

/// The use case that edits a price band.

final class UpdateTierPriceProvider
    extends
        $FunctionalProvider<UpdateTierPrice, UpdateTierPrice, UpdateTierPrice>
    with $Provider<UpdateTierPrice> {
  /// The use case that edits a price band.
  UpdateTierPriceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateTierPriceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateTierPriceHash();

  @$internal
  @override
  $ProviderElement<UpdateTierPrice> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateTierPrice create(Ref ref) {
    return updateTierPrice(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateTierPrice value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateTierPrice>(value),
    );
  }
}

String _$updateTierPriceHash() => r'3be7ae10b2201b13bfb1adf466b4fc689556de69';

/// The use case that retires a price band.

@ProviderFor(disableTierPrice)
final disableTierPriceProvider = DisableTierPriceProvider._();

/// The use case that retires a price band.

final class DisableTierPriceProvider
    extends
        $FunctionalProvider<
          DisableTierPrice,
          DisableTierPrice,
          DisableTierPrice
        >
    with $Provider<DisableTierPrice> {
  /// The use case that retires a price band.
  DisableTierPriceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'disableTierPriceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$disableTierPriceHash();

  @$internal
  @override
  $ProviderElement<DisableTierPrice> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DisableTierPrice create(Ref ref) {
    return disableTierPrice(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DisableTierPrice value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DisableTierPrice>(value),
    );
  }
}

String _$disableTierPriceHash() => r'7e2659ab7a97ee36c666cd84ec9d44f6c3a023d6';

/// The use case that picks the price for a quantity on a tier.
///
/// It reads the product only for its own sale price, which is the fallback when
/// no band of the requested tier applies.

@ProviderFor(selectPrice)
final selectPriceProvider = SelectPriceProvider._();

/// The use case that picks the price for a quantity on a tier.
///
/// It reads the product only for its own sale price, which is the fallback when
/// no band of the requested tier applies.

final class SelectPriceProvider
    extends $FunctionalProvider<SelectPrice, SelectPrice, SelectPrice>
    with $Provider<SelectPrice> {
  /// The use case that picks the price for a quantity on a tier.
  ///
  /// It reads the product only for its own sale price, which is the fallback when
  /// no band of the requested tier applies.
  SelectPriceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectPriceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectPriceHash();

  @$internal
  @override
  $ProviderElement<SelectPrice> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SelectPrice create(Ref ref) {
    return selectPrice(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SelectPrice value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SelectPrice>(value),
    );
  }
}

String _$selectPriceHash() => r'b3c3f8e50642fa3773a61a52a2329be776a0ca99';

/// The Drift-backed [ProductSearchRepository].
///
/// Reading a derived index is not a business write, so unlike the other
/// repositories here it takes no audit service and no clock: a rebuild only
/// re-reads rows `products` already holds. The settings use case is still
/// injected, because a hit reports a price and a price needs a currency.

@ProviderFor(productSearchRepository)
final productSearchRepositoryProvider = ProductSearchRepositoryProvider._();

/// The Drift-backed [ProductSearchRepository].
///
/// Reading a derived index is not a business write, so unlike the other
/// repositories here it takes no audit service and no clock: a rebuild only
/// re-reads rows `products` already holds. The settings use case is still
/// injected, because a hit reports a price and a price needs a currency.

final class ProductSearchRepositoryProvider
    extends
        $FunctionalProvider<
          ProductSearchRepository,
          ProductSearchRepository,
          ProductSearchRepository
        >
    with $Provider<ProductSearchRepository> {
  /// The Drift-backed [ProductSearchRepository].
  ///
  /// Reading a derived index is not a business write, so unlike the other
  /// repositories here it takes no audit service and no clock: a rebuild only
  /// re-reads rows `products` already holds. The settings use case is still
  /// injected, because a hit reports a price and a price needs a currency.
  ProductSearchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productSearchRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productSearchRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductSearchRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductSearchRepository create(Ref ref) {
    return productSearchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductSearchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductSearchRepository>(value),
    );
  }
}

String _$productSearchRepositoryHash() =>
    r'1d21e42a2be6c730f2af1cdebb3e32c327041e1e';

/// The use case that answers the quick-search box (`P2-06`).
///
/// It owns the page bounds, so the screen cannot ask for a page the search was
/// never meant to serve.

@ProviderFor(searchProducts)
final searchProductsProvider = SearchProductsProvider._();

/// The use case that answers the quick-search box (`P2-06`).
///
/// It owns the page bounds, so the screen cannot ask for a page the search was
/// never meant to serve.

final class SearchProductsProvider
    extends $FunctionalProvider<SearchProducts, SearchProducts, SearchProducts>
    with $Provider<SearchProducts> {
  /// The use case that answers the quick-search box (`P2-06`).
  ///
  /// It owns the page bounds, so the screen cannot ask for a page the search was
  /// never meant to serve.
  SearchProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchProductsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchProductsHash();

  @$internal
  @override
  $ProviderElement<SearchProducts> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchProducts create(Ref ref) {
    return searchProducts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchProducts value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchProducts>(value),
    );
  }
}

String _$searchProductsHash() => r'1f4e0e67978c55a2ad5966dbc2308ccf241c6b42';

/// The use case that rebuilds the search index from `products` (`P2-06`).
///
/// Kept as a use case rather than as a call on the repository so repairing a
/// degraded index is an explicit decision a screen makes, not something a read
/// can trigger behind the caller's back.

@ProviderFor(rebuildProductSearchIndex)
final rebuildProductSearchIndexProvider = RebuildProductSearchIndexProvider._();

/// The use case that rebuilds the search index from `products` (`P2-06`).
///
/// Kept as a use case rather than as a call on the repository so repairing a
/// degraded index is an explicit decision a screen makes, not something a read
/// can trigger behind the caller's back.

final class RebuildProductSearchIndexProvider
    extends
        $FunctionalProvider<
          RebuildProductSearchIndex,
          RebuildProductSearchIndex,
          RebuildProductSearchIndex
        >
    with $Provider<RebuildProductSearchIndex> {
  /// The use case that rebuilds the search index from `products` (`P2-06`).
  ///
  /// Kept as a use case rather than as a call on the repository so repairing a
  /// degraded index is an explicit decision a screen makes, not something a read
  /// can trigger behind the caller's back.
  RebuildProductSearchIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rebuildProductSearchIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rebuildProductSearchIndexHash();

  @$internal
  @override
  $ProviderElement<RebuildProductSearchIndex> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RebuildProductSearchIndex create(Ref ref) {
    return rebuildProductSearchIndex(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RebuildProductSearchIndex value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RebuildProductSearchIndex>(value),
    );
  }
}

String _$rebuildProductSearchIndexHash() =>
    r'b0062a0bab450669f7745bffb924634c585dc7c4';
