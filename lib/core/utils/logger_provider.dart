import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'logger.dart';

part 'logger_provider.g.dart';

/// Exposes the application [AppLogger] through Riverpod so it can be replaced
/// in tests or features without touching the global singleton:
///
/// ```dart
/// ProviderScope(overrides: [appLoggerProvider.overrideWithValue(custom)])
/// ```
@Riverpod(keepAlive: true)
AppLogger appLogger(Ref ref) => AppLogger.instance;
