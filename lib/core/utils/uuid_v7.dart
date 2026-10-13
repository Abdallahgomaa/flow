import 'dart:math';

import 'clock.dart';

/// Generates RFC 9562 UUID version 7 identifiers.
///
/// Layout (128 bits): a 48-bit big-endian millisecond timestamp
/// (`unix_ts_ms`), the 4-bit version (`7`), 12 bits of `rand_a`, the 2-bit
/// variant (`0b10`) and 62 bits of `rand_b`. Because the timestamp leads,
/// identifiers sort by creation time.
///
/// The generator is **monotonic**: within the same millisecond `rand_a` is
/// incremented, and once that 12-bit counter is exhausted the timestamp is
/// advanced by one millisecond. If the wall clock jumps backwards, the last
/// timestamp is reused so identifiers never go out of order.
final class UuidV7Generator {
  UuidV7Generator({required this.clock, Random? random})
    : _random = random ?? Random.secure();

  /// The clock that supplies the millisecond timestamp.
  final Clock clock;
  final Random _random;

  /// 12 bits of `rand_a` are available as a per-millisecond counter.
  static const int _counterMax = 0x1000;

  int? _lastMillis;
  int _counter = 0;

  /// Returns the next identifier in canonical `8-4-4-4-12` lowercase form.
  String next() {
    int millis = clock.nowUtc().millisecondsSinceEpoch;

    final int? last = _lastMillis;
    if (last != null && millis < last) {
      // Clock moved backwards: hold the line so ordering never regresses.
      millis = last;
    }

    if (_lastMillis != null && millis == _lastMillis) {
      _counter++;
      if (_counter >= _counterMax) {
        // rand_a exhausted: advance the timestamp and restart the counter.
        millis = _lastMillis! + 1;
        _counter = 0;
      }
    } else {
      _counter = 0;
    }
    _lastMillis = millis;

    final int randA = _counter & 0x0FFF;
    final List<int> bytes = List<int>.filled(16, 0);

    // Bytes 0..5: 48-bit millisecond timestamp, big-endian.
    for (int i = 0; i < 6; i++) {
      bytes[i] = (millis >> (8 * (5 - i))) & 0xFF;
    }
    // Byte 6: version (0111) + high nibble of rand_a.
    bytes[6] = 0x70 | ((randA >> 8) & 0x0F);
    // Byte 7: low byte of rand_a.
    bytes[7] = randA & 0xFF;
    // Byte 8: variant (10) + top 6 bits of rand_b.
    bytes[8] = 0x80 | _random.nextInt(0x40);
    // Bytes 9..15: remaining 56 bits of rand_b.
    for (int i = 9; i < 16; i++) {
      bytes[i] = _random.nextInt(0x100);
    }

    final StringBuffer hex = StringBuffer();
    for (final int byte in bytes) {
      hex.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    final String value = hex.toString();
    return '${value.substring(0, 8)}-'
        '${value.substring(8, 12)}-'
        '${value.substring(12, 16)}-'
        '${value.substring(16, 20)}-'
        '${value.substring(20)}';
  }

  /// Extracts the creation timestamp embedded in [uuid], or `null` when [uuid]
  /// is not a well-formed UUID string.
  static DateTime? timestampOf(String uuid) {
    final String hex = uuid.replaceAll('-', '');
    if (hex.length != 32) {
      return null;
    }
    final int? millis = int.tryParse(hex.substring(0, 12), radix: 16);
    if (millis == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }
}
