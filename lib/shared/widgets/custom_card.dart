import 'package:flutter/material.dart';

import '../design/app_dimens.dart';
import '../design/app_theme_extension.dart';

/// Visual style of a [CustomCard].
enum CustomCardVariant {
  /// Raised surface (default).
  elevated,

  /// Flat surface with a hairline border.
  outlined,

  /// Flat, filled surface with no border.
  filled,
}

/// A unified, theme-driven container used to group content and actions.
class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.footer,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.variant = CustomCardVariant.elevated,
    this.color,
  });

  /// Main content of the card.
  final Widget? child;

  /// Already-localised header title.
  final String? title;

  /// Already-localised header subtitle.
  final String? subtitle;

  /// Optional widget shown before the title (e.g. an avatar or icon).
  final Widget? leading;

  /// Optional widget shown after the title (e.g. a menu or badge).
  final Widget? trailing;

  /// Optional widget rendered below [child].
  final Widget? footer;

  /// When set the whole card becomes tappable.
  final VoidCallback? onTap;

  final EdgeInsetsGeometry padding;
  final CustomCardVariant variant;

  /// Overrides the resolved surface color when provided.
  final Color? color;

  bool get _hasHeader =>
      title != null || subtitle != null || leading != null || trailing != null;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AppColorsExtension ext = context.appColors;
    final bool isDark = scheme.brightness == Brightness.dark;

    final Color background = color ?? _backgroundColor(scheme);
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: AppRadius.card,
      side: variant == CustomCardVariant.outlined
          ? BorderSide(color: ext.border)
          : BorderSide.none,
    );

    final Widget content = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (_hasHeader) _buildHeader(context),
          if (_hasHeader && child != null)
            const SizedBox(height: AppSpacing.md),
          ?child,
          if (footer != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            footer!,
          ],
        ],
      ),
    );

    return Material(
      color: background,
      elevation: variant == CustomCardVariant.elevated ? (isDark ? 0 : 1) : 0,
      shadowColor: scheme.shadow,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        canRequestFocus: onTap != null,
        child: content,
      ),
    );
  }

  Color _backgroundColor(ColorScheme scheme) => switch (variant) {
    CustomCardVariant.elevated => scheme.surfaceContainerLow,
    CustomCardVariant.outlined => scheme.surface,
    CustomCardVariant.filled => scheme.surfaceContainerHigh,
  };

  Widget _buildHeader(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (leading != null) ...<Widget>[
          leading!,
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (title != null) Text(title!, style: text.titleMedium),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xxs),
                  child: Text(
                    subtitle!,
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: AppSpacing.md),
          trailing!,
        ],
      ],
    );
  }
}
