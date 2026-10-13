import 'dart:async';

import '../result/failure.dart';

/// Maps arbitrary thrown objects to a structured [Failure].
///
/// Kept here (and not inside [Result.guard]) so a single classification
/// strategy is shared by sync guards, async guards and the global handler.
abstract final class FailureMapper {
  const FailureMapper._();

  /// Converts [error] (and optional [stackTrace]) into a [Failure].
  ///
  /// Known exception shapes are classified; everything else becomes an
  /// [UnknownFailure] so the caller always gets a typed value.
  static Failure fromError(Object error, [StackTrace? stackTrace]) {
    if (error is Failure) {
      return error;
    }
    switch (error) {
      case FormatException():
        return ValidationFailure(
          message: error.message.isEmpty ? 'Invalid format' : error.message,
          cause: error,
          stackTrace: stackTrace,
        );
      case ArgumentError():
        return ValidationFailure(
          message: error.message?.toString(),
          cause: error,
          stackTrace: stackTrace,
        );
      case StateError():
        return UnexpectedFailure(
          message: error.message,
          cause: error,
          stackTrace: stackTrace,
        );
      case TypeError() || NoSuchMethodError():
        return UnexpectedFailure(
          message: 'Unexpected runtime error: ${error.runtimeType}',
          cause: error,
          stackTrace: stackTrace,
        );
      case TimeoutException():
        return TimeoutFailure(cause: error, stackTrace: stackTrace);
      default:
        return UnknownFailure(
          message: error.toString(),
          cause: error,
          stackTrace: stackTrace,
        );
    }
  }
}
