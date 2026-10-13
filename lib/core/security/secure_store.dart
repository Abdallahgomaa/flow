/// Minimal key/value storage for secrets.
///
/// The application is backed by the platform keystore/keychain
/// (`FlutterSecureStore`), while tests and ephemeral sessions use
/// `InMemorySecureStore`. Only the wrapped data-encryption key ever lives here.
abstract interface class SecureStore {
  /// Reads the value stored under [key], or `null` when absent.
  Future<String?> read(String key);

  /// Stores [value] under [key], overwriting any previous value.
  Future<void> write(String key, String value);

  /// Removes the entry stored under [key] (no-op when absent).
  Future<void> delete(String key);
}
