// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_ui_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the signed-in role may browse the catalogue at all.
///
/// The shell decides what to render and this decides what to offer; neither is
/// the security boundary on its own, which is why the data layer re-checks.

@ProviderFor(canViewProducts)
final canViewProductsProvider = CanViewProductsProvider._();

/// Whether the signed-in role may browse the catalogue at all.
///
/// The shell decides what to render and this decides what to offer; neither is
/// the security boundary on its own, which is why the data layer re-checks.

final class CanViewProductsProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the signed-in role may browse the catalogue at all.
  ///
  /// The shell decides what to render and this decides what to offer; neither is
  /// the security boundary on its own, which is why the data layer re-checks.
  CanViewProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'canViewProductsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$canViewProductsHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return canViewProducts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$canViewProductsHash() => r'7e7812985ba1c3dcc83ce56ae3ada0ba8d44d7b4';

/// Whether the signed-in role may create and edit products.

@ProviderFor(canManageProducts)
final canManageProductsProvider = CanManageProductsProvider._();

/// Whether the signed-in role may create and edit products.

final class CanManageProductsProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the signed-in role may create and edit products.
  CanManageProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'canManageProductsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$canManageProductsHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return canManageProducts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$canManageProductsHash() => r'c65dd3307f60df2151e018be3edf3789aa928475';

/// Whether the signed-in role may see selling and cost prices.
///
/// It is a permission of its own (`catalogPriceManage`) rather than a side
/// effect of managing products, because the two genuinely differ: the stock
/// specialist maintains the catalogue without ever seeing what it is worth.

@ProviderFor(canViewPrices)
final canViewPricesProvider = CanViewPricesProvider._();

/// Whether the signed-in role may see selling and cost prices.
///
/// It is a permission of its own (`catalogPriceManage`) rather than a side
/// effect of managing products, because the two genuinely differ: the stock
/// specialist maintains the catalogue without ever seeing what it is worth.

final class CanViewPricesProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the signed-in role may see selling and cost prices.
  ///
  /// It is a permission of its own (`catalogPriceManage`) rather than a side
  /// effect of managing products, because the two genuinely differ: the stock
  /// specialist maintains the catalogue without ever seeing what it is worth.
  CanViewPricesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'canViewPricesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$canViewPricesHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return canViewPrices(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$canViewPricesHash() => r'4e6198d1b45b48b7c88c84afd2debf0698cc10bd';

/// The catalogue for the list screen, with the price rule already applied.
///
/// The product read is the one that can fail the screen. The category and unit
/// lookups are treated as decoration: if they fail the list still renders, just
/// without labels, because a product with no category name is far better than an
/// empty screen.

@ProviderFor(productList)
final productListProvider = ProductListProvider._();

/// The catalogue for the list screen, with the price rule already applied.
///
/// The product read is the one that can fail the screen. The category and unit
/// lookups are treated as decoration: if they fail the list still renders, just
/// without labels, because a product with no category name is far better than an
/// empty screen.

final class ProductListProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<List<ProductView>>>,
          Result<List<ProductView>>,
          FutureOr<Result<List<ProductView>>>
        >
    with
        $FutureModifier<Result<List<ProductView>>>,
        $FutureProvider<Result<List<ProductView>>> {
  /// The catalogue for the list screen, with the price rule already applied.
  ///
  /// The product read is the one that can fail the screen. The category and unit
  /// lookups are treated as decoration: if they fail the list still renders, just
  /// without labels, because a product with no category name is far better than an
  /// empty screen.
  ProductListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productListHash();

  @$internal
  @override
  $FutureProviderElement<Result<List<ProductView>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<List<ProductView>>> create(Ref ref) {
    return productList(ref);
  }
}

String _$productListHash() => r'341c363c1cddac6b0eaf72c46002c38c683f0064';

/// One product for the details screen, carrying the same price rule.
///
/// It reads from the list rather than opening a second read of its own: the
/// product the user tapped is the product the screen shows, and the price rule
/// stays in exactly one place.

@ProviderFor(productDetail)
final productDetailProvider = ProductDetailFamily._();

/// One product for the details screen, carrying the same price rule.
///
/// It reads from the list rather than opening a second read of its own: the
/// product the user tapped is the product the screen shows, and the price rule
/// stays in exactly one place.

final class ProductDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<ProductView>>,
          Result<ProductView>,
          FutureOr<Result<ProductView>>
        >
    with
        $FutureModifier<Result<ProductView>>,
        $FutureProvider<Result<ProductView>> {
  /// One product for the details screen, carrying the same price rule.
  ///
  /// It reads from the list rather than opening a second read of its own: the
  /// product the user tapped is the product the screen shows, and the price rule
  /// stays in exactly one place.
  ProductDetailProvider._({
    required ProductDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productDetailHash();

  @override
  String toString() {
    return r'productDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Result<ProductView>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<ProductView>> create(Ref ref) {
    final argument = this.argument as String;
    return productDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productDetailHash() => r'0ff799925b0f4d0a264d13812dc169c408a41858';

/// One product for the details screen, carrying the same price rule.
///
/// It reads from the list rather than opening a second read of its own: the
/// product the user tapped is the product the screen shows, and the price rule
/// stays in exactly one place.

final class ProductDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Result<ProductView>>, String> {
  ProductDetailFamily._()
    : super(
        retry: null,
        name: r'productDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One product for the details screen, carrying the same price rule.
  ///
  /// It reads from the list rather than opening a second read of its own: the
  /// product the user tapped is the product the screen shows, and the price rule
  /// stays in exactly one place.

  ProductDetailProvider call(String id) =>
      ProductDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'productDetailProvider';
}

/// The price bands of one product, with the price rule applied.

@ProviderFor(productTierPrices)
final productTierPricesProvider = ProductTierPricesFamily._();

/// The price bands of one product, with the price rule applied.

final class ProductTierPricesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<List<TierPriceView>>>,
          Result<List<TierPriceView>>,
          FutureOr<Result<List<TierPriceView>>>
        >
    with
        $FutureModifier<Result<List<TierPriceView>>>,
        $FutureProvider<Result<List<TierPriceView>>> {
  /// The price bands of one product, with the price rule applied.
  ProductTierPricesProvider._({
    required ProductTierPricesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productTierPricesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productTierPricesHash();

  @override
  String toString() {
    return r'productTierPricesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Result<List<TierPriceView>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<List<TierPriceView>>> create(Ref ref) {
    final argument = this.argument as String;
    return productTierPrices(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductTierPricesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productTierPricesHash() => r'b0a41b9a84a06842dfab273601eee2d9702e9200';

/// The price bands of one product, with the price rule applied.

final class ProductTierPricesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Result<List<TierPriceView>>>,
          String
        > {
  ProductTierPricesFamily._()
    : super(
        retry: null,
        name: r'productTierPricesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The price bands of one product, with the price rule applied.

  ProductTierPricesProvider call(String productId) =>
      ProductTierPricesProvider._(argument: productId, from: this);

  @override
  String toString() => r'productTierPricesProvider';
}

/// The labels a product carries. A barcode holds no money, so it needs no rule.

@ProviderFor(productBarcodes)
final productBarcodesProvider = ProductBarcodesFamily._();

/// The labels a product carries. A barcode holds no money, so it needs no rule.

final class ProductBarcodesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<List<Barcode>>>,
          Result<List<Barcode>>,
          FutureOr<Result<List<Barcode>>>
        >
    with
        $FutureModifier<Result<List<Barcode>>>,
        $FutureProvider<Result<List<Barcode>>> {
  /// The labels a product carries. A barcode holds no money, so it needs no rule.
  ProductBarcodesProvider._({
    required ProductBarcodesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productBarcodesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productBarcodesHash();

  @override
  String toString() {
    return r'productBarcodesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Result<List<Barcode>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<List<Barcode>>> create(Ref ref) {
    final argument = this.argument as String;
    return productBarcodes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductBarcodesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productBarcodesHash() => r'fdfaf5fb03c4f19035bf2584c887a0fc74ca4c8b';

/// The labels a product carries. A barcode holds no money, so it needs no rule.

final class ProductBarcodesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Result<List<Barcode>>>, String> {
  ProductBarcodesFamily._()
    : super(
        retry: null,
        name: r'productBarcodesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The labels a product carries. A barcode holds no money, so it needs no rule.

  ProductBarcodesProvider call(String productId) =>
      ProductBarcodesProvider._(argument: productId, from: this);

  @override
  String toString() => r'productBarcodesProvider';
}

/// The stored product behind an edit, for the save path only.
///
/// It exists so a save can carry values the editor was not allowed to see —
/// above all the price — through untouched, since the update use case requires
/// one. The gate is not the UI: without `catalogProductManage` this refuses,
/// so the privileged read cannot be reached at all. A screen must never render a
/// field of this object; display goes through [ProductView].

@ProviderFor(productForEdit)
final productForEditProvider = ProductForEditFamily._();

/// The stored product behind an edit, for the save path only.
///
/// It exists so a save can carry values the editor was not allowed to see —
/// above all the price — through untouched, since the update use case requires
/// one. The gate is not the UI: without `catalogProductManage` this refuses,
/// so the privileged read cannot be reached at all. A screen must never render a
/// field of this object; display goes through [ProductView].

final class ProductForEditProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<Product>>,
          Result<Product>,
          FutureOr<Result<Product>>
        >
    with $FutureModifier<Result<Product>>, $FutureProvider<Result<Product>> {
  /// The stored product behind an edit, for the save path only.
  ///
  /// It exists so a save can carry values the editor was not allowed to see —
  /// above all the price — through untouched, since the update use case requires
  /// one. The gate is not the UI: without `catalogProductManage` this refuses,
  /// so the privileged read cannot be reached at all. A screen must never render a
  /// field of this object; display goes through [ProductView].
  ProductForEditProvider._({
    required ProductForEditFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productForEditProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productForEditHash();

  @override
  String toString() {
    return r'productForEditProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Result<Product>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<Product>> create(Ref ref) {
    final argument = this.argument as String;
    return productForEdit(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductForEditProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productForEditHash() => r'e557459628b50247344196d090d265ec8cf5809d';

/// The stored product behind an edit, for the save path only.
///
/// It exists so a save can carry values the editor was not allowed to see —
/// above all the price — through untouched, since the update use case requires
/// one. The gate is not the UI: without `catalogProductManage` this refuses,
/// so the privileged read cannot be reached at all. A screen must never render a
/// field of this object; display goes through [ProductView].

final class ProductForEditFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Result<Product>>, String> {
  ProductForEditFamily._()
    : super(
        retry: null,
        name: r'productForEditProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The stored product behind an edit, for the save path only.
  ///
  /// It exists so a save can carry values the editor was not allowed to see —
  /// above all the price — through untouched, since the update use case requires
  /// one. The gate is not the UI: without `catalogProductManage` this refuses,
  /// so the privileged read cannot be reached at all. A screen must never render a
  /// field of this object; display goes through [ProductView].

  ProductForEditProvider call(String id) =>
      ProductForEditProvider._(argument: id, from: this);

  @override
  String toString() => r'productForEditProvider';
}

/// The currency the shop prices in.
///
/// Money is stored as minor units and the currency is deliberately never a
/// column, so a screen that turns typed text into money has to ask. It is read
/// from the business profile rather than cached, for the same reason the
/// repositories do not cache it: changing the setting must change the money.

@ProviderFor(shopCurrency)
final shopCurrencyProvider = ShopCurrencyProvider._();

/// The currency the shop prices in.
///
/// Money is stored as minor units and the currency is deliberately never a
/// column, so a screen that turns typed text into money has to ask. It is read
/// from the business profile rather than cached, for the same reason the
/// repositories do not cache it: changing the setting must change the money.

final class ShopCurrencyProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<Currency>>,
          Result<Currency>,
          FutureOr<Result<Currency>>
        >
    with $FutureModifier<Result<Currency>>, $FutureProvider<Result<Currency>> {
  /// The currency the shop prices in.
  ///
  /// Money is stored as minor units and the currency is deliberately never a
  /// column, so a screen that turns typed text into money has to ask. It is read
  /// from the business profile rather than cached, for the same reason the
  /// repositories do not cache it: changing the setting must change the money.
  ShopCurrencyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shopCurrencyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shopCurrencyHash();

  @$internal
  @override
  $FutureProviderElement<Result<Currency>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<Currency>> create(Ref ref) {
    return shopCurrency(ref);
  }
}

String _$shopCurrencyHash() => r'9f018b9408f880809fe66c7ef6e51edbde10d0d8';

/// Everything the create form needs before it can render.

@ProviderFor(newProductForm)
final newProductFormProvider = NewProductFormProvider._();

/// Everything the create form needs before it can render.

final class NewProductFormProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<ProductFormData>>,
          Result<ProductFormData>,
          FutureOr<Result<ProductFormData>>
        >
    with
        $FutureModifier<Result<ProductFormData>>,
        $FutureProvider<Result<ProductFormData>> {
  /// Everything the create form needs before it can render.
  NewProductFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'newProductFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$newProductFormHash();

  @$internal
  @override
  $FutureProviderElement<Result<ProductFormData>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<ProductFormData>> create(Ref ref) {
    return newProductForm(ref);
  }
}

String _$newProductFormHash() => r'55e9452a081b6a7d89052b5845871d6044c66bb6';

/// Everything the edit form needs before it can render.
///
/// Two providers rather than one family keyed on a nullable id: a form that
/// creates has no product to read, and saying that in the type is clearer than a
/// `null` that happens to mean "not editing".

@ProviderFor(editProductForm)
final editProductFormProvider = EditProductFormFamily._();

/// Everything the edit form needs before it can render.
///
/// Two providers rather than one family keyed on a nullable id: a form that
/// creates has no product to read, and saying that in the type is clearer than a
/// `null` that happens to mean "not editing".

final class EditProductFormProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<ProductFormData>>,
          Result<ProductFormData>,
          FutureOr<Result<ProductFormData>>
        >
    with
        $FutureModifier<Result<ProductFormData>>,
        $FutureProvider<Result<ProductFormData>> {
  /// Everything the edit form needs before it can render.
  ///
  /// Two providers rather than one family keyed on a nullable id: a form that
  /// creates has no product to read, and saying that in the type is clearer than a
  /// `null` that happens to mean "not editing".
  EditProductFormProvider._({
    required EditProductFormFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'editProductFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editProductFormHash();

  @override
  String toString() {
    return r'editProductFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Result<ProductFormData>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<ProductFormData>> create(Ref ref) {
    final argument = this.argument as String;
    return editProductForm(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EditProductFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editProductFormHash() => r'd2c7ccb4cf769823cba574e863f3a70c3afe61aa';

/// Everything the edit form needs before it can render.
///
/// Two providers rather than one family keyed on a nullable id: a form that
/// creates has no product to read, and saying that in the type is clearer than a
/// `null` that happens to mean "not editing".

final class EditProductFormFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Result<ProductFormData>>, String> {
  EditProductFormFamily._()
    : super(
        retry: null,
        name: r'editProductFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Everything the edit form needs before it can render.
  ///
  /// Two providers rather than one family keyed on a nullable id: a form that
  /// creates has no product to read, and saying that in the type is clearer than a
  /// `null` that happens to mean "not editing".

  EditProductFormProvider call(String productId) =>
      EditProductFormProvider._(argument: productId, from: this);

  @override
  String toString() => r'editProductFormProvider';
}
