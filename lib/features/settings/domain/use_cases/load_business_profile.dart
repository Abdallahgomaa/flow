import 'package:flow/core/result/result.dart';

import '../business_profile.dart';
import '../settings_repository.dart';

/// Reads the saved business profile (or the defaults on a fresh install).
final class LoadBusinessProfile {
  /// Creates the use case.
  const LoadBusinessProfile(this._repository);

  final SettingsRepository _repository;

  /// Executes the use case.
  Future<Result<BusinessProfile>> call() async {
    final Result<Map<String, String>> result = await _repository.readAll();
    return result.map(BusinessProfile.fromSettings);
  }
}
