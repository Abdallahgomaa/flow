# اليوم الثالث — ربط واجهات المستخدم بقاعدة البيانات (حفظ وتحديث حي)

> الخطوة: `DAY-3` (تكملة واجب اليوم الثالث) — الموديل: Big Pickle — التاريخ: 2026-10-13
> المصدر الملزم للحالة: `EXECUTION_STATE.md`.

## 1) الهدف

تحقيق شرط اليوم الثالث: «تكامل المنطق مع واجهات المستخدم … تعمل أزرار الحفظ وتحديث البيانات بشكل حي وسليم»،
مع «تخزين البيانات محليًا … لا تضيع عند إغلاق التطبيق»، **مع الحفاظ على Clean Architecture**.

## 2) القرار المعماري ولماذا

كان أمام التنفيذ خياران:

1. **بناء كتالوج المنتجات** في الواجهة ثم ربطه بالقاعدة.
2. **ربط جدول `app_settings` الموجود** (من `P0-12`) بالواجهة.

اخترنا **الخيار الثاني** لأن الخارطة في `EXECUTION_STATE.md` تجعل `P2-02` (جدول المنتجات + DAO + مستودع + ترحيل)
**يعتمد على `P2-01`** (التصنيفات والوحدات) غير المنفَّذة بعد، ولأن شاشات المنتجات تخصّ `P2-05`.
البناء قبل الأساس = تجاوز للمرحلة 1 و`P2-01`، ومخاطرة بإعادة عمل. في المقابل يمنحنا `app_settings` تكاملًا
حقيقيًا كاملًا (قراءة/حفظ/تدقيق) **بلا أي تغيير في المخطط وبلا ترحيل**.

نطاق التسليم:

- **استمرارية المظهر واللغة** محليًا (لا تضيع عند إغلاق التطبيق).
- **نموذج ملف النشاط** (الاسم، الهاتف، العنوان، العملة، نسبة الضريبة، تذييل الفاتورة) مع **زر حفظ حقيقي**.

## 3) ما تم بناؤه

### 3.1 قاعدة البيانات والمزوّدات

- `lib/core/database/database_providers.dart` — مزوّدات Riverpod: `databaseConnectorProvider`
  (يُرمي `StateError` افتراضيًا ويُستبدل في `bootstrap` أو في الاختبارات)، `appDatabaseProvider`
  (يفتح القاعدة ويغلقها عبر `ref.onDispose`)، `unitOfWorkProvider`، `auditServiceProvider`.
  لم يُضَف إلى برميل `core/database/database.dart` عمدًا (البرميل يُستورد في اختبارات Dart الخالصة،
  وهذا الملف يجرّ Flutter).

### 3.2 ميزة الإعدادات (`lib/features/settings/`)

- **`domain/`** (Dart خالص): `setting_keys.dart`، `business_profile.dart` (الضريبة `Rate` بأعداد صحيحة — لا `double`)،
  `app_preferences.dart` (`AppThemePreference` + `AppPreferences`)، `settings_repository.dart`،
  وحالات الاستخدام: `load_business_profile.dart`، `save_business_profile.dart` (تحقق: اسم غير فارغ، ضريبة 0–100، تشذيب النصوص)،
  `load_app_preferences.dart`، `save_theme_preference.dart`، `save_language_preference.dart`.
- **`data/`**: `drift_settings_repository.dart` — كل `save` = **وحدة عمل ذرّية واحدة** (`UnitOfWork`) تُكتب فيها كل الصفوف
  **ويُلحق سجل تدقيق واحد** في نفس المعاملة (القاعدة الملزمة 2). `settings_providers.dart` يربط الحالات والمستودع.
- **`presentation/`**: `settings_screen.dart` (قائمة أفقية/عمودية من `CustomCard`/`CustomTextField`/`CustomButton`)،
  `theme_mode_mapping.dart`، `settings_providers.dart` (`savedBusinessProfile` غير `keepAlive` — إعادة الدخول للشاشة تعيد القراءة من القاعدة).

### 3.3 الربط مع التطبيق (composition root)

- `lib/app/settings/settings_route.dart` — يمرّر المظهر واللغة والدوال الراجعة إلى `SettingsScreen`
  (لأن طبقة `presentation` لا يجوز أن تستورد `lib/app/`).
- `lib/app/router/router.dart` — `AppDestination.settings` صار يعرض `SettingsRoute` الحقيقي بدل `PlaceholderPage`.
- `lib/app/theme/theme_provider.dart` و`lib/app/l10n/locale_provider.dart` — الكتابة في القاعدة عند التغيير
  (`setMode`/`setLocale`) + `restore()` للتغذية عند الإقلاع. **فشل الكتابة لا يكسر الواجهة**: يُسجَّل تحذيرًا فقط.
- `lib/bootstrap.dart` — يفتح القاعدة المشفّرة، يهيّئ المزوّدات، ويستعيد المظهر واللغة **قبل أول إطار** (بلا وميض).
- `lib/shared/l10n/{app_en,app_ar}.arb` — 19 مفتاحًا جديدًا للشاشة (عربي/إنجليزي، مجموعتا المفاتيح متطابقتان).

### 3.4 ملاحظة أمنية مؤقّتة (تُغلق في `P1-11`)

حتى وجود واجهة الدخول (`P1-05`)، يُلفّ **DEK** بمفتاح مشتق من بصمة الجهاز (HWID) بدل كلمة مرور المالك.
عند `P1-11` سيُعاد تغليف **نفس** DEK بكلمة مرور المالك (`KeyManager.changePassword`)، فتبقى القواعد المُنشأة الآن مقروءة.
وإن تعذّر فتح القاعدة (مفتاح/منصة)، **لا ينهار التطبيق**: يعمل مع بطاقة «إعادة المحاولة» في شاشة الإعدادات.

## 4) الاختبارات المضافة

| الملف | التغطية |
|---|---|
| `test/features/settings/drift_settings_repository_test.dart` | قراءة فارغة؛ الحفظ يكتب كل الصفوف + سجل تدقيق واحد + السلسلة سليمة؛ إعادة حفظ نفس المفتاح تُحدِّث الصف (لا تكرار) مع تدقيق كل كتابة |
| `test/features/settings/settings_use_cases_test.dart` | القيم الافتراضية؛ القراءة الكاملة؛ بيانات تالفة تُستبدل بالافتراضي؛ رفض الاسم الفارغ؛ رفض الضريبة >100 وللسالبة؛ التشذيب + حمولة التدقيق؛ الذهاب والإياب؛ تفضيلات المظهر/اللغة عبر حالتي استخدام مستقلتين |
| `test/features/settings/settings_screen_test.dart` | تركيب جديد يعرض الافتراضي؛ **الحفظ يثبت في القاعدة فعليًا** (`loadBusinessProfileProvider`) ويُدقَّق (`entity = app_settings`) والسلسلة سليمة؛ إعادة الفتح تُحمّل القيم؛ الاسم الفارغ يُرفض ولا يُدقَّق شيء |

## 5) تقرير تكامل (قالب القاعدة 5)

```
تقرير تكامل — P0-15 / P0-16
المشكلة: اختبار الشاشة الجديد كان يفشل في فحص سلامة سلسلة التدقيق
         (verifyChain().isIntact == false) بعد حفظ حقيقي عبر مزوّدات التطبيق
         (بساعة النظام)، مع أن المستودع كان يكتب الصفوف بشكل سليم.
السبب الجذري: AuditService.hashEntry يدخل الطابع الزمني في التجزئة بصيغة ISO-8601
         كاملة الدقة (ملي/ميكروثانية)، بينما Drift يخزّن DateTime بالنسبة الافتراضية
         كثوانٍ صحيحة (Unix timestamp بالثواني). القيمة المقروءة عند verifyChain
         تكون مقتطعة، فتُعاد تجزئة مختلفة وتُفسَّر كعبث — وهو عبث وهمي.
         لم تكتشفه الاختبارات السابقة لأنها استخدمت FixedClock بثوانٍ صحيحة
         (الذهاب والإياب بلا فقد)، بينما SystemClock في الإنتاج يحمل ميكروثانية
         فكان **كل** إلحاق سيُنتج سلسلة تفشل في التحقق.
الحل: 1) تطبيع الطابع الزمني إلى ثوانٍ صحيحة قبل التجزئة والتخزين في append.
      2) نفس التطبيع داخل hashEntry (نقطة اختناق واحدة) فلا يمكن لقيمة
         لا تعود من القاعدة أن تُنتج عبثًا وهميًا حتى لو تغيّرت دقة التخزين.
      3) دالة مساعدة `AuditService._toWholeSeconds` موثّقة.
      لم يتغيّر أي سلوك آخر: createdAt لنقاط التحقق ليست داخل التجزئة.
التحقق: test/core/database/audit_chain_test.dart → «sub-second timestamps still
        verify after a database round-trip» (اختبار انحدار)، إضافة إلى اختبار
        الشاشة الذي كشف المشكلة. كامل المجموعة: 180/180 خضراء، وكل تجزئات
        الاختبارات السابقة كما هي لأن التطبيع = الدالة المحايدة مع ثوانٍ صحيحة.
```

## 6) التحقق (أوامر القسم 4)

- `dart format` = **138 ملفًا بلا تغيير**.
- `flutter analyze` = **No issues found**.
- `dart run tool/check_boundaries.dart` = **Boundary check passed**.
- `flutter test` = **180/180 نجحت** (كانت 161 → +19: 18 لاختبارات الإعدادات + 1 لاختبار انحدار التدقيق).
- `build_runner` و`flutter gen-l10n` نجحا (المولَّدات الجديدة: `database_providers.g.dart`،
  `features/settings/{data,presentation}/settings_providers.g.dart`).

> **لا تغيير في المخطط:** `schema_version` ظلّ `3` في Drift؛ لا ترحيل ولا لقطة جديدة.
