/// Persists the activated licence key so it survives restarts.
///
/// The app implementation stores it in the platform keystore
/// (`SecureLicenseStore`); tests use an in-memory implementation.
abstract interface class LicenseStore {
  /// The stored key, or `null` when no licence has been activated.
  Future<String?> read();

  /// Stores [rawKey], replacing any previous value.
  Future<void> write(String rawKey);

  /// Removes the stored key.
  Future<void> clear();
}
