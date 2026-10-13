import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_flavor.dart';

part 'app_flavor_provider.g.dart';

/// Exposes the build [AppFlavor] through Riverpod.
///
/// The value is resolved from `--dart-define=APP_FLAVOR` at startup (see
/// `lib/bootstrap.dart`) and can be overridden in tests via
/// `appFlavorProvider.overrideWith((ref) => AppFlavor.dev)`.
@Riverpod(keepAlive: true)
AppFlavor appFlavor(Ref ref) => AppFlavor.fromEnvironment();
