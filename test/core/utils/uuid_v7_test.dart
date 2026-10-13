import 'dart:math';

import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/uuid_v7.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final RegExp pattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  test('matches the RFC 9562 canonical shape', () {
    final UuidV7Generator generator = UuidV7Generator(
      clock: FixedClock(DateTime.utc(2026, 7, 8, 9, 10, 11, 123)),
      random: Random(1),
    );

    for (int i = 0; i < 1000; i++) {
      final String id = generator.next();
      expect(id.length, 36);
      expect(pattern.hasMatch(id), isTrue, reason: id);
      expect(id[14], '7');
      expect('89ab'.contains(id[19]), isTrue, reason: id);
    }
  });

  test('is strictly ascending within a single millisecond', () {
    final UuidV7Generator generator = UuidV7Generator(
      clock: FixedClock(DateTime.utc(2026, 7, 8)),
      random: Random(7),
    );

    String previous = generator.next();
    for (int i = 0; i < 5000; i++) {
      final String id = generator.next();
      expect(id.compareTo(previous), greaterThan(0), reason: '$previous < $id');
      previous = id;
    }
  });

  test('stays ordered even when the clock moves backwards', () {
    final FixedClock clock = FixedClock(DateTime.utc(2026, 7, 8, 12));
    final UuidV7Generator generator = UuidV7Generator(
      clock: clock,
      random: Random(3),
    );

    final String first = generator.next();
    clock.set(DateTime.utc(2026, 7, 8, 11)); // one hour earlier
    final String second = generator.next();

    expect(second.compareTo(first), greaterThan(0));
  });

  test('embeds a recoverable timestamp', () {
    final DateTime instant = DateTime.utc(2026, 7, 8, 9, 10, 11, 123);
    final UuidV7Generator generator = UuidV7Generator(
      clock: FixedClock(instant),
      random: Random(5),
    );

    expect(UuidV7Generator.timestampOf(generator.next()), instant);
  });

  test('timestampOf rejects malformed ids', () {
    expect(UuidV7Generator.timestampOf('not-a-uuid'), isNull);
    expect(UuidV7Generator.timestampOf(''), isNull);
    expect(UuidV7Generator.timestampOf('01890a5d-ac96-7'), isNull);
  });
}
