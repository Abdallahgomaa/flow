import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic colors that [ColorScheme] does not model (success, warning, info)
/// plus a few design tokens reused by the custom widgets.
///
/// Registered on [ThemeData.extensions] and read via [AppThemeContextX].
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
    required this.border,
    required this.disabled,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;

  /// Default hairline border for cards, dividers and enabled inputs.
  final Color border;

  /// Background used for disabled controls.
  final Color disabled;

  /// Light-mode semantic tokens.
  static const AppColorsExtension light = AppColorsExtension(
    success: AppColors.success,
    onSuccess: AppColors.neutral0,
    warning: AppColors.warning,
    onWarning: AppColors.neutral900,
    info: AppColors.info,
    onInfo: AppColors.neutral0,
    border: AppColors.neutral200,
    disabled: AppColors.neutral100,
  );

  /// Dark-mode semantic tokens.
  static const AppColorsExtension dark = AppColorsExtension(
    success: Color(0xFF4ADE80),
    onSuccess: Color(0xFF052E16),
    warning: Color(0xFFFBBF24),
    onWarning: Color(0xFF451A03),
    info: Color(0xFF38BDF8),
    onInfo: Color(0xFF082F49),
    border: AppColors.neutral600,
    disabled: AppColors.neutral800,
  );

  @override
  AppColorsExtension copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
    Color? border,
    Color? disabled,
  }) {
    return AppColorsExtension(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      border: border ?? this.border,
      disabled: disabled ?? this.disabled,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      border: Color.lerp(border, other.border, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
    );
  }
}

/// Convenience accessor for the Flow semantic colors.
extension AppThemeContextX on BuildContext {
  /// Returns the [AppColorsExtension] registered by [AppTheme].
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>() ??
      AppColorsExtension.light;
}
