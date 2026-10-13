import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result<int>', () {
    test('ok state', () {
      const Result<int> result = Result.ok(42);
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect(result.valueOrNull, 42);
      expect(result.failureOrNull, isNull);
    });

    test('err state', () {
      const Failure failure = ValidationFailure(message: 'bad input');
      const Result<int> result = Result.err(failure);
      expect(result.isErr, isTrue);
      expect(result.isOk, isFalse);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, same(failure));
    });

    test('fold picks the right branch', () {
      const Result<String> ok = Result.ok('value');
      const Result<String> err = Result.err(UnknownFailure(message: 'boom'));

      expect(ok.fold(ok: (v) => 'ok:$v', err: (f) => 'err'), 'ok:value');
      expect(err.fold(ok: (v) => 'ok:$v', err: (f) => 'err'), 'err');
    });

    test('map transforms the value and keeps failure', () {
      const Result<int> ok = Result.ok(2);
      expect(ok.map((v) => v * 3), const Result.ok(6));

      const Result<int> err = Result.err(NotFoundFailure());
      final Result<String> mapped = err.map((v) => '$v');
      expect(mapped.isErr, isTrue);
      expect(mapped.failureOrNull, isA<NotFoundFailure>());
    });

    test('flatMap chains and short-circuits on failure', () {
      const Result<int> ok = Result.ok(2);
      final Result<int> chained = ok.flatMap((v) => Result.ok(v + 1));
      expect(chained, const Result.ok(3));

      const Result<int> err = Result.err(ConflictFailure());
      final Result<int> viaErr = err.flatMap((v) => Result.ok(v + 1));
      expect(viaErr.isErr, isTrue);
    });

    test('mapFailure transforms the failure only', () {
      const Result<int> err = Result.err(NotFoundFailure());
      final Result<int> mapped = err.mapFailure(
        (f) => ConflictFailure(message: f.message),
      );
      expect(mapped.failureOrNull, isA<ConflictFailure>());
      expect(mapped.valueOrNull, isNull);
    });

    test('value equality', () {
      expect(const Result.ok(1), const Result.ok(1));
      expect(const Result.ok(1), isNot(const Result.ok(2)));
      expect(
        const Result<int>.err(NotFoundFailure()),
        const Result<int>.err(NotFoundFailure()),
      );
    });
  });

  group('Result.guard', () {
    test('returns Ok for a successful body', () {
      final Result<int> result = Result.guard(() => 1 + 1);
      expect(result, const Result.ok(2));
    });

    test('returns UnknownFailure for a throwing body', () {
      final Result<int> result = Result.guard<int>(
        () => throw StateError('boom'),
      );
      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<UnknownFailure>());
    });

    test('uses onError mapper when provided', () {
      final Result<int> result = Result.guard<int>(
        () => throw const FormatException('nope'),
        onError: (error, stackTrace) =>
            const ValidationFailure(message: 'mapped'),
      );
      expect(result.failureOrNull, isA<ValidationFailure>());
    });
  });

  group('Result.guardAsync', () {
    test('returns Ok for a successful future', () async {
      final Result<int> result = await Result.guardAsync(() async => 2);
      expect(result, const Result.ok(2));
    });

    test('returns UnknownFailure for a throwing future', () async {
      final Result<int> result = await Result.guardAsync<int>(
        () async => throw Exception('async boom'),
      );
      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<UnknownFailure>());
    });
  });

  group('Failure hierarchy', () {
    test('ValidationFailure carries field errors', () {
      const Failure failure = ValidationFailure(
        message: 'fix the form',
        fieldErrors: <String, String>{'name': 'required'},
      );
      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).fieldErrors['name'], 'required');
    });

    test('PermissionFailure carries the permission id', () {
      const Failure failure = PermissionFailure(
        permission: 'permissions.manage_stock',
      );
      expect(
        (failure as PermissionFailure).permission,
        'permissions.manage_stock',
      );
    });

    test('toString is readable', () {
      expect(
        const NotFoundFailure(message: 'no row').toString(),
        contains('NotFoundFailure'),
      );
    });
  });
}
