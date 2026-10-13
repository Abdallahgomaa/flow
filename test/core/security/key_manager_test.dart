import 'dart:typed_data';

import 'package:flow/core/security/security.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Cheap Argon2id parameters keep the suite fast; production uses the
  // class defaults (64 MiB / 4 lanes / 3 iterations).
  KeyManager buildManager([SecureStore? store]) => KeyManager(
    store: store ?? InMemorySecureStore(),
    memoryKiB: 256,
    parallelism: 1,
    iterations: 1,
  );

  test(
    'initialize creates a 32-byte DEK and persists a wrapped blob',
    () async {
      final InMemorySecureStore store = InMemorySecureStore();
      final KeyManager manager = buildManager(store);

      expect(await manager.isInitialized, isFalse);
      await manager.initialize('correct horse battery staple');

      expect(await manager.isInitialized, isTrue);
      expect(manager.dek, isNotNull);
      expect(manager.dek, hasLength(KeyManager.dekLength));
      expect(manager.dekHex, hasLength(KeyManager.dekLength * 2));

      final String blob = (await store.read(KeyManager.entryKey))!;
      // The raw key must never be stored in clear text.
      expect(blob.contains(manager.dekHex!), isFalse);
      expect(blob.contains('"v":${KeyManager.formatVersion}'), isTrue);
    },
  );

  test('initialize twice is rejected', () async {
    final KeyManager manager = buildManager();
    await manager.initialize('pw');
    expect(() => manager.initialize('pw'), throwsStateError);
  });

  test('lock clears the in-memory DEK', () async {
    final KeyManager manager = buildManager();
    await manager.initialize('pw');
    manager.lock();
    expect(manager.dek, isNull);
    expect(manager.dekHex, isNull);
  });

  test('unlock rejects a wrong password and accepts the right one', () async {
    final InMemorySecureStore store = InMemorySecureStore();
    final KeyManager manager = buildManager(store);
    await manager.initialize('right');
    final Uint8List original = manager.dek!;

    manager.lock();
    await expectLater(
      manager.unlock('wrong'),
      throwsA(isA<InvalidPasswordException>()),
    );
    expect(manager.dek, isNull);

    await manager.unlock('right');
    expect(manager.dek, equals(original));
  });

  test('unlock before initialize reports a missing key', () async {
    final KeyManager manager = buildManager();
    await expectLater(
      manager.unlock('any'),
      throwsA(isA<KeyNotInitializedException>()),
    );
  });

  test('changePassword re-wraps the same DEK', () async {
    final KeyManager manager = buildManager();
    await manager.initialize('old');
    final Uint8List original = manager.dek!;

    await expectLater(
      manager.changePassword(currentPassword: 'nope', newPassword: 'new'),
      throwsA(isA<InvalidPasswordException>()),
    );

    await manager.changePassword(currentPassword: 'old', newPassword: 'new');
    expect(manager.dek, equals(original));

    manager.lock();
    await expectLater(
      manager.unlock('old'),
      throwsA(isA<InvalidPasswordException>()),
    );
    await manager.unlock('new');
    expect(manager.dek, equals(original));
  });
}
