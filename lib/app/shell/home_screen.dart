import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/design/app_dimens.dart';
import '../../shared/l10n/l10n.dart';
import '../../shared/widgets/widgets.dart';
import '../theme/theme_provider.dart';

/// Point-of-sale landing page — the Day-1 design-system showcase.
///
/// This is a **body-only** page: the adaptive shell supplies the single
/// `Scaffold`/`AppBar`. The content is a temporary showcase until the real POS
/// UI lands.
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

/// Interactive showcase of the shared widgets.
class _DesignSystemDemo extends StatefulWidget {
  const _DesignSystemDemo();

  @override
  State<_DesignSystemDemo> createState() => _DesignSystemDemoState();
}

class _DesignSystemDemoState extends State<_DesignSystemDemo> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _simulate() async {
    setState(() => _loading = true);
    await Future<void>.delayed(AppDurations.slow);
    if (!mounted) {
      return;
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CustomTextField(
          controller: _controller,
          label: l10n.productSearchLabel,
          hint: l10n.productSearchHint,
          prefixIcon: Icons.search,
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
