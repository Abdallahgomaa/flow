// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'فلو';

  @override
  String get actionSearch => 'بحث';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get buttonSecondary => 'ثانوي';

  @override
  String get buttonOutline => 'مُحدَّد';

  @override
  String get buttonGhost => 'شفّاف';

  @override
  String get themeModeSystem => 'النظام';

  @override
  String get themeModeLight => 'فاتح';

  @override
  String get themeModeDark => 'داكن';

  @override
  String get themeToggleTooltip => 'تبديل المظهر';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get navigationPos => 'نقطة البيع';

  @override
  String get navigationProducts => 'المنتجات';

  @override
  String get navigationInventory => 'المخزون';

  @override
  String get navigationReports => 'التقارير';

  @override
  String get navigationSettings => 'الإعدادات';

  @override
  String get designSystemTitle => 'نظام التصميم';

  @override
  String get customCardTitle => 'بطاقة مخصّصة';

  @override
  String get customCardSubtitle => 'النمط المرتفع مع عنوانٍ ومحتوى';

  @override
  String get outlinedCardTitle => 'بطاقة مُحدَّدة';

  @override
  String get outlinedCardSubtitle => 'مناسبة للإعدادات المجمَّعة';

  @override
  String get productSearchLabel => 'بحث المنتجات';

  @override
  String get productSearchHint => 'الاسم أو الباركود';

  @override
  String searchResultsCount(int count) {
    return 'النتائج: $count';
  }

  @override
  String get searchNoResults => 'لا توجد نتائج';

  @override
  String get demoProductMilk => 'حليب طازج 1 لتر';

  @override
  String get demoProductBread => 'خبز بلدي';

  @override
  String get demoProductRice => 'أرز مصري 1 كجم';

  @override
  String get demoProductTea => 'أكياس شاي (100)';

  @override
  String get demoProductOil => 'زيت عباد الشمس 1 لتر';

  @override
  String get demoProductSugar => 'سكر 1 كجم';

  @override
  String get demoProductWater => 'مياه معدنية 1.5 لتر';

  @override
  String get demoProductSoap => 'صابون يدان 500 مل';

  @override
  String get devScreenTitle => 'أدوات المطوّر';

  @override
  String get devScreenSubtitle => 'ملعب الحسابات المالية والضريبة';

  @override
  String get devAmountLabel => 'المبلغ';

  @override
  String get devTaxRateLabel => 'نسبة الضريبة (%)';

  @override
  String get devQuantityLabel => 'الكمية';

  @override
  String get devNetLabel => 'الصافي';

  @override
  String get devTaxLabel => 'الضريبة';

  @override
  String get devGrossLabel => 'الإجمالي';

  @override
  String get devInvalidAmount => 'أدخل مبلغًا صالحًا';

  @override
  String get devCurrencyLabel => 'العملة';

  @override
  String get devTaxModeLabel => 'طريقة الضريبة';

  @override
  String get devTaxExclusive => 'غير شامل';

  @override
  String get devTaxInclusive => 'شامل';

  @override
  String get devLineTotalLabel => 'إجمالي البند';

  @override
  String get placeholderComingSoon => 'قريبًا';

  @override
  String get errorTitle => 'حدث خطأ ما';

  @override
  String get errorUnexpected => 'حدث خطأ غير متوقّع. حاول مرة أخرى.';

  @override
  String get errorValidation => 'يرجى مراجعة القيم المُدخلة.';

  @override
  String get errorNotFound => 'العنصر المطلوب غير موجود.';

  @override
  String get errorConflict => 'يتعارض هذا الإجراء مع بيانات قائمة.';

  @override
  String get errorPermission => 'ليس لديك صلاحية لتنفيذ هذا الإجراء.';

  @override
  String get errorStorage =>
      'تعذّر قراءة قاعدة البيانات المحلية أو الكتابة فيها.';

  @override
  String get errorCrypto => 'فشلت إحدى العمليات الآمنة.';

  @override
  String get errorTimeout => 'استغرقت العملية وقتًا طويلًا. حاول مرة أخرى.';

  @override
  String get errorHardware => 'ميزة مطلوبة في الجهاز غير متوفّرة.';

  @override
  String get settingsBusinessSectionTitle => 'بيانات النشاط';

  @override
  String get settingsBusinessSectionSubtitle => 'تظهر في الفواتير والتقارير';

  @override
  String get settingsNameLabel => 'اسم النشاط';

  @override
  String get settingsPhoneLabel => 'رقم الهاتف';

  @override
  String get settingsAddressLabel => 'العنوان';

  @override
  String get settingsTaxRateLabel => 'نسبة الضريبة';

  @override
  String get settingsCurrencyLabel => 'العملة';

  @override
  String get settingsReceiptFooterLabel => 'تذييل الفاتورة';

  @override
  String get settingsAppearanceSectionTitle => 'المظهر واللغة';

  @override
  String get settingsAppearanceSectionSubtitle => 'تُحفظ على هذا الجهاز';

  @override
  String get settingsThemeLabel => 'المظهر';

  @override
  String get settingsLanguageSystem => 'لغة الجهاز';

  @override
  String get settingsDiscard => 'تراجع';

  @override
  String get settingsSaved => 'تم الحفظ';

  @override
  String get settingsSaveFailed => 'تعذّر الحفظ. حاول مرة أخرى.';

  @override
  String get settingsLoadFailed => 'تعذّر تحميل الإعدادات المحفوظة.';

  @override
  String get settingsNameRequired => 'أدخل اسم النشاط.';

  @override
  String get settingsTaxRateInvalid => 'أدخل نسبة ضريبة بين 0 و100.';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitle => 'أدخل بيانات حسابك للمتابعة.';

  @override
  String get loginUsernameLabel => 'اسم الدخول';

  @override
  String get loginSecretLabel => 'كلمة المرور أو رمز PIN';

  @override
  String get loginSecretHelper => 'استخدم كلمة مرورك أو رمز PIN الخاص بك.';

  @override
  String get loginSecretToggleTooltip => 'إظهار أو إخفاء';

  @override
  String get loginSubmit => 'دخول';

  @override
  String get loginUsernameRequired => 'أدخل اسم الدخول.';

  @override
  String get loginSecretRequired => 'أدخل كلمة المرور أو رمز PIN.';

  @override
  String get loginInvalidCredentials => 'اسم الدخول أو كلمة المرور غير صحيحة.';

  @override
  String get loginAccountDisabled => 'هذا الحساب معطّل. راجع المسؤول.';

  @override
  String get loginFailed => 'تعذّر تسجيل الدخول. حاول مرة أخرى.';

  @override
  String get ownerSetupTitle => 'مرحبًا بك في فلو';

  @override
  String get ownerSetupSubtitle => 'هذا تثبيت جديد. أنشئ حساب المالك للبدء.';

  @override
  String get ownerSetupUsernameLabel => 'اسم الدخول';

  @override
  String get ownerSetupUsernameHelper =>
      'من 3 إلى 32 حرفًا أو رقمًا أو نقطة أو شرطة أو شرطة سفلية.';

  @override
  String get ownerSetupSecretLabel => 'كلمة المرور أو رمز PIN';

  @override
  String get ownerSetupSecretHelper =>
      '8 أحرف على الأقل. ستُدخلها في كل عملية دخول.';

  @override
  String get ownerSetupConfirmLabel => 'تأكيد كلمة المرور أو رمز PIN';

  @override
  String get ownerSetupSubmit => 'إنشاء المالك';

  @override
  String get ownerSetupUsernameRequired => 'أدخل اسم الدخول.';

  @override
  String get ownerSetupUsernameInvalid =>
      'استخدم من 3 إلى 32 حرفًا أو رقمًا أو نقطة أو شرطة أو شرطة سفلية.';

  @override
  String get ownerSetupSecretRequired => 'أدخل كلمة المرور أو رمز PIN.';

  @override
  String get ownerSetupSecretTooShort => 'استخدم 8 أحرف على الأقل.';

  @override
  String get ownerSetupSecretMismatch => 'السرّان غير متطابقين.';

  @override
  String get ownerSetupAlreadyInitialised =>
      'هذا التثبيت يحتوي حسابًا بالفعل. سجّل الدخول بدلًا من ذلك.';

  @override
  String get ownerSetupFailed => 'تعذّر إنشاء حساب المالك. حاول مرة أخرى.';
}
