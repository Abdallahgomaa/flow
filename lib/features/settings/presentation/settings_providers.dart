import 'package:flow/core/result/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/settings_providers.dart';
import '../domain/business_profile.dart';

part 'settings_providers.g.dart';

/// The saved business profile, read straight from the database.
///
/// The provider exposes the raw `Result` instead of throwing, so the screen can
/// render a precise message for a storage failure. It is not kept alive: leaving
/// the settings destination disposes it and re-entering reloads from the
/// database, which is what makes the wiring verifiably "live".
@riverpod
Future<Result<BusinessProfile>> savedBusinessProfile(Ref ref) =>
    ref.watch(loadBusinessProfileProvider)();
