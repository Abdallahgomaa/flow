import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_provider.dart';
import '../../shared/widgets/widgets.dart';

/// Day-1 shell screen.
///
/// This is a temporary development screen that showcases the design system
/// (buttons, fields, cards) and the theme toggle until the adaptive POS shell
/// lands in P0-10. All literal strings are placeholders and will be replaced
/// by ARB localisation in P0-09.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final ThemeMode themeMode = ref.watch(themeModeControllerProvider);
    final String themeLabel = switch (themeMode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flow'),
        actions: <Widget>[
          IconButton(
            key: const Key('theme-toggle'),
            tooltip: 'Switch theme',
            onPressed: () =>
                ref.read(themeModeControllerProvider.notifier).cycle(),
            icon: const Icon(Icons.dark_mode_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            Text(
              'Design System',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Theme: $themeLabel (tap the moon icon to cycle)',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            const CustomCard(
              title: 'CustomCard',
              subtitle: 'Elevated variant with header and content',
              child: _DesignSystemDemo(),
            ),
            const SizedBox(height: AppSpacing.lg),
            const CustomCard(
              variant: CustomCardVariant.outlined,
              title: 'Outlined card',
              subtitle: 'Good for grouped settings',
            ),
          ],
        ),
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CustomTextField(
          controller: _controller,
          label: 'Product search',
          hint: 'Name or barcode',
          prefixIcon: Icons.search,
          onSubmitted: (_) => _simulate(),
        ),
        const SizedBox(height: AppSpacing.md),
        CustomButton(
          label: 'Search',
          icon: Icons.search,
          isExpanded: true,
          isLoading: _loading,
          onPressed: _simulate,
        ),
        const SizedBox(height: AppSpacing.sm),
        const Row(
          children: <Widget>[
            Expanded(
              child: CustomButton(
                label: 'Secondary',
                variant: CustomButtonVariant.secondary,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomButton(
                label: 'Outline',
                variant: CustomButtonVariant.outline,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomButton(
                label: 'Ghost',
                variant: CustomButtonVariant.ghost,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _simulate() async {
    setState(() => _loading = true);
    await Future<void>.delayed(AppDurations.slow);
    if (!mounted) {
      return;
    }
    setState(() => _loading = false);
  }
}
