import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get appTitle;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @buttonSecondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get buttonSecondary;

  /// No description provided for @buttonOutline.
  ///
  /// In en, this message translates to:
  /// **'Outline'**
  String get buttonOutline;

  /// No description provided for @buttonGhost.
  ///
  /// In en, this message translates to:
  /// **'Ghost'**
  String get buttonGhost;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @themeToggleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch theme'**
  String get themeToggleTooltip;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @navigationPos.
  ///
  /// In en, this message translates to:
  /// **'Point of Sale'**
  String get navigationPos;

  /// No description provided for @navigationProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navigationProducts;

  /// No description provided for @navigationInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get navigationInventory;

  /// No description provided for @navigationReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navigationReports;

  /// No description provided for @navigationSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navigationSettings;

  /// No description provided for @designSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'Design System'**
  String get designSystemTitle;

  /// No description provided for @customCardTitle.
  ///
  /// In en, this message translates to:
  /// **'CustomCard'**
  String get customCardTitle;

  /// No description provided for @customCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Elevated variant with header and content'**
  String get customCardSubtitle;

  /// No description provided for @outlinedCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Outlined card'**
  String get outlinedCardTitle;

  /// No description provided for @outlinedCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Good for grouped settings'**
  String get outlinedCardSubtitle;

  /// No description provided for @productSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Product search'**
  String get productSearchLabel;

  /// No description provided for @productSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Name or barcode'**
  String get productSearchHint;

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'Matches: {count}'**
  String searchResultsCount(int count);

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get searchNoResults;

  /// No description provided for @demoProductMilk.
  ///
  /// In en, this message translates to:
  /// **'Fresh milk 1L'**
  String get demoProductMilk;

  /// No description provided for @demoProductBread.
  ///
  /// In en, this message translates to:
  /// **'Baladi bread'**
  String get demoProductBread;

  /// No description provided for @demoProductRice.
  ///
  /// In en, this message translates to:
  /// **'Egyptian rice 1kg'**
  String get demoProductRice;

  /// No description provided for @demoProductTea.
  ///
  /// In en, this message translates to:
  /// **'Tea bags (100)'**
  String get demoProductTea;

  /// No description provided for @demoProductOil.
  ///
  /// In en, this message translates to:
  /// **'Sunflower oil 1L'**
  String get demoProductOil;

  /// No description provided for @demoProductSugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar 1kg'**
  String get demoProductSugar;

  /// No description provided for @demoProductWater.
  ///
  /// In en, this message translates to:
  /// **'Mineral water 1.5L'**
  String get demoProductWater;

  /// No description provided for @demoProductSoap.
  ///
  /// In en, this message translates to:
  /// **'Hand soap 500ml'**
  String get demoProductSoap;

  /// No description provided for @devScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Developer tools'**
  String get devScreenTitle;

  /// No description provided for @devScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Money and tax playground'**
  String get devScreenSubtitle;

  /// No description provided for @devAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get devAmountLabel;

  /// No description provided for @devTaxRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax rate (%)'**
  String get devTaxRateLabel;

  /// No description provided for @devQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get devQuantityLabel;

  /// No description provided for @devNetLabel.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get devNetLabel;

  /// No description provided for @devTaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get devTaxLabel;

  /// No description provided for @devGrossLabel.
  ///
  /// In en, this message translates to:
  /// **'Gross'**
  String get devGrossLabel;

  /// No description provided for @devInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get devInvalidAmount;

  /// No description provided for @devCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get devCurrencyLabel;

  /// No description provided for @devTaxModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax mode'**
  String get devTaxModeLabel;

  /// No description provided for @devTaxExclusive.
  ///
  /// In en, this message translates to:
  /// **'Exclusive'**
  String get devTaxExclusive;

  /// No description provided for @devTaxInclusive.
  ///
  /// In en, this message translates to:
  /// **'Inclusive'**
  String get devTaxInclusive;

  /// No description provided for @devLineTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Line total'**
  String get devLineTotalLabel;

  /// No description provided for @placeholderComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get placeholderComingSoon;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errorUnexpected;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Please check the values you entered.'**
  String get errorValidation;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested item was not found.'**
  String get errorNotFound;

  /// No description provided for @errorConflict.
  ///
  /// In en, this message translates to:
  /// **'This action conflicts with existing data.'**
  String get errorConflict;

  /// No description provided for @errorPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do this.'**
  String get errorPermission;

  /// No description provided for @errorStorage.
  ///
  /// In en, this message translates to:
  /// **'The local database could not be read or written.'**
  String get errorStorage;

  /// No description provided for @errorCrypto.
  ///
  /// In en, this message translates to:
  /// **'A secure operation failed.'**
  String get errorCrypto;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The operation took too long. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorHardware.
  ///
  /// In en, this message translates to:
  /// **'A required device feature is unavailable.'**
  String get errorHardware;

  /// No description provided for @settingsBusinessSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Business profile'**
  String get settingsBusinessSectionTitle;

  /// No description provided for @settingsBusinessSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Printed on receipts and reports'**
  String get settingsBusinessSectionSubtitle;

  /// No description provided for @settingsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get settingsNameLabel;

  /// No description provided for @settingsPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get settingsPhoneLabel;

  /// No description provided for @settingsAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get settingsAddressLabel;

  /// No description provided for @settingsTaxRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax rate'**
  String get settingsTaxRateLabel;

  /// No description provided for @settingsCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrencyLabel;

  /// No description provided for @settingsReceiptFooterLabel.
  ///
  /// In en, this message translates to:
  /// **'Receipt footer'**
  String get settingsReceiptFooterLabel;

  /// No description provided for @settingsAppearanceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance and language'**
  String get settingsAppearanceSectionTitle;

  /// No description provided for @settingsAppearanceSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device'**
  String get settingsAppearanceSectionSubtitle;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeLabel;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get settingsDiscard;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get settingsSaved;

  /// No description provided for @settingsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Please try again.'**
  String get settingsSaveFailed;

  /// No description provided for @settingsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the saved settings.'**
  String get settingsLoadFailed;

  /// No description provided for @settingsNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a business name.'**
  String get settingsNameRequired;

  /// No description provided for @settingsTaxRateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a tax rate between 0 and 100.'**
  String get settingsTaxRateInvalid;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your account details to continue.'**
  String get loginSubtitle;

  /// No description provided for @loginUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Login name'**
  String get loginUsernameLabel;

  /// No description provided for @loginSecretLabel.
  ///
  /// In en, this message translates to:
  /// **'Password or PIN'**
  String get loginSecretLabel;

  /// No description provided for @loginSecretHelper.
  ///
  /// In en, this message translates to:
  /// **'Use your password or your PIN.'**
  String get loginSecretHelper;

  /// No description provided for @loginSecretToggleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show or hide'**
  String get loginSecretToggleTooltip;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSubmit;

  /// No description provided for @loginUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your login name.'**
  String get loginUsernameRequired;

  /// No description provided for @loginSecretRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password or PIN.'**
  String get loginSecretRequired;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Unknown login name or wrong password.'**
  String get loginInvalidCredentials;

  /// No description provided for @loginAccountDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account is disabled. Contact an administrator.'**
  String get loginAccountDisabled;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Please try again.'**
  String get loginFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
