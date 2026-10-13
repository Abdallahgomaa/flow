/// Abstraction over "the current time" so the app never calls `DateTime.now()`
/// directly. Tests inject [FixedClock] for deterministic timestamps.
abstract interface class Clock {
  /// The current instant, always expressed in UTC.
  DateTime nowUtc();
}

/// Real wall-clock time, in UTC.
///
/// This is the single allowed `DateTime.now()` site in `lib/`; everything else
/// depends on the [Clock] abstraction.
final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

/// A clock whose time is controlled by tests.
///
/// [set] can move the clock backwards on purpose, which lets us prove that
/// identity generation never regresses when the system clock does.
final class FixedClock implements Clock {
  FixedClock(DateTime start) : _now = start.toUtc();

  DateTime _now;

  @override
  DateTime nowUtc() => _now;

  /// Moves the clock to [instant] (may be earlier than the current value).
  void set(DateTime instant) => _now = instant.toUtc();

  /// Moves the clock forward by [duration].
  void advance(Duration duration) => _now = _now.add(duration);
}
