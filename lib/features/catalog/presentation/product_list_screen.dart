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

import 'catalog_routes.dart';
import 'catalog_ui_providers.dart';
import 'catalog_widgets.dart';
import 'product_labels.dart';
import 'product_view.dart';

/// The product list — the products destination of the adaptive shell (`P2-05`).
///
/// Body only, like every other destination: the shell owns the application's
/// single `Scaffold`, so this returns content and nothing else.
///
/// The list is lazy (`ListView.separated` builds rows on demand) and filters in
/// memory. That is the right trade for an offline catalogue a single device
/// already holds on disk: a second database round-trip per keystroke would cost
/// more than the filter saves.
class ProductListScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reload() => ref.invalidate(productListProvider);

  void _open(ProductView product) =>
      context.go(CatalogRoutes.details(product.id));

  void _create() => context.go(CatalogRoutes.create);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return ref
        .watch(productListProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => AppErrorWidget(
            title: l10n.catalogTitle,
            message: l10n.catalogLoadFailed,
            onRetry: _reload,
            retryLabel: l10n.actionRetry,
          ),
          data: (Result<List<ProductView>> result) => result.fold(
            ok: (List<ProductView> products) => _catalogue(l10n, products),
            err: (Failure failure) => AppErrorWidget(
              title: l10n.catalogTitle,
              message: ErrorMessages.of(l10n, failure),
              onRetry: _reload,
              retryLabel: l10n.actionRetry,
            ),
          ),
        );
  }

  Widget _catalogue(AppLocalizations l10n, List<ProductView> products) {
    final ThemeData theme = Theme.of(context);

    // A product cannot exist without a price (`CreateProduct` requires one), so
    // only a role that may set prices is offered the create action. Editing the
    // rest of a product stays open to the stock specialist.
    final bool canCreate =
        ref.watch(canManageProductsProvider) &&
        ref.watch(canViewPricesProvider);

    final String query = _search.text.trim().toLowerCase();
    final List<ProductView> visible = query.isEmpty
        ? products
        : <ProductView>[
            for (final ProductView product in products)
              if (product.name.toLowerCase().contains(query)) product,
          ];

    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        l10n.catalogTitle,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    if (canCreate)
                      CustomButton(
                        label: l10n.catalogNewProduct,
                        icon: Icons.add,
                        onPressed: _create,
                      ),
                  ],
                ),
                if (products.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.catalogProductsCount(products.length),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CustomTextField(
                    controller: _search,
                    label: l10n.productSearchLabel,
                    hint: l10n.productSearchHint,
                    prefixIcon: Icons.search,
                    onChanged: (String value) => setState(() {}),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? _EmptyCatalogue(
                    title: products.isEmpty
                        ? l10n.catalogEmpty
                        : l10n.searchNoResults,
                    message: products.isEmpty
                        ? l10n.catalogEmptyHint
                        : l10n.catalogNoMatchesHint,
                    actionLabel: canCreate && products.isEmpty
                        ? l10n.catalogNewProduct
                        : null,
                    onAction: canCreate && products.isEmpty ? _create : null,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    itemCount: visible.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (BuildContext context, int index) =>
                        _ProductTile(
                          product: visible[index],
                          onTap: () => _open(visible[index]),
                        ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// One row of the catalogue.
///
/// The price is rendered only when the view carries one. There is no `if` here
/// that could be forgotten or inverted: a price-blind role receives a
/// `ProductView` whose `salePrice` is already `null` (`product_view.dart`).
class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onTap});

  final ProductView product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final Money? price = product.salePrice;

    final List<String> parts = <String>[
      productTypeLabel(l10n, product.type),
      if (product.categoryName != null) product.categoryName!,
      if (product.stockUnitName != null) product.stockUnitName!,
    ];

    return CustomCard(
      variant: CustomCardVariant.filled,
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  product.name,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  parts.join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (product.isDisabled) ...<Widget>[
            const SizedBox(width: AppSpacing.sm),
            CatalogBadge(label: l10n.catalogDisabled),
          ],
          if (price != null) ...<Widget>[
            const SizedBox(width: AppSpacing.sm),
            Text(catalogMoney.format(price), style: theme.textTheme.titleSmall),
          ],
        ],
      ),
    );
  }
}

/// What the list shows when there is nothing to show.
class _EmptyCatalogue extends StatelessWidget {
  const _EmptyCatalogue({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? actionLabel = this.actionLabel;
    final VoidCallback? onAction = this.onAction;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.inventory_2_outlined,
              size: AppSizes.iconXl * 2,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              CustomButton(
                label: actionLabel,
                icon: Icons.add,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
