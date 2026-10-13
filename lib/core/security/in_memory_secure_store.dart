import 'secure_store.dart';

/// In-memory [SecureStore].
///
/// Used by tests and by ephemeral (not-yet-persisted) sessions. It is
/// deliberately not a security boundary: the real app uses the platform
/// keystore through `FlutterSecureStore`.
class InMemorySecureStore implements SecureStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }
}
