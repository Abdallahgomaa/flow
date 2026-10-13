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
