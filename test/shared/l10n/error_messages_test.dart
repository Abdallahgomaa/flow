import 'package:flow/core/result/failure.dart';
import 'package:flow/shared/l10n/error_messages.dart';
import 'package:flow/shared/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorMessages', () {
    late AppLocalizations en;
    late AppLocalizations ar;

    setUp(() async {
      en = await AppLocalizations.delegate.load(const Locale('en'));
      ar = await AppLocalizations.delegate.load(const Locale('ar'));
    });

    test(
      'maps every failure type to a non-empty message in both languages',
      () {
        final List<Failure> failures = <Failure>[
          const UnknownFailure(),
          const UnexpectedFailure(),
          const ValidationFailure(),
          const NotFoundFailure(),
          const ConflictFailure(),
          const StorageFailure(),
          const CryptoFailure(),
          const PermissionFailure(permission: 'permissions.manage_stock'),
          const TimeoutFailure(),
          const HardwareFailure(),
        ];

        for (final Failure failure in failures) {
          expect(
            ErrorMessages.of(en, failure),
            isNotEmpty,
            reason: 'en: $failure',
          );
          expect(
            ErrorMessages.of(ar, failure),
            isNotEmpty,
            reason: 'ar: $failure',
          );
        }
      },
    );

    test('uses language-specific text', () {
      expect(ErrorMessages.of(en, const NotFoundFailure()), en.errorNotFound);
      expect(ErrorMessages.of(ar, const NotFoundFailure()), ar.errorNotFound);
      expect(
        ErrorMessages.of(ar, const NotFoundFailure()),
        isNot(ErrorMessages.of(en, const NotFoundFailure())),
      );
      expect(ErrorMessages.title(ar), ar.errorTitle);
    });
  });
}
