/// Domain-level failure hierarchy.
///
/// Every business/technical error surfaced by the app is an instance of
/// [Failure] (or a subtype). [Result] carries these failures instead of
/// throwing, so error paths are explicit and testable.
///
/// The file is pure Dart (no Flutter imports) to keep `domain` layers safe.
library;

/// Base class for all handled failures.
///
/// [message] is safe for end users and [code] is a stable machine-readable
/// identifier (e.g. `kInvalidPin`). [cause]/[stackTrace] may be attached for
/// diagnostics but must never be logged verbatim into analytics.
sealed class Failure {
  const Failure({this.message, this.code, this.cause, this.stackTrace});

  /// User-safe description.
  final String? message;

  /// Stable machine identifier for the failure category.
  final String? code;

  /// The original error/exception that triggered this failure, if any.
  final Object? cause;

  /// The stack trace captured at failure time, if any.
  final StackTrace? stackTrace;

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType(');
    final List<String> parts = <String>[
      if (message != null) 'message: $message',
      if (code != null) 'code: $code',
    ];
    buffer.write(parts.join(', '));
    buffer.write(')');
    return buffer.toString();
  }
}

/// An error with no known category. Default catch-all.
final class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message,
    super.code,
    super.cause,
    super.stackTrace,
  });
}

/// A programming or invariant error (e.g. unexpected `null` where forbidden).
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message,
    super.code,
    super.cause,
    super.stackTrace,
  });
}

/// Input data is invalid. [fieldErrors] maps field names to messages.
final class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message,
    super.code,
    super.cause,
    super.stackTrace,
    this.fieldErrors = const <String, String>{},
  });

  final Map<String, String> fieldErrors;
}

/// A requested resource could not be found.
final class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message,
    super.code,
    super.cause,
    super.stackTrace,
  });
}

/// The operation collides with the current state (e.g. duplicate record,
/// optimistic-lock mismatch).
final class ConflictFailure extends Failure {
  const ConflictFailure({
    super.message,
    super.code,
    super.cause,
    super.stackTrace,
  });
}

/// A storage/database operation failed.
final class StorageFailure extends Failure {
  const StorageFailure({
    super.message,
    super.code,
    super.cause,
    super.stackTrace,
  });
}

/// An encryption/decryption/keystore operation failed.
final class CryptoFailure extends Failure {
  const CryptoFailure({
    super.message,
    super.code,
    super.cause,
    super.stackTrace,
  });
}

/// The current user/permission is not allowed to perform the operation.
final class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message,
    super.code,
    super.cause,
    super.stackTrace,
    required this.permission,
  });

  /// Identifier of the missing permission (e.g. `permissions.manage_stock`).
  final String permission;
}

/// The operation timed out.
final class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message,
    super.code,
    super.cause,
    super.stackTrace,
  });
}

/// A hardware/peripheral operation failed (printer, scanner, scale...).
final class HardwareFailure extends Failure {
  const HardwareFailure({
    super.message,
    super.code,
    super.cause,
    super.stackTrace,
  });
}
