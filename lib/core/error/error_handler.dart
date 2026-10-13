import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../result/failure.dart';
import '../utils/logger.dart';
import 'crash_reporter.dart';
import 'failure_mapper.dart';

/// Installable handler for application-wide errors.
///
/// Wires Flutter's framework errors (`FlutterError.onError`) and the platform
/// isolate errors (`PlatformDispatcher.onError`) into the Flow [AppLogger] and
/// an optional [CrashReporter], and swaps the default red error widget for a
/// friendly in-app screen via `ErrorWidget.builder`.
class GlobalErrorHandler {
  GlobalErrorHandler(
    this._logger, [
    this._reporter = const NoopCrashReporter(),
  ]);

  final AppLogger _logger;
  final CrashReporter _reporter;

  bool _installed = false;

  /// Whether [install] has already been called.
  bool get isInstalled => _installed;

  /// Installs the handlers. Idempotent.
  void install({
    Widget Function(FlutterErrorDetails details)? errorWidgetBuilder,
  }) {
    if (_installed) {
      return;
    }
    _installed = true;

    FlutterError.onError = (FlutterErrorDetails details) {
      handle(details.exception, details.stack, fatal: false, source: 'flutter');
      if (kDebugMode) {
        // Keep the pretty red screen while developing.
        FlutterError.presentError(details);
      }
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      handle(error, stack, fatal: true, source: 'platform');
      // Swallow the error so the framework doesn't crash the isolate.
      return true;
    };

    ErrorWidget.builder = errorWidgetBuilder ?? _defaultErrorWidgetBuilder;
  }

  /// Routes [error] through the logger and reporter.
  Future<void> handle(
    Object error,
    StackTrace? stackTrace, {
    required bool fatal,
    required String source,
  }) async {
    final StackTrace resolvedStack = stackTrace ?? StackTrace.current;
    final Failure failure = FailureMapper.fromError(error, resolvedStack);
    _logger.error(
      'Unhandled $source error: ${failure.message ?? failure.runtimeType}',
      name: 'core.error',
      error: error,
      stackTrace: resolvedStack,
      context: <String, Object?>{'source': source, 'fatal': fatal},
    );

    await _reporter.report(
      error,
      resolvedStack,
      context: <String, Object?>{'source': source},
      fatal: fatal,
    );
  }

  static Widget _defaultErrorWidgetBuilder(FlutterErrorDetails details) {
    // The exception message may contain PII; never forward it verbatim.
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: Text('Something went wrong')),
    );
  }
}
