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

import '../domain/barcode.dart';
import 'catalog_routes.dart';
import 'catalog_ui_providers.dart';
import 'catalog_widgets.dart';
import 'product_labels.dart';
import 'product_view.dart';

/// One product in full: what it is, what it costs, its bands and its labels
/// (`P2-05`).
///
/// Body only, like the list: the shell owns the application's single `Scaffold`.
///
/// Retired things are shown, greyed, and never dropped — a band that no longer
/// prices and a barcode that no longer scans are still part of what the product
/// is, and hiding them is how a shop ends up re-creating something that already
/// exists.
class ProductDetailsScreen extends ConsumerWidget {
  /// Creates the screen for [productId].
  const ProductDetailsScreen({required this.productId, super.key});

  /// The product to show.
  final String productId;

  void _reload(WidgetRef ref) =>
      ref.invalidate(productDetailProvider(productId));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;

    return ref
        .watch(productDetailProvider(productId))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => AppErrorWidget(
            title: l10n.catalogDetailsTitle,
            message: l10n.catalogLoadFailed,
            onRetry: () => _reload(ref),
            retryLabel: l10n.actionRetry,
          ),
          data: (Result<ProductView> result) => result.fold(
            ok: (ProductView product) => _details(context, ref, l10n, product),
            err: (Failure failure) => AppErrorWidget(
              title: l10n.catalogDetailsTitle,
              message: ErrorMessages.of(l10n, failure),
              onRetry: () => _reload(ref),
              retryLabel: l10n.actionRetry,
            ),
          ),
        );
  }

  Widget _details(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ProductView product,
  ) {
    final ThemeData theme = Theme.of(context);
    final bool canManage = ref.watch(canManageProductsProvider);

    // Reading the price gate once, here, keeps the whole pricing section off the
    // screen for a role that may not see money: the bands below it carry no
    // meaning without an amount to compare them against.
    final bool showsPrices = product.showsPrices;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () => catalogBack(context),
                icon: const Icon(Icons.arrow_back),
                tooltip: l10n.catalogBack,
              ),
              Expanded(
                child: Text(
                  l10n.catalogDetailsTitle,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              if (canManage)
                CustomButton(
                  label: l10n.catalogEdit,
                  icon: Icons.edit_outlined,
                  variant: CustomButtonVariant.outline,
                  size: CustomButtonSize.small,
                  onPressed: () => context.go(CatalogRoutes.edit(product.id)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (product.isDisabled) ...<Widget>[
            ErrorBanner(message: l10n.catalogDisabled),
            const SizedBox(height: AppSpacing.lg),
          ],
          CustomCard(
            title: product.name,
            subtitle: productTypeLabel(l10n, product.type),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _Field(
                  label: l10n.catalogCategoryLabel,
                  value: product.categoryName ?? l10n.catalogNoCategory,
                ),
                _Field(
                  label: l10n.catalogStockUnitLabel,
                  value: product.stockUnitName ?? product.stockUnitCode,
                ),
                _Field(
                  label: l10n.catalogPurchaseUnitLabel,
                  value:
                      product.purchaseUnitName ??
                      product.purchaseUnitCode ??
                      l10n.catalogNoneOption,
                ),
                _Field(
                  label: l10n.catalogReorderLevel,
                  value:
                      product.reorderLevel?.toDecimalString() ??
                      l10n.catalogNoneOption,
                ),
              ],
            ),
          ),
          if (showsPrices) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            CustomCard(
              title: l10n.catalogSectionPricing,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _Field(
                    label: l10n.catalogSalePrice,
                    value: catalogMoney.format(product.salePrice!),
                  ),
                  _Field(
                    label: l10n.catalogCostPrice,
                    value: product.costPrice == null
                        ? l10n.catalogNoneOption
                        : catalogMoney.format(product.costPrice!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _BandsCard(productId: product.id),
          ],
          const SizedBox(height: AppSpacing.lg),
          _BarcodesCard(productId: product.id),
        ],
      ),
    );
  }
}

/// The product's price bands, honoured by the same price rule as the product.
class _BandsCard extends ConsumerWidget {
  const _BandsCard({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;

    return ref
        .watch(productTierPricesProvider(productId))
        .when(
          loading: () => CustomCard(
            title: l10n.catalogSectionBands,
            child: const LinearProgressIndicator(),
          ),
          error: (Object error, StackTrace stackTrace) => CustomCard(
            title: l10n.catalogSectionBands,
            child: ErrorBanner(message: l10n.catalogLoadFailed),
          ),
          data: (Result<List<TierPriceView>> result) => CustomCard(
            title: l10n.catalogSectionBands,
            child: result.fold(
              ok: (List<TierPriceView> bands) => bands.isEmpty
                  ? CatalogMutedText(text: l10n.catalogNoBands)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        for (final TierPriceView band in bands)
                          _Band(band: band),
                      ],
                    ),
              err: (Failure failure) =>
                  ErrorBanner(message: ErrorMessages.of(l10n, failure)),
            ),
          ),
        );
  }
}

/// One price band.
class _Band extends StatelessWidget {
  const _Band({required this.band});

  final TierPriceView band;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final Money? price = band.price;
    final Color? muted = band.isDisabled
        ? theme.colorScheme.onSurfaceVariant
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '${priceTierLabel(l10n, band.tier)} · '
              '${l10n.catalogBandFrom(band.minQuantity.toDecimalString())}',
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ),
          if (band.isDisabled) ...<Widget>[
            const SizedBox(width: AppSpacing.sm),
            CatalogBadge(label: l10n.catalogDisabled),
          ],
          if (price != null) ...<Widget>[
            const SizedBox(width: AppSpacing.sm),
            Text(
              catalogMoney.format(price),
              style: theme.textTheme.titleSmall?.copyWith(color: muted),
            ),
          ],
        ],
      ),
    );
  }
}

/// The labels that resolve to this product.
class _BarcodesCard extends ConsumerWidget {
  const _BarcodesCard({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;

    return ref
        .watch(productBarcodesProvider(productId))
        .when(
          loading: () => CustomCard(
            title: l10n.catalogSectionBarcodes,
            child: const LinearProgressIndicator(),
          ),
          error: (Object error, StackTrace stackTrace) => CustomCard(
            title: l10n.catalogSectionBarcodes,
            child: ErrorBanner(message: l10n.catalogLoadFailed),
          ),
          data: (Result<List<Barcode>> result) => CustomCard(
            title: l10n.catalogSectionBarcodes,
            child: result.fold(
              ok: (List<Barcode> barcodes) => barcodes.isEmpty
                  ? CatalogMutedText(text: l10n.catalogNoBarcodes)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        for (final Barcode barcode in barcodes)
                          _BarcodeRow(barcode: barcode),
                      ],
                    ),
              err: (Failure failure) =>
                  ErrorBanner(message: ErrorMessages.of(l10n, failure)),
            ),
          ),
        );
  }
}

/// One barcode.
class _BarcodeRow extends StatelessWidget {
  const _BarcodeRow({required this.barcode});

  final Barcode barcode;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final Color? muted = barcode.isDisabled
        ? theme.colorScheme.onSurfaceVariant
        : null;

    // Only a label that means more than one unit is worth annotating: on a
    // single unit the multiplier is noise.
    final bool scales = barcode.multiplier != Barcode.plainUnitMultiplier;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              barcode.code,
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ),
          if (scales) ...<Widget>[
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n.catalogBarcodeMultiplier(
                barcode.multiplier.toDecimalString(),
              ),
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ],
          if (barcode.isDisabled) ...<Widget>[
            const SizedBox(width: AppSpacing.sm),
            CatalogBadge(label: l10n.catalogDisabled),
          ],
        ],
      ),
    );
  }
}

/// A label/value pair inside a card.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
