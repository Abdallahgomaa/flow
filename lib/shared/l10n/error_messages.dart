import '../../core/result/failure.dart';
import 'generated/app_localizations.dart';

/// Maps domain [Failure]s to localised, user-safe messages.
///
/// `core/` deliberately stays language-agnostic: failures carry stable
/// machine-readable codes/types, and the UI layer decides how to phrase them.
/// This switch is exhaustive over the sealed [Failure] hierarchy, so adding a
/// new failure type becomes a compile-time prompt to add a translation.
abstract final class ErrorMessages {
  /// The localised headline shared by all error surfaces.
  static String title(AppLocalizations l10n) => l10n.errorTitle;

  /// The best localised description for [failure].
  static String of(AppLocalizations l10n, Failure failure) => switch (failure) {
    ValidationFailure() => l10n.errorValidation,
    NotFoundFailure() => l10n.errorNotFound,
    ConflictFailure() => l10n.errorConflict,
    StorageFailure() => l10n.errorStorage,
    CryptoFailure() => l10n.errorCrypto,
    PermissionFailure() => l10n.errorPermission,
    TimeoutFailure() => l10n.errorTimeout,
    HardwareFailure() => l10n.errorHardware,
    UnexpectedFailure() => l10n.errorUnexpected,
    UnknownFailure() => l10n.errorUnexpected,
  };
}
