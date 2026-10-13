// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flow';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get buttonSecondary => 'Secondary';

  @override
  String get buttonOutline => 'Outline';

  @override
  String get buttonGhost => 'Ghost';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeToggleTooltip => 'Switch theme';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get navigationPos => 'Point of Sale';

  @override
  String get navigationProducts => 'Products';

  @override
  String get navigationInventory => 'Inventory';

  @override
  String get navigationReports => 'Reports';

  @override
  String get navigationSettings => 'Settings';

  @override
  String get designSystemTitle => 'Design System';

  @override
  String get customCardTitle => 'CustomCard';

  @override
  String get customCardSubtitle => 'Elevated variant with header and content';

  @override
  String get outlinedCardTitle => 'Outlined card';

  @override
  String get outlinedCardSubtitle => 'Good for grouped settings';

  @override
  String get productSearchLabel => 'Product search';

  @override
  String get productSearchHint => 'Name or barcode';

  @override
  String searchResultsCount(int count) {
    return 'Matches: $count';
  }

  @override
  String get searchNoResults => 'No products found';

  @override
  String get demoProductMilk => 'Fresh milk 1L';

  @override
  String get demoProductBread => 'Baladi bread';

  @override
  String get demoProductRice => 'Egyptian rice 1kg';

  @override
  String get demoProductTea => 'Tea bags (100)';

  @override
  String get demoProductOil => 'Sunflower oil 1L';

  @override
  String get demoProductSugar => 'Sugar 1kg';

  @override
  String get demoProductWater => 'Mineral water 1.5L';

  @override
  String get demoProductSoap => 'Hand soap 500ml';

  @override
  String get devScreenTitle => 'Developer tools';

  @override
  String get devScreenSubtitle => 'Money and tax playground';

  @override
  String get devAmountLabel => 'Amount';

  @override
  String get devTaxRateLabel => 'Tax rate (%)';

  @override
  String get devQuantityLabel => 'Quantity';

  @override
  String get devNetLabel => 'Net';

  @override
  String get devTaxLabel => 'Tax';

  @override
  String get devGrossLabel => 'Gross';

  @override
  String get devInvalidAmount => 'Enter a valid amount';

  @override
  String get devCurrencyLabel => 'Currency';

  @override
  String get devTaxModeLabel => 'Tax mode';

  @override
  String get devTaxExclusive => 'Exclusive';

  @override
  String get devTaxInclusive => 'Inclusive';

  @override
  String get devLineTotalLabel => 'Line total';

  @override
  String get placeholderComingSoon => 'Coming soon';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorUnexpected =>
      'An unexpected error occurred. Please try again.';

  @override
  String get errorValidation => 'Please check the values you entered.';

  @override
  String get errorNotFound => 'The requested item was not found.';

  @override
  String get errorConflict => 'This action conflicts with existing data.';

  @override
  String get errorPermission => 'You do not have permission to do this.';

  @override
  String get errorStorage => 'The local database could not be read or written.';

  @override
  String get errorCrypto => 'A secure operation failed.';

  @override
  String get errorTimeout => 'The operation took too long. Please try again.';

  @override
  String get errorHardware => 'A required device feature is unavailable.';

  @override
  String get settingsBusinessSectionTitle => 'Business profile';

  @override
  String get settingsBusinessSectionSubtitle =>
      'Printed on receipts and reports';

  @override
  String get settingsNameLabel => 'Business name';

  @override
  String get settingsPhoneLabel => 'Phone';

  @override
  String get settingsAddressLabel => 'Address';

  @override
  String get settingsTaxRateLabel => 'Tax rate';

  @override
  String get settingsCurrencyLabel => 'Currency';

  @override
  String get settingsReceiptFooterLabel => 'Receipt footer';

  @override
  String get settingsAppearanceSectionTitle => 'Appearance and language';

  @override
  String get settingsAppearanceSectionSubtitle => 'Saved on this device';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsDiscard => 'Discard';

  @override
  String get settingsSaved => 'Saved';

  @override
  String get settingsSaveFailed => 'Could not save. Please try again.';

  @override
  String get settingsLoadFailed => 'Could not load the saved settings.';

  @override
  String get settingsNameRequired => 'Enter a business name.';

  @override
  String get settingsTaxRateInvalid => 'Enter a tax rate between 0 and 100.';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Enter your account details to continue.';

  @override
  String get loginUsernameLabel => 'Login name';

  @override
  String get loginSecretLabel => 'Password or PIN';

  @override
  String get loginSecretHelper => 'Use your password or your PIN.';

  @override
  String get loginSecretToggleTooltip => 'Show or hide';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginUsernameRequired => 'Enter your login name.';

  @override
  String get loginSecretRequired => 'Enter your password or PIN.';

  @override
  String get loginInvalidCredentials => 'Unknown login name or wrong password.';

  @override
  String get loginAccountDisabled =>
      'This account is disabled. Contact an administrator.';

  @override
  String get loginFailed => 'Could not sign in. Please try again.';
}
