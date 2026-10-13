import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'device_id_provider.dart';

/// Derives the app's hardware id (HWID) from a raw device identifier.
///
/// The raw id never leaves this class in clear text: it is namespaced, hashed
/// with SHA-256 and returned as 64 lowercase hex characters — the value a
/// licence binds to.
final class HardwareId {
  /// Creates the derivation over [provider].
  const HardwareId({required this.provider, this.namespace = 'flow-pos'});

  /// Source of the raw, machine-bound identifier.
  final DeviceIdProvider provider;

  /// Salt mixed into the hash; changing it invalidates all issued licences.
  final String namespace;

  /// The 64-character lowercase hex HWID for the current device.
  Future<String> compute() async {
    final String raw = await provider.readRawDeviceId();
    final Hash hash = await Sha256().hash(utf8.encode('$namespace:$raw'));
    return hash.bytes
        .map((int byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
