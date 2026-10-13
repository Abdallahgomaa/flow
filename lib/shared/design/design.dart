/// Flow design tokens.
///
/// These files are pure design primitives (colors, spacing, radius, sizing,
/// typography and the semantic [AppColorsExtension]). They live in `shared/`
/// — not in `app/` — so that widgets in `lib/shared/widgets/` can depend on
/// them without `shared` reaching up into `app` (enforced by
/// `tool/check_boundaries.dart`).
///
/// The composed `ThemeData` lives in `lib/app/theme/app_theme.dart`, which is
/// the only place allowed to assemble the Flutter theme.
library;

export 'app_colors.dart';
export 'app_dimens.dart';
export 'app_theme_extension.dart';
export 'app_typography.dart';
