import 'package:flutter/material.dart';

import '../../shared/design/app_dimens.dart';
import '../../shared/l10n/l10n.dart';
import 'app_destination.dart';

/// Body-only placeholder for destinations whose feature has not landed yet.
///
/// It deliberately has **no** `Scaffold`/`AppBar`: the adaptive shell owns the
/// application's single scaffold, which keeps the widget tree (and tests)
/// unambiguous.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({required this.destination, super.key});

  /// Which destination this placeholder stands in for.
  final AppDestination destination;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                destination.selectedIcon,
                size: AppSizes.iconXl * 2,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                destination.label(context.l10n),
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.placeholderComingSoon,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
