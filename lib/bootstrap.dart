import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/app_flavor.dart';
import 'core/config/app_flavor_provider.dart';
import 'core/error/error.dart';
import 'core/utils/logger.dart';
import 'shared/widgets/app_error_widget.dart';

/// Entry point of the application runtime.
///
/// Responsibilities:
/// * resolves the build [AppFlavor] (`--dart-define=APP_FLAVOR`);
/// * configures the global error pipeline ([GlobalErrorHandler]);
/// * creates the [ProviderContainer] with env overrides;
/// * launches the widget tree inside a guarded zone.
Future<void> bootstrap({AppFlavor? flavor}) async {
  final AppFlavor resolvedFlavor = flavor ?? AppFlavor.fromEnvironment();
  final AppLogger logger = AppLogger.instance;
  final GlobalErrorHandler errorHandler = GlobalErrorHandler(logger);

  final ProviderContainer container = ProviderContainer(
    overrides: [appFlavorProvider.overrideWith((Ref ref) => resolvedFlavor)],
  );

  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      errorHandler.install(
        errorWidgetBuilder: (FlutterErrorDetails details) =>
            const AppErrorWidget(),
      );

      runApp(
        UncontrolledProviderScope(container: container, child: const FlowApp()),
      );
    },
    (Object error, StackTrace stackTrace) {
      // Async errors that escape the widget tree land here.
      errorHandler.handle(error, stackTrace, fatal: true, source: 'zone');
    },
  );
}
