import 'package:flow/core/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(AppLogger.reset);
  tearDown(AppLogger.reset);

  test('writes records through configured sinks', () {
    final MemoryLogSink sink = MemoryLogSink();
    AppLogger.configure(level: LogLevel.debug, sinks: <LogSink>[sink]);

    AppLogger.instance.info('hello', name: 'test');

    expect(sink.records, hasLength(1));
    expect(sink.records.single.message, 'hello');
    expect(sink.records.single.level, LogLevel.info);
    expect(sink.records.single.name, 'test');
  });

  test('filters records below the configured threshold', () {
    final MemoryLogSink sink = MemoryLogSink();
    AppLogger.configure(level: LogLevel.warning, sinks: <LogSink>[sink]);

    AppLogger.instance.debug('dropped');
    AppLogger.instance.info('dropped');
    AppLogger.instance.warning('kept');

    expect(sink.records.map((LogRecord r) => r.message), <String>['kept']);
  });

  test('redacts sensitive payload keys before delivery', () {
    final MemoryLogSink sink = MemoryLogSink();
    AppLogger.configure(level: LogLevel.debug, sinks: <LogSink>[sink]);

    AppLogger.instance.debug(
      'login started',
      context: <String, Object?>{
        'username': 'admin',
        'password': 'hunter2',
        'api_key': 'abc123',
      },
    );

    final LogRecord record = sink.records.single;
    expect(record.context['username'], 'admin');
    expect(record.context['password'], Redactor.mask);
    expect(record.context['api_key'], Redactor.mask);
  });

  test('redactor sanitises nested structures recursively', () {
    final Object? sanitized = Redactor.sanitize(<String, Object?>{
      'api_key': 'secret',
      'list': <Object?>[
        1,
        <String, Object?>{'pin': 1234, 'count': 2},
      ],
    });

    expect(sanitized, <String, Object?>{
      'api_key': Redactor.mask,
      'list': <Object?>[
        1,
        <String, Object?>{'pin': Redactor.mask, 'count': 2},
      ],
    });
  });

  test('memory sink is bounded and can be cleared', () {
    final MemoryLogSink sink = MemoryLogSink(capacity: 2);
    AppLogger.configure(level: LogLevel.debug, sinks: <LogSink>[sink]);

    AppLogger.instance.debug('one');
    AppLogger.instance.debug('two');
    AppLogger.instance.debug('three');

    expect(sink.records.map((LogRecord r) => r.message), <String>[
      'two',
      'three',
    ]);

    sink.clear();
    expect(sink.records, isEmpty);
  });
}
