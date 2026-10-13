import 'package:flutter/material.dart';

import '../design/app_dimens.dart';
import '../design/app_theme_extension.dart';

/// Visual emphasis of a [CustomButton].
enum CustomButtonVariant {
  /// Filled, brand-colored. Use for the single primary action of a screen.
  primary,

  /// Filled, secondary color. Use for supportive actions.
  secondary,

  /// Filled, destructive color. Use for irreversible or destructive actions.
  danger,

  /// Transparent with a border. Use for lower-emphasis actions.
  outline,

  /// Transparent, no border. Use for the lowest-emphasis actions.
  ghost,
}

/// Physical size preset of a [CustomButton].
enum CustomButtonSize { small, medium, large }

/// A unified, theme-driven button used across the whole application.
///
/// It delegates to Material buttons ([FilledButton], [OutlinedButton],
/// [TextButton]) so accessibility, focus and ink behaviour stay native while
/// the look is controlled by the Flow design tokens.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.size = CustomButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.focusNode,
    this.autofocus = false,
  });

  /// Visible, already-localised text of the button.
  final String label;

  /// Tap handler; `null` renders the button in its disabled state.
  final VoidCallback? onPressed;

  final CustomButtonVariant variant;
  final CustomButtonSize size;

  /// Optional leading icon (ignored while [isLoading]).
  final IconData? icon;

  /// Optional trailing icon.
  final IconData? trailingIcon;

  /// When `true` replaces the leading slot with a spinner and blocks taps.
  final bool isLoading;

  /// When `true` the button expands to the full available width.
  final bool isExpanded;

  final FocusNode? focusNode;
  final bool autofocus;

  bool get _isDisabled => onPressed == null || isLoading;

  _ButtonMetrics get _metrics => switch (size) {
    CustomButtonSize.small => const _ButtonMetrics(
      height: AppSizes.minTouchTarget,
      horizontal: AppSpacing.lg,
      icon: AppSizes.iconSm,
      spinner: 16,
    ),
    CustomButtonSize.medium => const _ButtonMetrics(
      height: 52,
      horizontal: AppSpacing.xl,
      icon: AppSizes.iconMd,
      spinner: 18,
    ),
    CustomButtonSize.large => const _ButtonMetrics(
      height: 56,
      horizontal: 28,
      icon: 22,
      spinner: 20,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final AppColorsExtension ext = context.appColors;
    final _ButtonMetrics metrics = _metrics;

    final TextStyle? textStyle = switch (size) {
      CustomButtonSize.small => theme.textTheme.labelMedium,
      CustomButtonSize.medium => theme.textTheme.labelLarge,
      CustomButtonSize.large => theme.textTheme.titleMedium,
    };

    final ButtonStyle style = _buildStyle(
      scheme: scheme,
      ext: ext,
      metrics: metrics,
      textStyle: textStyle,
    );

    final Widget child = _buildContent(
      scheme: scheme,
      ext: ext,
      metrics: metrics,
    );

    final Widget button = switch (variant) {
      CustomButtonVariant.primary ||
      CustomButtonVariant.secondary ||
      CustomButtonVariant.danger => FilledButton(
        onPressed: _isDisabled ? null : onPressed,
        style: style,
        focusNode: focusNode,
        autofocus: autofocus,
        child: child,
      ),
      CustomButtonVariant.outline => OutlinedButton(
        onPressed: _isDisabled ? null : onPressed,
        style: style,
        focusNode: focusNode,
        autofocus: autofocus,
        child: child,
      ),
      CustomButtonVariant.ghost => TextButton(
        onPressed: _isDisabled ? null : onPressed,
        style: style,
        focusNode: focusNode,
        autofocus: autofocus,
        child: child,
      ),
    };

    return isExpanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  ButtonStyle _buildStyle({
    required ColorScheme scheme,
    required AppColorsExtension ext,
    required _ButtonMetrics metrics,
    required TextStyle? textStyle,
  }) {
    final _ButtonColors colors = _colors(scheme);
    final bool isFilled =
        variant != CustomButtonVariant.outline &&
        variant != CustomButtonVariant.ghost;

    return ButtonStyle(
      minimumSize: WidgetStatePropertyAll<Size>(Size(0, metrics.height)),
      padding: WidgetStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(horizontal: metrics.horizontal),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle?>(textStyle),
      iconSize: WidgetStatePropertyAll<double>(metrics.icon),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: AppRadius.button),
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return isFilled ? ext.disabled : Colors.transparent;
        }
        return colors.background;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: 0.38);
        }
        return colors.foreground;
      }),
      side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
        final Color? borderColor = colors.border;
        if (borderColor == null) {
          return null;
        }
        return BorderSide(
          color: states.contains(WidgetState.disabled)
              ? ext.disabled
              : borderColor,
        );
      }),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) {
          return colors.foreground.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return colors.foreground.withValues(alpha: 0.08);
        }
        return null;
      }),
    );
  }

  _ButtonColors _colors(ColorScheme scheme) => switch (variant) {
    CustomButtonVariant.primary => _ButtonColors(
      background: scheme.primary,
      foreground: scheme.onPrimary,
    ),
    CustomButtonVariant.secondary => _ButtonColors(
      background: scheme.secondary,
      foreground: scheme.onSecondary,
    ),
    CustomButtonVariant.danger => _ButtonColors(
      background: scheme.error,
      foreground: scheme.onError,
    ),
    CustomButtonVariant.outline => _ButtonColors(
      background: Colors.transparent,
      foreground: scheme.primary,
      border: scheme.outline,
    ),
    CustomButtonVariant.ghost => _ButtonColors(
      background: Colors.transparent,
      foreground: scheme.primary,
    ),
  };

  Widget _buildContent({
    required ColorScheme scheme,
    required AppColorsExtension ext,
    required _ButtonMetrics metrics,
  }) {
    final _ButtonColors colors = _colors(scheme);

    if (!isLoading && icon == null && trailingIcon == null) {
      return Text(label);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (isLoading)
          SizedBox.square(
            dimension: metrics.spinner,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.foreground,
            ),
          )
        else if (icon != null)
          Icon(icon, size: metrics.icon),
        if (label.isNotEmpty) ...<Widget>[
          if (isLoading || icon != null) const SizedBox(width: AppSpacing.sm),
          Text(label),
        ],
        if (trailingIcon != null) ...<Widget>[
          const SizedBox(width: AppSpacing.sm),
          Icon(trailingIcon, size: metrics.icon),
        ],
      ],
    );
  }
}

/// Immutable size data for a button instance.
class _ButtonMetrics {
  const _ButtonMetrics({
    required this.height,
    required this.horizontal,
    required this.icon,
    required this.spinner,
  });

  final double height;
  final double horizontal;
  final double icon;
  final double spinner;
}

/// Resolved background/foreground/border colors for a variant.
class _ButtonColors {
  const _ButtonColors({
    required this.background,
    required this.foreground,
    this.border,
  });

  final Color background;
  final Color foreground;
  final Color? border;
}
