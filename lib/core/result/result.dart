import 'failure.dart';

/// A value that is either a success [Ok] or a failure [Err].
///
/// Use [Result] as the return type of every use case and repository call:
///
/// ```dart
/// final Result<Customer> result = await repo.findById(id);
/// final name = result.fold(
///   ok: (c) => c.name,
///   err: (f) => '',
/// );
/// ```
///
/// The type is deliberately sealed, so exhaustive matching is enforced by the
/// compiler. File is pure Dart on purpose.
sealed class Result<T> {
  const Result();

  /// Creates a success result.
  const factory Result.ok(T value) = Ok<T>;

  /// Creates a failure result.
  const factory Result.err(Failure failure) = Err<T>;

  /// `true` when this result is an [Ok].
  bool get isOk => this is Ok<T>;

  /// `true` when this result is an [Err].
  bool get isErr => this is Err<T>;

  /// The success value, or `null` when this is an [Err].
  T? get valueOrNull => switch (this) {
    Ok<T>(:final T value) => value,
    Err<T>() => null,
  };

  /// The failure, or `null` when this is an [Ok].
  Failure? get failureOrNull => switch (this) {
    Ok<T>() => null,
    Err<T>(:final Failure failure) => failure,
  };

  /// Destructures the result into [ok] or [err] handlers.
  R fold<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) err,
  }) => switch (this) {
    Ok<T>(:final T value) => ok(value),
    Err<T>(:final Failure failure) => err(failure),
  };

  /// Maps the success value, preserving the failure unchanged.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok<T>(:final T value) => Ok<R>(transform(value)),
    Err<T>(:final Failure failure) => Err<R>(failure),
  };

  /// Chains to another [Result]-returning operation.
  Result<R> flatMap<R>(Result<R> Function(T value) transform) => switch (this) {
    Ok<T>(:final T value) => transform(value),
    Err<T>(:final Failure failure) => Err<R>(failure),
  };

  /// Transforms the failure, keeping the success value unchanged.
  Result<T> mapFailure(Failure Function(Failure failure) transform) =>
      switch (this) {
        Ok<T>(:final T value) => Ok<T>(value),
        Err<T>(:final Failure failure) => Err<T>(transform(failure)),
      };

  /// Runs [body] synchronously and converts exceptions to a [Failure].
  static Result<T> guard<T>(
    T Function() body, {
    Failure Function(Object error, StackTrace stackTrace)? onError,
  }) {
    try {
      return Result<T>.ok(body());
    } on Object catch (error, stackTrace) {
      return Result<T>.err(
        onError?.call(error, stackTrace) ??
            UnknownFailure(cause: error, stackTrace: stackTrace),
      );
    }
  }

  /// Runs [body] asynchronously and converts exceptions to a [Failure].
  static Future<Result<T>> guardAsync<T>(
    Future<T> Function() body, {
    Failure Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      return Result<T>.ok(await body());
    } on Object catch (error, stackTrace) {
      return Result<T>.err(
        onError?.call(error, stackTrace) ??
            UnknownFailure(cause: error, stackTrace: stackTrace),
      );
    }
  }
}

/// The success variant of [Result].
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  bool operator ==(Object other) => other is Ok<T> && other.value == value;

  @override
  int get hashCode => Object.hash(Ok, value);

  @override
  String toString() => 'Ok($value)';
}

/// The failure variant of [Result].
final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;

  @override
  bool operator ==(Object other) => other is Err<T> && other.failure == failure;

  @override
  int get hashCode => Object.hash(Err, failure);

  @override
  String toString() => 'Err($failure)';
}
