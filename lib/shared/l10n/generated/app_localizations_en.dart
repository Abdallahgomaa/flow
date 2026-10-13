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
}
