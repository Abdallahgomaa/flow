import 'package:flow/core/security/secure_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// [SecureStore] backed by the platform keystore (Android Keystore, iOS
/// Keychain, Windows Credential Manager, …).
///
/// Never used in unit tests: the plugin needs a real platform channel, so tests
/// inject `InMemorySecureStore` instead.
class FlutterSecureStore implements SecureStore {
  /// Creates the store over an optional [storage] (injected in tests).
  FlutterSecureStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
