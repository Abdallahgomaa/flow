/// Supplies a raw, machine-bound identifier.
///
/// `core` only depends on this abstraction, so the licensing logic stays pure
/// and fully testable; the platform-specific implementation lives in the app
/// layer (`DeviceInfoDeviceIdProvider`).
abstract interface class DeviceIdProvider {
  /// The raw device identifier.
  ///
  /// Callers must never log it or store it in clear text: it is hashed into the
  /// HWID by `HardwareId`.
  Future<String> readRawDeviceId();
}
