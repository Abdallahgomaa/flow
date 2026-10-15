import 'package:flutter/material.dart';

import '../design/app_dimens.dart';

/// The inline strip that explains why the last action failed.
///
/// It lives in `shared` because every form that can be rejected should say so
/// the same way; the auth screens are its first two callers, and duplicating the
/// strip in each of them would be exactly the copy-paste the architecture rules
/// forbid.
class ErrorBanner extends StatelessWidget {
  /// Creates the banner.
  const ErrorBanner({required this.message, super.key});

  /// Already-localised explanation.
  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: AppRadius.input,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: AppSizes.iconMd,
            color: scheme.onErrorContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
