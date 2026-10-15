/// The public surface of the settings feature.
///
/// Another feature may not reach into `features/settings/data/` or
/// `features/settings/presentation/` directly (`AGENTS.md` §3, enforced by
/// `tool/check_boundaries.dart`); anything it legitimately needs is re-exported
/// here. Pure value types and use cases are also reachable straight from
/// `features/settings/domain/`, which is the better choice for a feature that
/// only needs a value type because this barrel drags Riverpod in with it.
///
/// The catalog feature needs the live `settingsRepository`, because the money a
/// product is priced in is the shop's currency (a setting), so this barrel is
/// the single sanctioned door to it.
library;

export 'data/settings_providers.dart';
export 'domain/business_profile.dart';
export 'domain/setting_keys.dart';
export 'domain/settings_repository.dart';
export 'domain/use_cases/load_business_profile.dart';
