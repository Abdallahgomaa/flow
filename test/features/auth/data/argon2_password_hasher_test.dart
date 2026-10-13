import 'dart:math';

import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/features/auth/data/argon2_password_hasher.dart';
import 'package:flow/features/auth/domain/password_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Cheap Argon2id parameters keep the suite fast; production uses the
  // calibrated defaults (16 MiB / 2 iterations — see EXECUTION_STATE.md).
  Argon2PasswordHasher buildHasher({Random? random}) => Argon2PasswordHasher(
    memoryKiB: 256,
    iterations: 1,
    parallelism: 1,
    random: random,
  );

  test('production defaults stay at the calibrated cost', () {
    final Argon2PasswordHasher hasher = Argon2PasswordHasher();

    expect(Argon2PasswordHasher.defaultMemoryKiB, 16384);
    expect(Argon2PasswordHasher.defaultIterations, 2);
    expect(Argon2PasswordHasher.defaultParallelism, 1);
    expect(Argon2PasswordHasher.defaultHashLength, 32);
    expect(Argon2PasswordHasher.defaultSaltLength, 16);
    expect(hasher.memoryKiB, Argon2PasswordHasher.defaultMemoryKiB);
    expect(hasher.iterations, Argon2PasswordHasher.defaultIterations);
  });

  test('a hash verifies its own secret and rejects another', () async {
    final Argon2PasswordHasher hasher = buildHasher();

    final Result<String> encoded = await hasher.hash('correct horse');
    final String stored = encoded.valueOrNull!;

    expect(
      (await hasher.verify(
        secret: 'correct horse',
        encodedHash: stored,
      )).valueOrNull,
      isTrue,
    );
    expect(
      (await hasher.verify(
        secret: 'correct Horse',
        encodedHash: stored,
      )).valueOrNull,
      isFalse,
    );
  });

  test('a blank candidate is a plain mismatch, never an error', () async {
    final Argon2PasswordHasher hasher = buildHasher();
    final String stored = (await hasher.hash('1234')).valueOrNull!;

    final Result<bool> verified = await hasher.verify(
      secret: '',
      encodedHash: stored,
    );

    expect(verified, isA<Ok<bool>>());
    expect(verified.valueOrNull, isFalse);
  });

  test('the same secret hashes differently every time', () async {
    final Argon2PasswordHasher hasher = buildHasher();

    final String first = (await hasher.hash('1234')).valueOrNull!;
    final String second = (await hasher.hash('1234')).valueOrNull!;

    expect(first, isNot(second));
    expect(
      (await hasher.verify(secret: '1234', encodedHash: first)).valueOrNull,
      isTrue,
    );
    expect(
      (await hasher.verify(secret: '1234', encodedHash: second)).valueOrNull,
      isTrue,
    );
  });

  test('an injected Random makes the salt reproducible', () async {
    // The seam exists so tests (and only tests) can be deterministic.
    final String first = (await buildHasher(random: Random(7)).hash('1234'))
        .valueOrNull!;
    final String second = (await buildHasher(random: Random(7)).hash('1234'))
        .valueOrNull!;

    expect(first, second);
  });

  test('the stored value is a self-describing PHC string', () async {
    final Argon2PasswordHasher hasher = buildHasher();

    final String stored = (await hasher.hash('1234')).valueOrNull!;

    // $argon2id$v=19$m=256,t=1,p=1$<salt>$<digest>
    expect(stored, startsWith(r'$argon2id$v=19$'));
    expect(stored, contains('m=256,t=1,p=1'));
    expect(stored.split(r'$'), hasLength(6));
  });

  test('the stored value never contains the secret', () async {
    final Argon2PasswordHasher hasher = buildHasher();

    final String stored = (await hasher.hash('super-secret')).valueOrNull!;

    expect(stored, isNot(contains('super-secret')));
  });

  test('a blank secret is refused instead of stored', () async {
    final Argon2PasswordHasher hasher = buildHasher();

    final Result<String> encoded = await hasher.hash('');

    expect(encoded, isA<Err<String>>());
    expect(encoded.failureOrNull, isA<ValidationFailure>());
    expect(encoded.failureOrNull?.code, PasswordHasher.emptySecretCode);
  });

  test('a hash written with other cost parameters still verifies', () async {
    // The cost travels inside the string, so raising the defaults later must
    // not invalidate what is already stored.
    final Argon2PasswordHasher older = Argon2PasswordHasher(
      memoryKiB: 512,
      iterations: 3,
      parallelism: 1,
    );
    final Argon2PasswordHasher current = buildHasher();

    final String stored = (await older.hash('1234')).valueOrNull!;

    expect(stored, contains('m=512,t=3,p=1'));
    expect(
      (await current.verify(secret: '1234', encodedHash: stored)).valueOrNull,
      isTrue,
    );
    expect(
      (await current.verify(secret: '4321', encodedHash: stored)).valueOrNull,
      isFalse,
    );
  });

  test(
    'a damaged or foreign stored value is reported, not swallowed',
    () async {
      final Argon2PasswordHasher hasher = buildHasher();

      final List<String> damaged = <String>[
        '',
        'not-a-hash',
        r'$argon2i$v=19$m=256,t=1,p=1$c2FsdA$aGFzaA',
        r'$argon2id$v=16$m=256,t=1,p=1$c2FsdA$aGFzaA',
        r'$argon2id$v=19$m=0,t=1,p=1$c2FsdA$aGFzaA',
        r'$argon2id$v=19$m=256,t=1$c2FsdA$aGFzaA',
        r'$argon2id$v=19$m=256,t=1,p=1$$aGFzaA',
      ];

      for (final String encoded in damaged) {
        final Result<bool> verified = await hasher.verify(
          secret: '1234',
          encodedHash: encoded,
        );
        expect(
          verified.failureOrNull?.code,
          PasswordHasher.malformedHashCode,
          reason: 'expected a malformed-hash failure for "$encoded"',
        );
      }
    },
  );

  test('the production cost stays inside a sane time budget', () async {
    // Calibrated to ≈250 ms on the reference machine (tool/_argon2_probe.dart,
    // recorded in EXECUTION_STATE.md). The bound is deliberately loose so a
    // slow CI host does not flake, while a tenfold parameter mistake fails.
    final Argon2PasswordHasher hasher = Argon2PasswordHasher();

    final Stopwatch watch = Stopwatch()..start();
    final Result<String> encoded = await hasher.hash('1234');
    watch.stop();

    expect(encoded.isOk, isTrue);
    expect(watch.elapsedMilliseconds, lessThan(3000));
  });
}
