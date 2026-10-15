import 'package:flow/shared/design/design.dart';
import 'package:flutter/material.dart';

/// A small, non-interactive label used across the catalogue screens (`P2-05`).
///
/// It lives here rather than twice inside the two screens that need it: "this
/// thing is retired" must look the same wherever it appears, and two private
/// copies is exactly how two things stop looking the same.
class CatalogBadge extends StatelessWidget {
  /// Creates the badge.
  const CatalogBadge({required this.label, super.key});

  /// The already-localised text.
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Second-level prose: "nothing here yet", or a rule that is not an error.
///
/// It is deliberately *not* `ErrorBanner`. A stock specialist being unable to see
/// prices is a permission, not a failure, and dressing it up in error colours
/// would tell the user something is broken when nothing is.
class CatalogMutedText extends StatelessWidget {
  /// Creates the text.
  const CatalogMutedText({required this.text, super.key});

  /// The already-localised text.
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
