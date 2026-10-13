import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'secure_store.dart';

/// Thrown when a password fails to unwrap the data-encryption key.
class InvalidPasswordException implements Exception {
  /// Creates the exception.
  const InvalidPasswordException();

  @override
  String toString() =>
      'InvalidPasswordException: the password did not unlock '
      'the data-encryption key.';
}

/// Thrown when an operation needs a stored key that does not exist yet.
class KeyNotInitializedException implements Exception {
  /// Creates the exception.
  const KeyNotInitializedException();

  @override
  String toString() => 'KeyNotInitializedException: call initialize() first.';
}

/// Owns the application's data-encryption key (DEK).
///
/// Security model:
///  * The password never encrypts the database directly. It is stretched with
///    **Argon2id** into a key-encryption key (KEK).
///  * A random 256-bit **DEK** is what SQLCipher uses to encrypt the database.
///  * The KEK wraps the DEK with **AES-256-GCM**; only the wrapped blob is
///    persisted (in the [SecureStore]).
///  * Changing the password only re-wraps the DEK — the database file is never
///    re-encrypted.
///
/// This class is pure Dart: it has no Flutter dependency, so it is fully
/// unit-testable.
class KeyManager {
  /// Creates a key manager over [store].
  ///
  /// [memoryKiB], [parallelism] and [iterations] are the Argon2id cost
  /// parameters used when a key is (re)wrapped. The chosen parameters are
  /// stored alongside the blob, so a future change of defaults still unlocks
  /// existing data. Tests inject cheap values to stay fast.
  KeyManager({
    required this.store,
    this.memoryKiB = 65536,
    this.parallelism = 4,
    this.iterations = 3,
    AesGcm? cipher,
    Random? random,
  }) : _cipher = cipher ?? AesGcm.with256bits(),
       _random = random ?? Random.secure();

  /// Store key under which the wrapped DEK is persisted.
  static const String entryKey = 'flow.dek.v1';

  /// Format version of the wrapped-key blob.
  static const int formatVersion = 1;

  /// Length of the data-encryption key (256 bits).
  static const int dekLength = 32;

  /// Length of the Argon2id salt.
  static const int saltLength = 16;

  /// Argon2id memory cost, in kibibytes.
  final int memoryKiB;

  /// Argon2id parallelism (lanes).
  final int parallelism;

  /// Argon2id time cost (iterations).
  final int iterations;

  /// Backing store for the wrapped key.
  final SecureStore store;
  final AesGcm _cipher;
  final Random _random;

  Uint8List? _dek;

  /// Whether a wrapped key already exists in the store.
  Future<bool> get isInitialized async => await store.read(entryKey) != null;

  /// The in-memory DEK, or `null` while locked.
  Uint8List? get dek => _dek;

  /// The DEK as lowercase hex (the form SQLCipher expects), or `null` while
  /// locked.
  String? get dekHex {
    final Uint8List? dek = _dek;
    if (dek == null) {
      return null;
    }
    final StringBuffer buffer = StringBuffer();
    for (final int byte in dek) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  /// Creates a new random DEK and wraps it under a KEK derived from [password].
  ///
  /// Throws [StateError] when a key already exists (use [changePassword]).
  Future<void> initialize(String password) async {
    if (await isInitialized) {
      throw StateError('KeyManager is already initialized.');
    }
    final Uint8List dek = _randomBytes(dekLength);
    final Uint8List salt = _randomBytes(saltLength);
    final SecretKey kek = await _deriveKek(
      password,
      salt,
      memoryKiB,
      parallelism,
      iterations,
    );
    final SecretBox box = await _cipher.encrypt(dek, secretKey: kek);
    await store.write(
      entryKey,
      jsonEncode(<String, Object?>{
        'v': formatVersion,
        'm': memoryKiB,
        'p': parallelism,
        't': iterations,
        'salt': base64Encode(salt),
        'box': base64Encode(box.concatenation()),
      }),
    );
    _dek = dek;
  }

  /// Derives the KEK from [password] and unwraps the DEK into memory.
  ///
  /// Throws [InvalidPasswordException] when the password is wrong and
  /// [KeyNotInitializedException] when no key has been created yet.
  Future<void> unlock(String password) async {
    final _WrappedKey wrapped = await _read();
    final SecretKey kek = await _deriveKek(
      password,
      wrapped.salt,
      wrapped.memoryKiB,
      wrapped.parallelism,
      wrapped.iterations,
    );
    try {
      final List<int> dek = await _cipher.decrypt(wrapped.box, secretKey: kek);
      _dek = Uint8List.fromList(dek);
    } on SecretBoxAuthenticationError {
      throw const InvalidPasswordException();
    }
  }

  /// Re-wraps the existing DEK under [newPassword].
  ///
  /// The DEK itself does not change, so the database remains readable. Throws
  /// [InvalidPasswordException] when [currentPassword] is wrong.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final _WrappedKey wrapped = await _read();
    final SecretKey currentKek = await _deriveKek(
      currentPassword,
      wrapped.salt,
      wrapped.memoryKiB,
      wrapped.parallelism,
      wrapped.iterations,
    );
    final List<int> dek;
    try {
      dek = await _cipher.decrypt(wrapped.box, secretKey: currentKek);
    } on SecretBoxAuthenticationError {
      throw const InvalidPasswordException();
    }

    final Uint8List salt = _randomBytes(saltLength);
    final SecretKey newKek = await _deriveKek(
      newPassword,
      salt,
      memoryKiB,
      parallelism,
      iterations,
    );
    final SecretBox box = await _cipher.encrypt(dek, secretKey: newKek);
    await store.write(
      entryKey,
      jsonEncode(<String, Object?>{
        'v': formatVersion,
        'm': memoryKiB,
        'p': parallelism,
        't': iterations,
        'salt': base64Encode(salt),
        'box': base64Encode(box.concatenation()),
      }),
    );
    _dek = Uint8List.fromList(dek);
  }

  /// Drops the in-memory DEK. The wrapped key stays in the [SecureStore].
  void lock() {
    _dek = null;
  }

  Future<_WrappedKey> _read() async {
    final String? raw = await store.read(entryKey);
    if (raw == null) {
      throw const KeyNotInitializedException();
    }
    final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
    return _WrappedKey(
      memoryKiB: json['m'] as int,
      parallelism: json['p'] as int,
      iterations: json['t'] as int,
      salt: base64Decode(json['salt'] as String),
      box: SecretBox.fromConcatenation(
        base64Decode(json['box'] as String),
        nonceLength: _cipher.nonceLength,
        macLength: _cipher.macAlgorithm.macLength,
      ),
    );
  }

  Future<SecretKey> _deriveKek(
    String password,
    List<int> salt,
    int memory,
    int lanes,
    int rounds,
  ) {
    final Argon2id kdf = Argon2id(
      memory: memory,
      parallelism: lanes,
      iterations: rounds,
      hashLength: dekLength,
    );
    return kdf.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  Uint8List _randomBytes(int length) {
    final Uint8List bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }
}

/// Internal view of the persisted wrapped-key blob.
class _WrappedKey {
  const _WrappedKey({
    required this.memoryKiB,
    required this.parallelism,
    required this.iterations,
    required this.salt,
    required this.box,
  });

  final int memoryKiB;
  final int parallelism;
  final int iterations;
  final Uint8List salt;
  final SecretBox box;
}
