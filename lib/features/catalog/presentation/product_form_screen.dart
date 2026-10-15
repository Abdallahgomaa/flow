import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/shared/design/design.dart';
import 'package:flow/shared/l10n/error_messages.dart';
import 'package:flow/shared/l10n/l10n.dart';
import 'package:flow/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog_providers.dart';
import '../domain/category.dart';
import '../domain/product.dart';
import '../domain/product_type.dart';
import '../domain/product_validation.dart';
import '../domain/unit.dart';
import 'catalog_routes.dart';
import 'catalog_ui_providers.dart';
import 'catalog_widgets.dart';
import 'product_labels.dart';
import 'product_view.dart';

/// The product form — one widget for creating and for editing (`P2-05`).
///
/// Body only, like the other destinations: the shell owns the single `Scaffold`.
///
/// It writes nothing directly. Saved or discarded, a product only ever changes
/// through `CreateProduct`/`UpdateProduct`, which validate, resolve the unit and
/// category references, and audit inside their own transaction (AGENTS rule 3).
///
/// The same screen serves a role that may see prices and one that may not. The
/// price fields are not merely hidden for the second role: their values are
/// carried over from the stored product untouched, because `UpdateProduct`
/// requires a sale price and inventing one would silently reprice an item the
/// user cannot even see.
class ProductFormScreen extends ConsumerStatefulWidget {
  /// Creates the form.
  ///
  /// [productId] is the product to edit, or `null` to create a new one.
  const ProductFormScreen({super.key, this.productId});

  /// The product being edited, or `null` when the form creates a new one.
  final String? productId;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  String _name = '';
  String _salePrice = '';
  String _costPrice = '';
  String _reorderLevel = '';

  ProductType _type = ProductType.simple;
  String? _categoryId;
  String? _purchaseUnitCode;
  String? _stockUnitCode;

  String? _priceError;
  String? _quantityError;
  bool _saving = false;
  bool _seeded = false;

  bool get _isEditing => widget.productId != null;

  /// Copies the stored product into the form's fields.
  ///
  /// These are plain strings, not controllers, so seeding them costs no frame
  /// and the field's `initialValue` does the rest. The guard makes it happen
  /// once, so a rebuild while the user is typing cannot overwrite what they
  /// typed.
  void _seed(ProductFormData data) {
    if (_seeded) {
      return;
    }
    _seeded = true;

    final ProductView? product = data.product;
    if (product == null) {
      return;
    }

    _name = product.name;
    _type = product.type;
    _categoryId = product.categoryId;
    _purchaseUnitCode = product.purchaseUnitCode;
    _stockUnitCode = product.stockUnitCode;
    // Null when this role may not see prices, which is exactly why the save path
    // falls back to the stored product instead of trusting these.
    _salePrice = product.salePrice?.toDecimalString() ?? '';
    _costPrice = product.costPrice?.toDecimalString() ?? '';
    _reorderLevel = product.reorderLevel?.toDecimalString() ?? '';
  }

  /// Picks the unit a new product's stock is counted in before the user chooses.
  void _seedStockUnit(List<Unit> units) {
    if (_stockUnitCode != null || units.isEmpty) {
      return;
    }
    _stockUnitCode = units.first.code;
  }

  void _reload() {
    final String? productId = widget.productId;
    if (productId == null) {
      ref.invalidate(newProductFormProvider);
    } else {
      ref.invalidate(editProductFormProvider(productId));
    }
  }

  String _title(AppLocalizations l10n) =>
      _isEditing ? l10n.catalogEditTitle : l10n.catalogCreateTitle;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String? productId = widget.productId;

    final AsyncValue<Result<ProductFormData>> form = productId == null
        ? ref.watch(newProductFormProvider)
        : ref.watch(editProductFormProvider(productId));

    return form.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) => AppErrorWidget(
        title: _title(l10n),
        message: l10n.catalogLoadFailed,
        onRetry: _reload,
        retryLabel: l10n.actionRetry,
      ),
      data: (Result<ProductFormData> result) => result.fold(
        ok: (ProductFormData data) {
          _seed(data);
          _seedStockUnit(data.units);
          return _form(context, l10n, data);
        },
        err: (Failure failure) => AppErrorWidget(
          title: _title(l10n),
          message: ErrorMessages.of(l10n, failure),
          onRetry: _reload,
          retryLabel: l10n.actionRetry,
        ),
      ),
    );
  }

  Widget _form(
    BuildContext context,
    AppLocalizations l10n,
    ProductFormData data,
  ) {
    final ThemeData theme = Theme.of(context);
    final bool showPrices = ref.watch(canViewPricesProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: _saving ? null : () => catalogBack(context),
                icon: const Icon(Icons.arrow_back),
                tooltip: l10n.catalogBack,
              ),
              Expanded(
                child: Text(_title(l10n), style: theme.textTheme.headlineSmall),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomCard(
            title: l10n.catalogSectionDetails,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CustomTextField(
                  label: l10n.catalogNameLabel,
                  initialValue: _name,
                  textInputAction: TextInputAction.next,
                  enabled: !_saving,
                  onChanged: (String value) => _name = value,
                ),
                const SizedBox(height: AppSpacing.lg),
                _ChoiceLabel(text: l10n.catalogTypeLabel),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    for (final ProductType type in ProductType.values)
                      _Choice(
                        label: productTypeLabel(l10n, type),
                        selected: type == _type,
                        onPressed: _saving
                            ? null
                            : () => setState(() => _type = type),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _ChoiceLabel(text: l10n.catalogStockUnitLabel),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    for (final Unit unit in data.units)
                      _Choice(
                        label: unit.name,
                        selected: unit.code == _stockUnitCode,
                        onPressed: _saving
                            ? null
                            : () => setState(() => _stockUnitCode = unit.code),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _ChoiceLabel(text: l10n.catalogPurchaseUnitLabel),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    _Choice(
                      label: l10n.catalogNoneOption,
                      selected: _purchaseUnitCode == null,
                      onPressed: _saving
                          ? null
                          : () => setState(() => _purchaseUnitCode = null),
                    ),
                    for (final Unit unit in data.units)
                      _Choice(
                        label: unit.name,
                        selected: unit.code == _purchaseUnitCode,
                        onPressed: _saving
                            ? null
                            : () =>
                                  setState(() => _purchaseUnitCode = unit.code),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _ChoiceLabel(text: l10n.catalogCategoryLabel),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    _Choice(
                      label: l10n.catalogNoCategory,
                      selected: _categoryId == null,
                      onPressed: _saving
                          ? null
                          : () => setState(() => _categoryId = null),
                    ),
                    for (final Category category in data.categories)
                      _Choice(
                        label: category.name,
                        selected: category.id == _categoryId,
                        onPressed: _saving
                            ? null
                            : () => setState(() => _categoryId = category.id),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomCard(
            title: l10n.catalogSectionPricing,
            child: showPrices
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      CustomTextField(
                        label: l10n.catalogSalePrice,
                        initialValue: _salePrice,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        enabled: !_saving,
                        onChanged: (String value) => _salePrice = value,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      CustomTextField(
                        label: l10n.catalogCostPrice,
                        initialValue: _costPrice,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        enabled: !_saving,
                        onChanged: (String value) => _costPrice = value,
                      ),
                    ],
                  )
                : CatalogMutedText(text: l10n.catalogPricesReadOnlyNote),
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomCard(
            title: l10n.catalogSectionStock,
            child: CustomTextField(
              label: l10n.catalogReorderLevel,
              initialValue: _reorderLevel,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              enabled: !_saving,
              onChanged: (String value) => _reorderLevel = value,
            ),
          ),
          if (_priceError != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            ErrorBanner(message: _priceError!),
          ],
          if (_quantityError != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            ErrorBanner(message: _quantityError!),
          ],
          const SizedBox(height: AppSpacing.lg),
          CustomButton(
            label: l10n.actionSave,
            icon: Icons.save_outlined,
            isLoading: _saving,
            isExpanded: true,
            onPressed: () => _save(l10n, data),
          ),
          const SizedBox(height: AppSpacing.sm),
          CustomButton(
            label: l10n.actionCancel,
            variant: CustomButtonVariant.outline,
            isExpanded: true,
            onPressed: _saving ? null : () => catalogBack(context),
          ),
        ],
      ),
    );
  }

  /// Resolves the prices to send, or `null` when the input was rejected.
  ///
  /// A role that may see prices sends what was typed. A role that may not sends
  /// the stored values back **unchanged**: `UpdateProduct` demands a sale price,
  /// and inventing one would silently reprice somebody else's product. That is
  /// also why a role without price permission is never offered the create form —
  /// a new product has no stored price to carry over.
  Future<({Money salePrice, Money? costPrice})?> _readPrices(
    AppLocalizations l10n,
    ProductFormData data,
  ) async {
    if (!ref.read(canViewPricesProvider)) {
      final String? productId = widget.productId;
      if (productId == null) {
        _priceError = l10n.catalogPriceInvalid;
        return null;
      }

      final Result<Product> stored = await ref.read(
        productForEditProvider(productId).future,
      );
      final Product? product = stored.valueOrNull;
      if (product == null) {
        _priceError = ErrorMessages.of(l10n, stored.failureOrNull!);
        return null;
      }

      return (salePrice: product.salePrice, costPrice: product.costPrice);
    }

    final Money? salePrice = Money.parse(_salePrice, data.currency).valueOrNull;
    if (salePrice == null) {
      _priceError = l10n.catalogPriceInvalid;
      return null;
    }

    final String costText = _costPrice.trim();
    Money? costPrice;
    if (costText.isNotEmpty) {
      costPrice = Money.parse(costText, data.currency).valueOrNull;
      if (costPrice == null) {
        _priceError = l10n.catalogPriceInvalid;
        return null;
      }
    }

    return (salePrice: salePrice, costPrice: costPrice);
  }

  Future<void> _save(AppLocalizations l10n, ProductFormData data) async {
    setState(() {
      _saving = true;
      _priceError = null;
      _quantityError = null;
    });

    final ({Money salePrice, Money? costPrice})? prices = await _readPrices(
      l10n,
      data,
    );
    if (!mounted) {
      return;
    }
    if (prices == null) {
      setState(() => _saving = false);
      return;
    }

    final String reorderText = _reorderLevel.trim();
    Quantity? reorderLevel;
    if (reorderText.isNotEmpty) {
      final Quantity? parsed = Quantity.parse(reorderText).valueOrNull;
      if (parsed == null) {
        setState(() {
          _saving = false;
          _quantityError = l10n.catalogQuantityInvalid;
        });
        return;
      }
      reorderLevel = parsed;
    }

    // The only way a product is written: through the use cases, which validate,
    // check every reference and audit inside their own transaction.
    final String? productId = widget.productId;
    final Result<Product> result;
    if (productId == null) {
      result = await ref.read(createProductProvider)(
        name: _name,
        type: _type,
        stockUnitCode: _stockUnitCode ?? '',
        salePrice: prices.salePrice,
        categoryId: _categoryId,
        purchaseUnitCode: _purchaseUnitCode,
        costPrice: prices.costPrice,
        reorderLevel: reorderLevel,
      );
    } else {
      result = await ref.read(updateProductProvider)(
        id: productId,
        name: _name,
        type: _type,
        stockUnitCode: _stockUnitCode ?? '',
        salePrice: prices.salePrice,
        categoryId: _categoryId,
        purchaseUnitCode: _purchaseUnitCode,
        costPrice: prices.costPrice,
        reorderLevel: reorderLevel,
      );
    }

    if (!mounted) {
      return;
    }
    setState(() => _saving = false);

    final String message = switch (result) {
      Ok<Product>() => l10n.catalogSaved,
      Err<Product>(:final Failure failure) => _messageFor(failure, l10n),
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

    final Product? saved = result.valueOrNull;
    if (saved == null) {
      return;
    }

    // The list is held for the whole session, so it has to be told that the
    // catalogue changed before the new state is shown.
    ref.invalidate(productListProvider);
    context.go(CatalogRoutes.details(saved.id));
  }

  /// Turns a failure into something worth reading.
  ///
  /// The validation failures carry a code rather than a message, because the
  /// domain is pure Dart and cannot localise; the fallback covers the ones this
  /// form does not specialise.
  String _messageFor(Failure failure, AppLocalizations l10n) =>
      switch (failure.code) {
        ProductValidation.nameRequiredCode => l10n.catalogNameRequired,
        ProductValidation.stockUnitRequiredCode =>
          l10n.catalogStockUnitRequired,
        ProductValidation.priceNegativeCode => l10n.catalogPriceNegative,
        _ => ErrorMessages.of(l10n, failure),
      };
}

/// A section's heading, above a row of choices.
class _ChoiceLabel extends StatelessWidget {
  const _ChoiceLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.labelLarge);
}

/// One option in a row of choices.
///
/// The design system has no picker widget, and a row of buttons reads better
/// than a dropdown on the phone this is built for, so the choices are buttons
/// whose variant is the selection state.
class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => CustomButton(
    label: label,
    size: CustomButtonSize.small,
    variant: selected
        ? CustomButtonVariant.primary
        : CustomButtonVariant.outline,
    onPressed: onPressed,
  );
}
