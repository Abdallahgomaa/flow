import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';

/// Friendly fallback widget used by `ErrorWidget.builder` when a widget fails
/// to build, preventing the infamous "red screen" from leaking to users.
///
/// It is intentionally self-contained (no inherited theme assumptions) so it
/// can render even when the surrounding widget tree is broken.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({super.key, this.title, this.message, this.onRetry});

  /// Already-localised headline.
  final String? title;

  /// Already-localised description.
  final String? message;

  /// Optional retry callback (used by error views that can recover).
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // Intentionally avoids Theme.of(...) so it renders even when the
    // surrounding widget tree (and its inherited themes) is broken.
    final ColorScheme scheme = AppColors.light;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: scheme.surface,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.error_outline,
                  size: AppSizes.iconXl,
                  color: scheme.error,
                ),
                const SizedBox(height: AppSpacing.md),
                if (title != null)
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (message != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                if (onRetry != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  OutlinedButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('title', title))
      ..add(StringProperty('message', message));
  }
}
