import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';

import 'hardware_id.dart';
import 'license.dart';
import 'license_key.dart';
import 'license_store.dart';
import 'license_verifier.dart';

/// Activates, validates and removes this device's offline licence.
final class LicenseService {
  /// Creates the service.
  LicenseService({
    required this.store,
    required this.verifier,
    required this.hardwareId,
    required this.clock,
  });

  /// Where the activated key is kept.
  final LicenseStore store;

  /// Signature/claims checker.
  final LicenseVerifier verifier;

  /// HWID derivation for the current device.
  final HardwareId hardwareId;

  /// Time source for expiry checks.
  final Clock clock;

  /// Verifies [rawKey] for this device and, on success, persists it.
  Future<Result<License>> activate(String rawKey) async {
    final ParsedLicenseKey? key = LicenseKey.tryDecode(rawKey);
    if (key == null) {
      return const Result<License>.err(
        ValidationFailure(message: 'the licence key is malformed'),
      );
    }

    final Result<License> result = await verifier.verify(
      key: key,
      hardwareId: await hardwareId.compute(),
      nowUtc: clock.nowUtc(),
    );

    switch (result) {
      case Ok<License>(:final License value):
        await store.write(rawKey);
        return Result<License>.ok(value);
      case Err<License>():
        return result;
    }
  }

  /// Re-validates the stored licence; call it on every start.
  Future<Result<License>> load() async {
    final String? rawKey = await store.read();
    if (rawKey == null) {
      return const Result<License>.err(
        NotFoundFailure(message: 'no licence has been activated'),
      );
    }
    return activate(rawKey);
  }

  /// Forgets the stored licence.
  Future<void> deactivate() => store.clear();
}
