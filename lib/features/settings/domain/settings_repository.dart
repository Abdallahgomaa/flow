import 'package:flow/core/result/result.dart';

/// Reads and writes the key/value rows of the `app_settings` table.
///
/// The interface is pure Dart: the Drift implementation lives in `data/`, so
/// use cases (and their tests) never depend on the storage engine. A single
/// [save] is one atomic, audited unit of work.
abstract interface class SettingsRepository {
  /// Every stored setting, keyed by its `SettingKeys` value.
  ///
  /// Keys that were never written are simply absent.
  Future<Result<Map<String, String>>> readAll();

  /// Persists [values] atomically and appends one audit entry describing the
  /// change.
  ///
  /// [action] is the stable audit action name (for example
  /// `settings.business_profile.saved`) and [payload] is a flat, JSON-safe
  /// summary of what changed. Either every row is written and the audit entry
  /// is appended, or nothing is.
  Future<Result<void>> save({
    required Map<String, String> values,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  });
}
