import 'package:flow/core/money/rate.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';

import '../business_profile.dart';
import '../settings_repository.dart';

/// Validates and persists the business profile.
///
/// This is the only way the profile is ever written (AGENTS rule 3): the screen
/// calls the use case, the use case calls the repository, and the repository
/// wraps the rows plus the audit entry in one unit of work.
final class SaveBusinessProfile {
  /// Creates the use case.
  const SaveBusinessProfile(this._repository);

  final SettingsRepository _repository;

  /// Audit action recorded for every saved profile.
  static const String auditAction = 'settings.business_profile.saved';

  /// Failure code used when the business name is missing.
  static const String nameRequiredCode = 'settings.nameRequired';

  /// Failure code used when the tax rate is outside 0–100%.
  static const String taxRateInvalidCode = 'settings.taxRateInvalid';

  /// Validates [profile] and saves it.
  ///
  /// Returns the normalised (trimmed) profile on success, or a
  /// [ValidationFailure] naming the first problem via [code].
  Future<Result<BusinessProfile>> call(BusinessProfile profile) async {
    final String name = profile.name.trim();
    if (name.isEmpty) {
      return const Result<BusinessProfile>.err(
        ValidationFailure(
          message: 'Enter a business name.',
          code: nameRequiredCode,
        ),
      );
    }
    if (profile.taxRate.isNegative || profile.taxRate > Rate.full) {
      return const Result<BusinessProfile>.err(
        ValidationFailure(
          message: 'Enter a tax rate between 0 and 100.',
          code: taxRateInvalidCode,
        ),
      );
    }

    final BusinessProfile normalised = profile.copyWith(
      name: name,
      phone: profile.phone.trim(),
      address: profile.address.trim(),
      receiptFooter: profile.receiptFooter.trim(),
    );

    final Result<void> saved = await _repository.save(
      values: normalised.toSettings(),
      action: auditAction,
      payload: normalised.toAuditPayload(),
    );
    return saved.map((_) => normalised);
  }
}
