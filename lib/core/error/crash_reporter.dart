/// Crash reporting boundary.
///
/// Flow ships with telemetry **disabled by default** (NFR-06: no data leaves
/// the device unless the user opts in). The [CrashReporter] interface exists so
/// an opt-in implementation (e.g. Sentry/Crashlytics) can be plugged in later
/// without touching the rest of the error pipeline.
abstract interface class CrashReporter {
  /// Reports an unhandled error. Implementations never throw.
  Future<void> report(
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?>? context,
    bool fatal = false,
  });
}

/// Default reporter that discards everything.
///
/// Safe-by-default: nothing is transmitted, no PII leaves the device.
final class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  Future<void> report(
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?>? context,
    bool fatal = false,
  }) async {
    // Intentionally empty.
  }
}
