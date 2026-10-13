import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'clock.dart';
import 'logger.dart';
import 'utils_providers.dart';

part 'logger_provider.g.dart';

/// Exposes the application [AppLogger] through Riverpod so it can be replaced
/// in tests or features without touching the global singleton:
///
/// ```dart
/// ProviderScope(overrides: [appLoggerProvider.overrideWithValue(custom)])
/// ```
///
/// The logger's timestamp source is the injected [clockProvider], so every
/// record can be made deterministic in tests by overriding the clock.
@Riverpod(keepAlive: true)
AppLogger appLogger(Ref ref) {
  final Clock clock = ref.watch(clockProvider);
  AppLogger.configure(nowUtc: clock.nowUtc);
  return AppLogger.instance;
}
