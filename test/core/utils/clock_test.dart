import 'package:flow/core/utils/clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SystemClock', () {
    test('returns the current UTC instant', () {
      const SystemClock clock = SystemClock();
      final DateTime before = DateTime.now().toUtc();
      final DateTime now = clock.nowUtc();
      final DateTime after = DateTime.now().toUtc();

      expect(now.isUtc, isTrue);
      expect(now.isBefore(before), isFalse);
      expect(now.isAfter(after), isFalse);
    });
  });

  group('FixedClock', () {
    test('reports the injected instant in UTC', () {
      final DateTime instant = DateTime.utc(2026, 7, 8, 9, 10, 11, 123);
      final FixedClock clock = FixedClock(instant);

      expect(clock.nowUtc(), instant);
      expect(clock.nowUtc().isUtc, isTrue);
    });

    test('advances by a duration', () {
      final FixedClock clock = FixedClock(DateTime.utc(2026, 1, 1));
      clock.advance(const Duration(minutes: 5));

      expect(clock.nowUtc(), DateTime.utc(2026, 1, 1, 0, 5));
    });

    test('can be moved backwards with set', () {
      final FixedClock clock = FixedClock(DateTime.utc(2026, 1, 2));
      clock.set(DateTime.utc(2026, 1, 1));

      expect(clock.nowUtc(), DateTime.utc(2026, 1, 1));
    });

    test('normalises non-UTC input to UTC', () {
      final FixedClock clock = FixedClock(DateTime(2026));

      expect(clock.nowUtc().isUtc, isTrue);
    });
  });
}
