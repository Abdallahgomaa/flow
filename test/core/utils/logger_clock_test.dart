import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the injected clock for record timestamps', () {
    final FixedClock clock = FixedClock(
      DateTime.utc(2026, 7, 8, 9, 10, 11, 123),
    );
    final MemoryLogSink sink = MemoryLogSink();
    AppLogger.configure(
      level: LogLevel.trace,
      sinks: <LogSink>[sink],
      nowUtc: clock.nowUtc,
    );
    addTearDown(AppLogger.reset);

    AppLogger.instance.info('hello', name: 'test');

    expect(sink.records, hasLength(1));
    expect(sink.records.single.timeUtc, clock.nowUtc());
  });
}
