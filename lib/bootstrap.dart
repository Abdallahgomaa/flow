import 'dart:async';
import 'dart:io';

import 'package:flow/core/database/database_connector.dart';
import 'package:flow/core/database/database_providers.dart';
import 'package:flow/core/licensing/hardware_id.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/security/key_manager.dart';
import 'package:flow/features/settings/data/settings_providers.dart';
import 'package:flow/features/settings/domain/app_preferences.dart';
import 'package:flow/features/settings/presentation/theme_mode_mapping.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/database/sqlcipher_database_connector.dart';
import 'app/l10n/locale_provider.dart';
import 'app/licensing/device_info_device_id_provider.dart';
import 'app/security/flutter_secure_store.dart';
import 'app/theme/theme_provider.dart';
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
/// * opens the encrypted local database and wires it into the container;
/// * restores the theme and language saved by a previous run;
/// * launches the widget tree inside a guarded zone.
Future<void> bootstrap({AppFlavor? flavor}) async {
  final AppFlavor resolvedFlavor = flavor ?? AppFlavor.fromEnvironment();
  final AppLogger logger = AppLogger.instance;
  final GlobalErrorHandler errorHandler = GlobalErrorHandler(logger);

  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      errorHandler.install(
        errorWidgetBuilder: (FlutterErrorDetails details) =>
            const AppErrorWidget(),
      );

      final DatabaseConnector? connector = await _openDatabase(logger);
      final ProviderContainer container = ProviderContainer(
        overrides: [
          appFlavorProvider.overrideWith((Ref ref) => resolvedFlavor),
          if (connector != null)
            databaseConnectorProvider.overrideWith((Ref ref) => connector),
        ],
      );

      await _restoreSavedPreferences(container, logger);

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

/// File name of the SQLCipher database inside the application support folder.
const String databaseFileName = 'flow.sqlite';

/// Opens the encrypted database, or returns `null` when it cannot be opened.
///
/// INTERIM (until the owner account lands in P1-11): there is no password UI
/// yet, so the data key is wrapped under a key derived from the device
/// fingerprint (HWID) rather than the owner's password. P1-11 re-wraps the very
/// same data key under the owner password via `KeyManager.changePassword`, so
/// databases created here stay readable. Returning `null` keeps the app usable:
/// the settings screen shows a retry card instead of crashing.
Future<DatabaseConnector?> _openDatabase(AppLogger logger) async {
  try {
    final Directory directory = await getApplicationSupportDirectory();
    final KeyManager keyManager = KeyManager(store: FlutterSecureStore());
    final String devicePassword = await HardwareId(
      provider: DeviceInfoDeviceIdProvider(),
    ).compute();

    if (await keyManager.isInitialized) {
      await keyManager.unlock(devicePassword);
    } else {
      await keyManager.initialize(devicePassword);
    }

    final String? keyHex = keyManager.dekHex;
    if (keyHex == null) {
      return null;
    }
    return SqlCipherDatabaseConnector(
      file: File(p.join(directory.path, databaseFileName)),
      keyHex: keyHex,
    );
  } on Object catch (error, stackTrace) {
    logger.error(
      'Could not open the database.',
      name: 'bootstrap',
      error: error,
      stackTrace: stackTrace,
    );
    return null;
  }
}

/// Applies the theme and language chosen during a previous run.
///
/// Runs before the first frame (so there is no flash of the default theme) and
/// uses `restore`, which does not write the values back.
Future<void> _restoreSavedPreferences(
  ProviderContainer container,
  AppLogger logger,
) async {
  try {
    final Result<AppPreferences> result = await container.read(
      loadAppPreferencesProvider,
    )();
    final AppPreferences preferences =
        result.valueOrNull ?? AppPreferences.initial;
    container
        .read(themeModeControllerProvider.notifier)
        .restore(preferences.theme.themeMode);
    final String? languageCode = preferences.languageCode;
    container
        .read(localeControllerProvider.notifier)
        .restore(languageCode == null ? null : Locale(languageCode));
  } on Object catch (error, stackTrace) {
    logger.warning(
      'Could not restore the saved preferences.',
      name: 'bootstrap',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
