import 'dart:developer' as developer;

/// Severity of a log record.
enum LogLevel {
  trace(300),
  debug(500),
  info(800),
  warning(900),
  error(1000),
  fatal(1200);

  const LogLevel(this.developerLevel);

  /// Maps to the `dart:developer` level so IDE consoles stay colour-coded.
  final int developerLevel;
}

/// An immutable, sanitised log entry.
final class LogRecord {
  const LogRecord({
    required this.level,
    required this.message,
    required this.timeUtc,
    this.name,
    this.error,
    this.stackTrace,
    this.context = const <String, Object?>{},
  });

  final LogLevel level;
  final String message;
  final DateTime timeUtc;

  /// Short logger/component name (e.g. `pos.cart`).
  final String? name;

  final Object? error;
  final StackTrace? stackTrace;

  /// Structured, already-sanitised metadata.
  final Map<String, Object?> context;

  @override
  String toString() {
    final buffer = StringBuffer()
      ..write('[${level.name.toUpperCase()}] ')
      ..write(timeUtc.toIso8601String())
      ..write(' ')
      ..write(message);
    if (name != null) {
      buffer
        ..write(' (')
        ..write(name)
        ..write(')');
    }
    if (context.isNotEmpty) {
      buffer
        ..write(' ')
        ..write(context);
    }
    if (error != null) {
      buffer
        ..write(' error=')
        ..write(error);
    }
    return buffer.toString();
  }
}

/// Destination for [LogRecord]s. Implementations never throw.
abstract interface class LogSink {
  void write(LogRecord record);
}

/// Writes records through `dart:developer` into the platform console.
final class ConsoleLogSink implements LogSink {
  const ConsoleLogSink();

  @override
  void write(LogRecord record) {
    developer.log(
      record.message,
      name: record.name ?? 'flow',
      level: record.level.developerLevel,
      time: record.timeUtc,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  }
}

/// In-memory, bounded buffer of records. Useful for tests and crash reports.
final class MemoryLogSink implements LogSink {
  MemoryLogSink({this.capacity = 500});

  /// Maximum number of records kept before the oldest is dropped.
  final int capacity;

  final List<LogRecord> _records = <LogRecord>[];

  /// Immutable snapshot of the buffered records (oldest first).
  List<LogRecord> get records => List<LogRecord>.unmodifiable(_records);

  /// Empties the buffer.
  void clear() => _records.clear();

  @override
  void write(LogRecord record) {
    _records.add(record);
    if (_records.length > capacity) {
      _records.removeAt(0);
    }
  }
}

/// Masks sensitive values (secrets, tokens, PII) before they reach a sink.
///
/// Contract: no hardcoded secrets and no PII may be logged, even accidentally.
abstract final class Redactor {
  const Redactor._();

  static const String mask = '[REDACTED]';
  static const int maxDepth = 6;

  static const Set<String> sensitiveKeys = <String>{
    'password',
    'passwd',
    'pass',
    'pin',
    'pinhash',
    'passwordhash',
    'secret',
    'token',
    'accesstoken',
    'refreshtoken',
    'apikey',
    'authorization',
    'key',
    'dek',
    'kek',
    'privatekey',
    'recoverykey',
    'salt',
    'cardnumber',
    'cvv',
  };

  /// `true` when [key] names a sensitive value (case/underscore-insensitive).
  static bool isSensitiveKey(String key) {
    final String normalized = key.toLowerCase().replaceAll('_', '');
    return sensitiveKeys.contains(normalized);
  }

  /// Recursively sanitises [value]. Maps and iterables are walked.
  static Object? sanitize(Object? value, {int depth = 0}) {
    if (depth >= maxDepth) {
      return '[...]';
    }
    if (value == null) {
      return null;
    }
    if (value is num || value is bool || value is DateTime) {
      return value;
    }
    if (value is String) {
      return value;
    }
    if (value is Map) {
      return sanitizeMap(value, depth: depth);
    }
    if (value is Iterable) {
      return value
          .map((Object? item) => sanitize(item, depth: depth + 1))
          .toList(growable: false);
    }
    return value.toString();
  }

  /// Sanitises a map, masking any sensitive-key entries.
  static Map<String, Object?> sanitizeMap(
    Map<Object?, Object?> map, {
    int depth = 0,
  }) {
    final Map<String, Object?> result = <String, Object?>{};
    map.forEach((Object? key, Object? value) {
      final String k = key.toString();
      result[k] = isSensitiveKey(k) ? mask : sanitize(value, depth: depth + 1);
    });
    return result;
  }
}

/// Application logger.
///
/// Use via `AppLogger.instance` or the Riverpod `appLoggerProvider`. Records
/// are filtered by the configured [level] and every payload passes through
/// [Redactor] before being delivered to the attached [LogSink]s.
final class AppLogger {
  AppLogger._({required this.level, required List<LogSink> sinks})
    : _sinks = List<LogSink>.unmodifiable(sinks);

  static AppLogger? _instance;

  /// Global instance; lazily created with sensible defaults.
  static AppLogger get instance => _instance ??= AppLogger._(
    level: LogLevel.info,
    sinks: const <LogSink>[ConsoleLogSink()],
  );

  /// Replaces the configuration (level and/or sinks).
  static void configure({LogLevel? level, List<LogSink>? sinks}) {
    final AppLogger current = instance;
    _instance = AppLogger._(
      level: level ?? current.level,
      sinks: sinks ?? current._sinks,
    );
  }

  /// Reverts to default configuration (used by tests).
  static void reset() {
    _instance = null;
  }

  /// Minimum severity that will be delivered to sinks.
  final LogLevel level;

  final List<LogSink> _sinks;

  /// Attached destinations.
  List<LogSink> get sinks => _sinks;

  /// `true` when records of [level] pass the current threshold.
  bool isEnabled(LogLevel level) =>
      level.developerLevel >= this.level.developerLevel;

  /// Emits a record at [level] if it passes the threshold.
  void log(
    LogLevel level,
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {
    if (!isEnabled(level)) {
      return;
    }
    final LogRecord record = LogRecord(
      level: level,
      message: message,
      timeUtc: DateTime.now().toUtc(),
      name: name,
      error: error == null ? null : Redactor.sanitize(error),
      stackTrace: stackTrace,
      context: context == null
          ? const <String, Object?>{}
          : Redactor.sanitizeMap(context),
    );
    for (final LogSink sink in _sinks) {
      sink.write(record);
    }
  }

  void trace(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) => log(
    LogLevel.trace,
    message,
    name: name,
    error: error,
    stackTrace: stackTrace,
    context: context,
  );

  void debug(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) => log(
    LogLevel.debug,
    message,
    name: name,
    error: error,
    stackTrace: stackTrace,
    context: context,
  );

  void info(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) => log(
    LogLevel.info,
    message,
    name: name,
    error: error,
    stackTrace: stackTrace,
    context: context,
  );

  void warning(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) => log(
    LogLevel.warning,
    message,
    name: name,
    error: error,
    stackTrace: stackTrace,
    context: context,
  );

  void error(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) => log(
    LogLevel.error,
    message,
    name: name,
    error: error,
    stackTrace: stackTrace,
    context: context,
  );

  void fatal(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) => log(
    LogLevel.fatal,
    message,
    name: name,
    error: error,
    stackTrace: stackTrace,
    context: context,
  );
}
