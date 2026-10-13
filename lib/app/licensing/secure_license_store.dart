import 'package:flow/core/licensing/license_store.dart';
import 'package:flow/core/security/secure_store.dart';

/// [LicenseStore] that keeps the activated key in the platform keystore.
///
/// Reuses the same [SecureStore] abstraction as the key manager, so the licence
/// never lands in the database or in plain shared preferences.
class SecureLicenseStore implements LicenseStore {
  /// Wraps [store].
  SecureLicenseStore(this._store);

  /// Storage key inside the [SecureStore].
  static const String entryKey = 'flow.license.v1';

  final SecureStore _store;

  @override
  Future<String?> read() => _store.read(entryKey);

  @override
  Future<void> write(String rawKey) => _store.write(entryKey, rawKey);

  @override
  Future<void> clear() => _store.delete(entryKey);
}
