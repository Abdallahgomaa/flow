import 'package:flow/core/money/currency.dart';
import 'package:flow/core/money/rate.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/features/settings/data/settings_providers.dart';
import 'package:flow/features/settings/domain/app_preferences.dart';
import 'package:flow/features/settings/domain/business_profile.dart';
import 'package:flow/features/settings/domain/use_cases/save_business_profile.dart';
import 'package:flow/shared/design/app_dimens.dart';
import 'package:flow/shared/l10n/l10n.dart';
import 'package:flow/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_providers.dart';
import 'theme_mode_mapping.dart';

/// Settings destination: the business profile plus the appearance choices.
///
/// The profile is read from — and written to — the local database through the
/// settings use cases, so everything survives closing the app. The theme and
/// language are delegated upward through [onThemeModeChanged] /
/// [onLanguageChanged]: those live at application level, and the presentation
/// layer must not reach into `lib/app/`.
class SettingsScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const SettingsScreen({
    required this.themeMode,
    required this.languageCode,
    required this.onThemeModeChanged,
    required this.onLanguageChanged,
    super.key,
  });

  /// Theme mode currently applied by the application.
  final ThemeMode themeMode;

  /// Pinned language code, or `null` to follow the device language.
  final String? languageCode;

  /// Called when the user picks a theme mode.
  final ValueChanged<ThemeMode> onThemeModeChanged;

  /// Called when the user picks a language (`null` = device language).
  final ValueChanged<String?> onLanguageChanged;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _name = '';
  String _phone = '';
  String _address = '';
  String _receiptFooter = '';
  String _taxRate = '';
  String _currency = BusinessProfile.defaultCurrencyCode;
  String? _taxError;
  bool _saving = false;
  bool _seeded = false;

  /// Copies the stored profile into the form mirrors the first time it arrives.
  ///
  /// The text fields seed themselves from these values, so they must be set
  /// before the fields are built. Plain strings have no listeners, so doing it
  /// during build is safe (unlike mutating a `TextEditingController`).
  void _seed(BusinessProfile profile) {
    if (_seeded) {
      return;
    }
    _seeded = true;
    _name = profile.name;
    _phone = profile.phone;
    _address = profile.address;
    _receiptFooter = profile.receiptFooter;
    _currency = profile.currencyCode;
    _taxRate = profile.taxRate.toPercentString().replaceAll('%', '');
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return ref
        .watch(savedBusinessProfileProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) =>
              _MessageCard(message: l10n.settingsLoadFailed, onRetry: _reload),
          data: (Result<BusinessProfile> result) => result.fold(
            ok: (BusinessProfile profile) {
              _seed(profile);
              return _buildForm(l10n);
            },
            err: (_) => _MessageCard(
              message: l10n.settingsLoadFailed,
              onRetry: _reload,
            ),
          ),
        );
  }

  /// Re-reads the stored profile from the database.
  void _reload() {
    _seeded = false;
    ref.invalidate(savedBusinessProfileProvider);
  }

  /// Discards the edits by reloading the persisted values.
  void _discard() {
    setState(() => _taxError = null);
    _reload();
  }

  /// Validates the form and persists the profile.
  Future<void> _save() async {
    final String rawRate = _taxRate.trim();
    final Rate? rate = Rate.parsePercent(rawRate.isEmpty ? '0' : rawRate)
        .valueOrNull;
    if (rate == null) {
      setState(() => _taxError = context.l10n.settingsTaxRateInvalid);
      return;
    }

    setState(() {
      _saving = true;
      _taxError = null;
    });

    final Result<BusinessProfile> result =
        await ref.read(saveBusinessProfileProvider)(
          BusinessProfile(
            name: _name,
            phone: _phone,
            address: _address,
            currencyCode: _currency,
            taxRate: rate,
            receiptFooter: _receiptFooter,
          ),
        );

    if (!mounted) {
      return;
    }
    setState(() => _saving = false);

    final AppLocalizations l10n = context.l10n;
    final String message = switch (result) {
      Ok<BusinessProfile>() => l10n.settingsSaved,
      Err<BusinessProfile>(:final Failure failure) => _messageFor(
        failure,
        l10n,
      ),
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Turns a use-case [Failure] into a user-readable message.
  String _messageFor(Failure failure, AppLocalizations l10n) =>
      switch (failure.code) {
        SaveBusinessProfile.nameRequiredCode => l10n.settingsNameRequired,
        SaveBusinessProfile.taxRateInvalidCode => l10n.settingsTaxRateInvalid,
        _ => l10n.settingsSaveFailed,
      };

  Widget _buildForm(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        CustomCard(
          title: l10n.settingsBusinessSectionTitle,
          subtitle: l10n.settingsBusinessSectionSubtitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CustomTextField(
                label: l10n.settingsNameLabel,
                initialValue: _name,
                textInputAction: TextInputAction.next,
                enabled: !_saving,
                onChanged: (String value) => _name = value,
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                label: l10n.settingsPhoneLabel,
                initialValue: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                enabled: !_saving,
                onChanged: (String value) => _phone = value,
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                label: l10n.settingsAddressLabel,
                initialValue: _address,
                maxLines: 2,
                textInputAction: TextInputAction.next,
                enabled: !_saving,
                onChanged: (String value) => _address = value,
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                label: l10n.settingsTaxRateLabel,
                initialValue: _taxRate,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                suffixText: '%',
                errorText: _taxError,
                enabled: !_saving,
                onChanged: (String value) {
                  _taxRate = value;
                  if (_taxError != null) {
                    setState(() => _taxError = null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.settingsCurrencyLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  for (final Currency option in Currency.predefined)
                    CustomButton(
                      label: option.code,
                      size: CustomButtonSize.small,
                      variant: _currency == option.code
                          ? CustomButtonVariant.primary
                          : CustomButtonVariant.outline,
                      onPressed: _saving
                          ? null
                          : () => setState(() => _currency = option.code),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                label: l10n.settingsReceiptFooterLabel,
                initialValue: _receiptFooter,
                maxLines: 2,
                enabled: !_saving,
                onChanged: (String value) => _receiptFooter = value,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomButton(
                      label: l10n.actionSave,
                      icon: Icons.save_outlined,
                      isLoading: _saving,
                      onPressed: _save,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  CustomButton(
                    label: l10n.settingsDiscard,
                    variant: CustomButtonVariant.outline,
                    onPressed: _saving ? null : _discard,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        CustomCard(
          title: l10n.settingsAppearanceSectionTitle,
          subtitle: l10n.settingsAppearanceSectionSubtitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.settingsThemeLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  for (final AppThemePreference preference
                      in AppThemePreference.values)
                    CustomButton(
                      label: _themeLabel(preference, l10n),
                      size: CustomButtonSize.small,
                      variant: widget.themeMode.preference == preference
                          ? CustomButtonVariant.primary
                          : CustomButtonVariant.outline,
                      onPressed: () =>
                          widget.onThemeModeChanged(preference.themeMode),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.languageLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  for (final String? code in _languageChoices)
                    CustomButton(
                      label: _languageLabel(code, l10n),
                      size: CustomButtonSize.small,
                      variant: widget.languageCode == code
                          ? CustomButtonVariant.primary
                          : CustomButtonVariant.outline,
                      onPressed: () => widget.onLanguageChanged(code),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// `null` first so "follow the device language" is the default choice.
  static const List<String?> _languageChoices = <String?>[null, 'ar', 'en'];

  String _themeLabel(AppThemePreference preference, AppLocalizations l10n) =>
      switch (preference) {
        AppThemePreference.system => l10n.themeModeSystem,
        AppThemePreference.light => l10n.themeModeLight,
        AppThemePreference.dark => l10n.themeModeDark,
      };

  String _languageLabel(String? code, AppLocalizations l10n) => switch (code) {
    null => l10n.settingsLanguageSystem,
    'ar' => l10n.languageArabic,
    _ => l10n.languageEnglish,
  };
}

/// Card shown when the profile could not be read, with a retry action.
class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: CustomCard(
          variant: CustomCardVariant.outlined,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.lg),
              CustomButton(
                label: context.l10n.actionRetry,
                icon: Icons.refresh,
                variant: CustomButtonVariant.outline,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
