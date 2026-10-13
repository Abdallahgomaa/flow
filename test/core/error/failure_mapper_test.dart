import 'dart:async';

import 'package:flow/core/error/failure_mapper.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('passes Failure instances through untouched', () {
    const Failure failure = NotFoundFailure(message: 'nope');
    expect(FailureMapper.fromError(failure), same(failure));
  });

  test('maps FormatException to ValidationFailure', () {
    final Failure failure = FailureMapper.fromError(
      const FormatException('bad format'),
    );
    expect(failure, isA<ValidationFailure>());
    expect(failure.message, 'bad format');
  });

  test('maps ArgumentError and RangeError to ValidationFailure', () {
    expect(
      FailureMapper.fromError(ArgumentError('arg')),
      isA<ValidationFailure>(),
    );
    expect(
      FailureMapper.fromError(RangeError.range(1, 0, 2)),
      isA<ValidationFailure>(),
    );
  });

  test('maps StateError to UnexpectedFailure', () {
    expect(
      FailureMapper.fromError(StateError('bad state')),
      isA<UnexpectedFailure>(),
    );
  });

  test('maps TimeoutException to TimeoutFailure', () {
    expect(
      FailureMapper.fromError(TimeoutException('slow')),
      isA<TimeoutFailure>(),
    );
  });

  test('defaults to UnknownFailure for anything else', () {
    expect(
      FailureMapper.fromError(Exception('generic')),
      isA<UnknownFailure>(),
    );
    expect(FailureMapper.fromError(42), isA<UnknownFailure>());
  });
}
