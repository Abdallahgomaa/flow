import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/money_core.dart';
import '../../shared/design/app_dimens.dart';
import '../../shared/l10n/l10n.dart';
import '../../shared/widgets/widgets.dart';
import '../theme/theme_provider.dart';
import 'demo_product.dart';

/// Point-of-sale landing page — the Day-1 design-system showcase.
///
/// This is a **body-only** page: the adaptive shell supplies the single
/// `Scaffold`/`AppBar`. The content is a temporary showcase until the real POS
/// UI lands; the search box filters the in-memory [DemoProduct] catalogue so it
/// returns visible results without a database.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = context.l10n;
    final ThemeMode themeMode = ref.watch(themeModeControllerProvider);
    final String themeLabel = switch (themeMode) {
      ThemeMode.system => l10n.themeModeSystem,
      ThemeMode.light => l10n.themeModeLight,
      ThemeMode.dark => l10n.themeModeDark,
    };

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Text(l10n.designSystemTitle, style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            themeLabel,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomCard(
            title: l10n.customCardTitle,
            subtitle: l10n.customCardSubtitle,
            child: const _DesignSystemDemo(),
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomCard(
            variant: CustomCardVariant.outlined,
            title: l10n.outlinedCardTitle,
            subtitle: l10n.outlinedCardSubtitle,
          ),
        ],
      ),
    );
  }
}

/// Interactive showcase of the shared widgets, including a working search.
class _DesignSystemDemo extends StatefulWidget {
  const _DesignSystemDemo();

  @override
  State<_DesignSystemDemo> createState() => _DesignSystemDemoState();
}

class _DesignSystemDemoState extends State<_DesignSystemDemo> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Demonstrates the button's loading state (the actual filtering is live).
  Future<void> _simulate() async {
    setState(() => _loading = true);
    await Future<void>.delayed(AppDurations.slow);
    if (!mounted) {
      return;
    }
    setState(() => _loading = false);
  }

  /// The live result section; empty until the user types something.
  List<Widget> _buildResults(AppLocalizations l10n, ThemeData theme) {
    final String query = _query.trim();
    if (query.isEmpty) {
      return const <Widget>[];
    }

    final List<DemoProduct> results = DemoProduct.values
        .where((DemoProduct product) => product.matches(l10n, query))
        .toList(growable: false);
    const MoneyFormatter formatter = MoneyFormatter();

    return <Widget>[
      const SizedBox(height: AppSpacing.md),
      Text(
        results.isEmpty
            ? l10n.searchNoResults
            : l10n.searchResultsCount(results.length),
        key: const Key('search-results-count'),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      for (final DemoProduct product in results)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _ProductResultTile(
            name: product.name(l10n),
            barcode: product.barcode,
            price: formatter.format(product.price),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CustomTextField(
          controller: _controller,
          label: l10n.productSearchLabel,
          hint: l10n.productSearchHint,
          prefixIcon: Icons.search,
          onChanged: (String value) => setState(() => _query = value),
          onSubmitted: (_) => _simulate(),
        ),
        const SizedBox(height: AppSpacing.md),
        CustomButton(
          label: l10n.actionSearch,
          icon: Icons.search,
          isExpanded: true,
          isLoading: _loading,
          onPressed: _simulate,
        ),
        ..._buildResults(l10n, theme),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            Expanded(
              child: CustomButton(
                label: l10n.buttonSecondary,
                variant: CustomButtonVariant.secondary,
                onPressed: _simulate,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomButton(
                label: l10n.buttonOutline,
                variant: CustomButtonVariant.outline,
                onPressed: _simulate,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomButton(
                label: l10n.buttonGhost,
                variant: CustomButtonVariant.ghost,
                onPressed: _simulate,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A single search result (name, barcode, formatted price).
class _ProductResultTile extends StatelessWidget {
  const _ProductResultTile({
    required this.name,
    required this.barcode,
    required this.price,
  });

  final String name;
  final String barcode;
  final String price;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return CustomCard(
      variant: CustomCardVariant.filled,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(name, style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  barcode,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(price, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}
