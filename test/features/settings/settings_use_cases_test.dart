import 'package:flow/core/money/rate.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/features/settings/domain/app_preferences.dart';
import 'package:flow/features/settings/domain/business_profile.dart';
import 'package:flow/features/settings/domain/setting_keys.dart';
import 'package:flow/features/settings/domain/settings_repository.dart';
import 'package:flow/features/settings/domain/use_cases/load_app_preferences.dart';
import 'package:flow/features/settings/domain/use_cases/load_business_profile.dart';
import 'package:flow/features/settings/domain/use_cases/save_business_profile.dart';
import 'package:flow/features/settings/domain/use_cases/save_language_preference.dart';
import 'package:flow/features/settings/domain/use_cases/save_theme_preference.dart';
import 'package:flutter_test/flutter_test.dart';

/// One recorded `save` call.
typedef _SaveCall = ({
  String action,
  Map<String, String> values,
  Map<String, Object?> payload,
});

/// In-memory [SettingsRepository] double, so the use cases are exercised without
/// a database, Drift or Flutter.
final class _FakeSettingsRepository implements SettingsRepository {
  final Map<String, String> store = <String, String>{};
  final List<_SaveCall> saves = <_SaveCall>[];

  @override
  Future<Result<Map<String, String>>> readAll() async =>
      Result<Map<String, String>>.ok(<String, String>{...store});

  @override
  Future<Result<void>> save({
    required Map<String, String> values,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async {
    store.addAll(values);
    saves.add((
      action: action,
      values: <String, String>{...values},
      payload: payload,
    ));
    return const Result<void>.ok(null);
  }
}

/// The failure code of an errored [Result], or `null` when it succeeded.
String? _codeOf<T>(Result<T> result) => switch (result) {
  Ok<T>() => null,
  Err<T>(:final Failure failure) => failure.code,
};

void main() {
  group('LoadBusinessProfile', () {
    test('returns the defaults when nothing has been saved', () async {
      final Result<BusinessProfile> result = await LoadBusinessProfile(
        _FakeSettingsRepository(),
      )();

      final BusinessProfile profile = result.valueOrNull!;
      expect(profile.name, isEmpty);
      expect(profile.currencyCode, BusinessProfile.defaultCurrencyCode);
      expect(profile.taxRate, Rate.zero);
      expect(profile.isEmpty, isTrue);
    });

    test('reads every stored field back', () async {
      final _FakeSettingsRepository repository = _FakeSettingsRepository()
        ..store.addAll(<String, String>{
          SettingKeys.businessName: 'Flow Market',
          SettingKeys.businessPhone: '0100',
          SettingKeys.businessAddress: 'Cairo',
          SettingKeys.currency: 'EGP',
          SettingKeys.taxRate: '14',
          SettingKeys.receiptFooter: 'Thanks',
        });

      final BusinessProfile profile = (await LoadBusinessProfile(
        repository,
      )()).valueOrNull!;

      expect(profile.name, 'Flow Market');
      expect(profile.phone, '0100');
      expect(profile.address, 'Cairo');
      expect(profile.currencyCode, 'EGP');
      expect(profile.taxRate, const Rate.basisPoints(1400));
      expect(profile.receiptFooter, 'Thanks');
    });

    test('falls back to the defaults when a stored value is corrupt', () async {
      final _FakeSettingsRepository repository = _FakeSettingsRepository()
        ..store.addAll(<String, String>{
          SettingKeys.taxRate: 'not-a-number',
          SettingKeys.currency: '',
        });

      final BusinessProfile profile = (await LoadBusinessProfile(
        repository,
      )()).valueOrNull!;

      expect(profile.taxRate, Rate.zero);
      expect(profile.currencyCode, BusinessProfile.defaultCurrencyCode);
    });
  });

  group('SaveBusinessProfile', () {
    test('rejects a blank name without writing anything', () async {
      final _FakeSettingsRepository repository = _FakeSettingsRepository();

      final Result<BusinessProfile> result = await SaveBusinessProfile(
        repository,
      )(const BusinessProfile(name: '   '));

      expect(_codeOf(result), SaveBusinessProfile.nameRequiredCode);
      expect(repository.saves, isEmpty);
    });

    test('rejects a tax rate above 100 percent', () async {
      final _FakeSettingsRepository repository = _FakeSettingsRepository();

      final Result<BusinessProfile> result = await SaveBusinessProfile(
        repository,
      )(const BusinessProfile(name: 'Shop', taxRate: Rate.basisPoints(10001)));

      expect(_codeOf(result), SaveBusinessProfile.taxRateInvalidCode);
      expect(repository.saves, isEmpty);
    });

    test('rejects a negative tax rate', () async {
      final _FakeSettingsRepository repository = _FakeSettingsRepository();

      final Result<BusinessProfile> result = await SaveBusinessProfile(
        repository,
      )(const BusinessProfile(name: 'Shop', taxRate: Rate.basisPoints(-1)));

      expect(_codeOf(result), SaveBusinessProfile.taxRateInvalidCode);
      expect(repository.saves, isEmpty);
    });

    test('trims the text fields and records one audited save', () async {
      final _FakeSettingsRepository repository = _FakeSettingsRepository();

      final Result<BusinessProfile> result =
          await SaveBusinessProfile(repository)(
            const BusinessProfile(
              name: '  Flow Market  ',
              phone: ' 0100 ',
              address: ' Cairo ',
              currencyCode: 'EGP',
              taxRate: Rate.basisPoints(1400),
              receiptFooter: ' Thanks ',
            ),
          );

      final BusinessProfile saved = result.valueOrNull!;
      expect(saved.name, 'Flow Market');
      expect(saved.phone, '0100');
      expect(saved.address, 'Cairo');
      expect(saved.receiptFooter, 'Thanks');

      expect(repository.saves, hasLength(1));
      expect(repository.saves.single.action, SaveBusinessProfile.auditAction);
      expect(repository.saves.single.payload, <String, Object?>{
        'name': 'Flow Market',
        'currency': 'EGP',
        'taxBasisPoints': 1400,
      });
      // The stored percent string round-trips through `Rate.parsePercent`.
      expect(repository.store[SettingKeys.taxRate], '14');
    });

    test('round-trips through LoadBusinessProfile', () async {
      final _FakeSettingsRepository repository = _FakeSettingsRepository();
      const BusinessProfile profile = BusinessProfile(
        name: 'Flow Market',
        phone: '0100',
        address: 'Cairo',
        currencyCode: 'EGP',
        taxRate: Rate.basisPoints(525),
        receiptFooter: 'Thanks',
      );

      await SaveBusinessProfile(repository)(profile);
      final BusinessProfile reloaded = (await LoadBusinessProfile(
        repository,
      )()).valueOrNull!;

      expect(reloaded, profile);
    });
  });

  group('app preferences', () {
    test('theme and language round-trip through separate use cases', () async {
      final _FakeSettingsRepository repository = _FakeSettingsRepository();

      expect(
        (await LoadAppPreferences(repository)()).valueOrNull,
        AppPreferences.initial,
      );

      await SaveThemePreference(repository)(AppThemePreference.dark);
      await SaveLanguagePreference(repository)('en');

      final AppPreferences preferences = (await LoadAppPreferences(
        repository,
      )()).valueOrNull!;
      expect(preferences.theme, AppThemePreference.dark);
      expect(preferences.languageCode, 'en');
      expect(repository.store[SettingKeys.themeMode], 'dark');
      expect(repository.store[SettingKeys.locale], 'en');
    });

    test('a null language is stored empty and reads back as null', () async {
      final _FakeSettingsRepository repository = _FakeSettingsRepository();

      await SaveLanguagePreference(repository)(null);

      expect(repository.store[SettingKeys.locale], isEmpty);
      expect(
        (await LoadAppPreferences(repository)()).valueOrNull?.languageCode,
        isNull,
      );
    });

    test('an unknown stored theme falls back to system', () async {
      final _FakeSettingsRepository repository = _FakeSettingsRepository()
        ..store[SettingKeys.themeMode] = 'sepia';

      final AppPreferences preferences = (await LoadAppPreferences(
        repository,
      )()).valueOrNull!;

      expect(preferences.theme, AppThemePreference.system);
    });
  });
}
