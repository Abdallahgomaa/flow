# EXECUTION_STATE.md — Flow: وثيقة تتبع حالة التنفيذ وتوجيهات التطوير الصارمة

> **هذا الملف هو المرجع الوحيد لحالة المشروع.** أي موديل ذكاء اصطناعي (OpenCopilot أو Cursor أو غيره) يبدأ جلسة جديدة أو يتسلّم العمل من موديل آخر **يجب أن يقرأ هذا الملف كاملًا أولًا** قبل لمس أي كود.
>
> **المراجع المرتبطة:** وثيقة متطلبات المنتج (PRD) والمواصفات التقنية (Technical Architecture). معرّفات المتطلبات (مثل `FR-POS-005`) تشير إلى الـ PRD، وأرقام المراحل تشير إلى خارطة الطريق في المواصفات التقنية.
>
> **مكان الحفظ:** جذر المشروع باسم `EXECUTION_STATE.md`، ويُلتزم (commit) مع كل تغيير في الحالة.

---

## 0. ترويسة الحالة (يحدّثها الموديل بعد كل خطوة)

| الحقل | القيمة |
|---|---|
| آخر تحديث | 2026-10-19 |
| آخر موديل عمل | Big Pickle (OpenCode) |
| المرحلة الحالية | Phase 2 — الكتالوج والمخزون (قيد التنفيذ) |
| الخطوة الحالية | `P2-07` |
| عدد الخطوات المكتملة | 30 / 133 |
| إصدار المخطط (schema_version) | Drift: 9 (خطوة `P2-06`: جدول `product_search` الافتراضي FTS5) |
| حالة البناء الأخيرة | `dart format` = 279 ملفًا بلا تغيير، `flutter analyze` = No issues found، `dart run tool/check_boundaries.dart` = Boundary check passed، `flutter test` = 642/642 نجحت، `build_runner` نجح، ولقطة المخطط v9 + اختبار الترحيل (أربع عشرة حالة) نجحا |

---

## 1. حالة التنفيذ الحالية (Current Execution State)

### 1.1 المراحل المكتملة `[DONE]`

> لا تُدرَج هنا إلا خطوة اجتازت كل شروط «تعريف الإنجاز» (القسم 3). كل بند يُكتب بالصيغة:
> `- [DONE] <ID> — <العنوان> — الملفات: <المسارات> — الاختبارات: <المسارات> — التاريخ — الموديل`

- [DONE] `P0-01` — إنشاء مشروع Flutter وهيكل المجلدات والنكهات (Flavors) — الملفات: `lib/main.dart`, `lib/bootstrap.dart`, `lib/app/app.dart`, `lib/app/router/router.dart`, `lib/core/config/app_flavor.dart`, `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml` — الاختبارات: `test/smoke_test.dart` — 2026-10-13 — Copilot SDK

- [DONE] `P0-05` — `core/result`: `Result<T>` و`Failure` (أنواع مغلقة sealed مع map/fold) — الملفات: `lib/core/result/failure.dart`, `lib/core/result/result.dart`, `lib/core/error/failure_mapper.dart` — الاختبارات: `test/core/result/result_test.dart`, `test/core/error/failure_mapper_test.dart` — 2026-10-13 — Big Pickle

- [DONE] `P0-02` — ضبط التحليل الصارم + أداة منع خرق الحدود بين الطبقات — الملفات: `analysis_options.yaml`, `tool/check_boundaries.dart`, ونقل رموز التصميم إلى `lib/shared/design/{app_colors,app_dimens,app_typography,app_theme_extension,design}.dart` (لفصل `shared` عن `app`) — الاختبارات: `test/tool/check_boundaries_test.dart` — 2026-10-13 — Big Pickle

- [DONE] `P0-03` — مسار CI (format, analyze, boundaries, test) — الملفات: `.github/workflows/ci.yml` — 2026-10-13 — Big Pickle

- [DONE] `P0-04` — ملف `AGENTS.md` في الجذر (قواعد القسم 2 وقواعد المواصفات) — الملفات: `AGENTS.md` — 2026-10-13 — Big Pickle

- [DONE] `P0-06` — `core/money`: كائن `Money` (أعداد صحيحة + عملة) مع `Rate` و`RoundingMode` و`MoneyFormatter` (بلا `double`) — الملفات: `lib/core/money/{currency,rounding_mode,rate,money,money_formatter,money_core}.dart` — الاختبارات: `test/core/money/{money,rate,money_formatter}_test.dart` — 2026-10-13 — Big Pickle

- [DONE] `P0-07` — `Quantity` + حاسبة الضريبة (شامل/غير شامل، توزيع الباقي بطريقة أكبر باقٍ) — الملفات: `lib/core/money/{quantity,tax_mode,tax_calculator}.dart` — الاختبارات: `test/core/money/{quantity,tax_calculator}_test.dart` — 2026-10-13 — Big Pickle

- [DONE] `P0-08` — `core/utils`: `Clock` وUUID v7 وربط المسجّل بساعة مُحقونة (لا `DateTime.now()` خارج `SystemClock`) — الملفات: `lib/core/utils/{clock,uuid_v7,utils_providers,logger_provider,logger}.dart` — الاختبارات: `test/core/utils/{clock,uuid_v7,logger_clock}_test.dart` — 2026-10-13 — Big Pickle

- [DONE] `P0-09` — التوطين: ARB (ar/en) + دعم RTL + مبدّل اللغة + مفاتيح رسائل الأخطاء — الملفات: `l10n.yaml`, `lib/shared/l10n/{app_en,app_ar}.arb`, `lib/shared/l10n/{l10n,error_messages}.dart`, `lib/app/l10n/locale_provider.dart`، وتحديث `app.dart`/`home_screen.dart`/`app_error_widget.dart` — الاختبارات: `test/shared/l10n/error_messages_test.dart`, `test/app/l10n/locale_provider_test.dart` — 2026-10-13 — Big Pickle

- [DONE] `P0-10` — المظهر والقالب المتكيّف: `go_router` (StatefulShellRoute) + شريط سفلي للهاتف / جانبي للتابلت وسطح المكتب + شاشة `/dev` (ملعب Money/Tax) — الملفات: `lib/app/router/router.dart`, `lib/app/shell/{app_destination,adaptive_shell,placeholder_page,dev_screen}.dart` — الاختبارات: `test/app/router/app_router_test.dart`, `test/app/shell/app_destination_test.dart` — 2026-10-13 — Big Pickle

- [DONE] `P0-11` — استكشاف SQLite/SQLCipher/FTS5 (Spike): القياس `SQLITE_VERSION=3.53.4`، `cipher_version` فارغ على المضيف (SQLCipher يعمل داخل بناء التطبيق فقط)، FTS5 مدعوم — الملفات: `docs/P0-11_sqlite_spike.md` (مع مسبار مؤقّت في `test/spike` حُذف) — 2026-10-13 — Big Pickle

- [DONE] `P0-12` — `AppDatabase` (Drift) + اتصال قابل للحقن (`DatabaseConnector`) + PRAGMA (WAL/foreign_keys/secure_delete) + جدول `app_settings`؛ مغلّف الإنتاج `SqlCipherDatabaseConnector` (PRAGMA key أولًا) — الملفات: `lib/core/database/{app_database,database_connector,database_pragmas,database,tables/app_settings}.dart`, `lib/app/database/sqlcipher_database_connector.dart` — الاختبارات: `test/core/database/app_database_test.dart` — التوثيق: `docs/P0-12_database.md`, `docs/DEVELOPMENT_ENVIRONMENT.md` — 2026-10-13 — Big Pickle

- [DONE] `P0-13` — أساس الأمان: `KeyManager` (Argon2id → KEK، DEK عشوائي 32 بايت، تغليف AES-GCM، تخزين آمن) + `SecureStore` قابل للحقن؛ كلمة المرور الخاطئة مرفوضة وتغييرها يعيد تغليف نفس DEK — الملفات: `lib/core/security/{secure_store,in_memory_secure_store,key_manager,security}.dart`, `lib/app/security/flutter_secure_store.dart` — الاختبارات: `test/core/security/key_manager_test.dart` — 2026-10-13 — Big Pickle

- [DONE] `P0-14` — وحدة العمل: `UnitOfWork` + `DriftUnitOfWork` (معاملة Drift واحدة تغلّف المستودعات؛ أي استثناء = تراجع كامل) — الملفات: `lib/core/database/unit_of_work.dart`, `lib/core/database/database.dart` — الاختبارات: `test/core/database/unit_of_work_test.dart` (تثبيت الكتابة عند النجاح + تراجع كامل عند الاستثناء) — 2026-10-13 — Big Pickle

- [DONE] `P0-15` — سجل التدقيق: جدول `audit_log` (مخطط v2) + Triggerان يمنعان UPDATE/DELETE + `AuditService.append` بسلسلة تجزئة SHA-256 (prev_hash/hash، بذرة أصفار) داخل `UnitOfWork` — الملفات: `lib/core/database/{tables/audit_log,audit_service,app_database,database}.dart` — الاختبارات: `test/core/database/audit_service_test.dart` — التوثيق: `docs/P0-15_audit.md` — 2026-10-13 — Big Pickle

- [DONE] `P0-16` — فحص السلامة: `AuditService.verifyChain()` يكشف أول حلقة مكسورة + نقاط تحقق (`audit_checkpoints`، مخطط v3) + Triggerان إضافيان يمنعان تعديلها؛ اختبار عبث بتعديل صف/ذيل السلسلة — الملفات: `lib/core/database/{audit_chain_status,tables/audit_checkpoints,audit_service,app_database,database}.dart` — الاختبارات: `test/core/database/audit_chain_test.dart` — التوثيق: `docs/P0-16_chain.md` — بوابة G0 مكتملة — 2026-10-13 — Big Pickle

- [DONE] `EXTRA-HWID` — وحدة الترخيص المحلي (HWID): بصمة الجهاز `HardwareId` (SHA-256 مُنطَّق) + `LicenseKey` (`FLOW1.<base64url(payload)>.<base64url(sig)>`) + `LicenseVerifier` (توقيع Ed25519 + ربط الجهاز + الانتهاء) + `LicenseService` (`activate`/`load`/`deactivate` عبر `Result<T>`) — الملفات: `lib/core/licensing/{device_id_provider,hardware_id,license,license_key,license_verifier,license_store,license_service,licensing}.dart`، `lib/core/utils/canonical_json.dart`، `lib/app/licensing/{device_info_device_id_provider,secure_license_store}.dart` — الاختبارات: `test/core/licensing/{license_test,license_service_test}.dart` — التوثيق: `docs/EXTRA_hwid_licensing.md` — 2026-10-13 — Big Pickle

- [DONE] `DAY-1` — **اليوم الأول: التأسيس المعماري ونظام التصميم** (يشمل الجزء المتعلّق بالمظهر من `P0-10` وجزء المسجّل من `P0-08`) — التفاصيل:
  - **هيكل Feature-First:** إنشاء `lib/app`, `lib/core`, `lib/features` (17 ميزة × `domain/data/presentation`), `lib/shared` مع `.gitkeep`.
  - **نظام التصميم:** `lib/app/theme/app_colors.dart`, `app_typography.dart`, `app_dimens.dart`, `app_theme_extension.dart`, `app_theme.dart`, `theme_provider.dart`.
  - **عناصر الواجهة الموحّدة:** `lib/shared/widgets/custom_button.dart`, `custom_text_field.dart`, `custom_card.dart`, `app_error_widget.dart`, `widgets.dart`.
  - **إدارة الحالات (Riverpod 3 + codegen):** `theme_provider.dart`, `lib/core/config/app_flavor_provider.dart`, `lib/core/utils/logger_provider.dart`.
  - **نظام الأخطاء والتسجيل العام:** `lib/core/utils/logger.dart`, `lib/core/error/error_handler.dart`, `crash_reporter.dart`, `error.dart`, تسلسل الإقلاع في `lib/bootstrap.dart`.
  - **شاشة عرض نظام التصميم:** `lib/app/shell/home_screen.dart`.
  - الاختبارات: `test/app/theme/app_theme_test.dart`, `test/core/utils/logger_test.dart`, `test/shared/widgets/custom_button_test.dart`, `test/shared/widgets/custom_text_field_test.dart`, `test/shared/widgets/custom_card_test.dart`, `test/widget_test.dart`, `test/smoke_test.dart` — 2026-10-13 — Big Pickle
  - ✅ **التحقق اليدوي (T):** تم تشغيل التطبيق ومشاهدة واجهات نظام التصميم (CustomButton / CustomTextField / CustomCard + مبدّل الوضع الفاتح/الداكن) على المحاكي بنجاح — تحقّق من قِبل المستخدم في 2026-10-13.

- [DONE] `DAY-3` — **ربط واجهات المستخدم بقاعدة البيانات (حفظ وتحديث حي)** على جدول `app_settings` الموجود — **بلا تغيير مخطط وبلا ترحيل** — التفاصيل:
  - **ميزة الإعدادات كاملة:** `lib/features/settings/{domain,data,presentation}` — مفاتيح `SettingKeys`، كيان `BusinessProfile` (الضريبة `Rate` بلا `double`)، `AppPreferences`/`AppThemePreference`، واجهة `SettingsRepository`، حالات استخدام (`LoadBusinessProfile`, `SaveBusinessProfile` مع تحقق، `LoadAppPreferences`, `SaveThemePreference`, `SaveLanguagePreference`)، مستودع Drift مدقَّق `DriftSettingsRepository` (كتابة ذرّية داخل `UnitOfWork` + سجل تدقيق واحد لكل حفظ)، مزوّدات Riverpod، وشاشة `SettingsScreen` (ملف النشاط + العملة + المظهر + اللغة).
  - **المزوّدات الأساسية:** `lib/core/database/database_providers.dart` (`databaseConnectorProvider` يُحقَن/يُستبدل في الاختبارات، `appDatabaseProvider`, `unitOfWorkProvider`, `auditServiceProvider`).
  - **ربط الإقلاع والتوجيه:** `lib/bootstrap.dart` يفتح القاعدة المشفّرة ويهيّئ المزوّدات ويستعيد المظهر واللغة **قبل أول إطار**؛ `AppDestination.settings` يعرض `SettingsRoute` الحقيقي (`lib/app/settings/settings_route.dart`) بدل الشاشة البديلة.
  - **استمرارية المظهر واللغة:** `theme_provider.dart` و`locale_provider.dart` يكتبان التفضيل في القاعدة (`setMode`/`setLocale`) ويُستعادان عبر `restore()` عند الإقلاع — فلا تضيع عند إغلاق التطبيق. (فشل الكتابة يُسجَّل تحذيرًا ولا يكسر تغيير المظهر/اللغة.)
  - **ملاحظة أمنية مؤقّتة:** يُلفّ DEK بمفتاح مشتق من بصمة الجهاز (HWID) لأن فتح القاعدة يسبق الدخول؛ وقد أُنشئت شاشة الدخول في `P1-05`، لكن إعادة لفّ **نفس** DEK تحت كلمة المالك (`KeyManager.changePassword`) من نطاق `P1-11`؛ وعند تعذّر فتح القاعدة يستمر التطبيق مع بطاقة «إعادة المحاولة» في شاشة الإعدادات بدل الانهيار.
  - الملفات: `lib/core/database/database_providers.dart`, `lib/features/settings/domain/*`, `lib/features/settings/data/*`, `lib/features/settings/presentation/*`, `lib/app/settings/settings_route.dart`, `lib/app/theme/theme_provider.dart`, `lib/app/l10n/locale_provider.dart`, `lib/bootstrap.dart`, `lib/app/router/router.dart`, `lib/shared/l10n/{app_en,app_ar}.arb` — الاختبارات: `test/features/settings/{drift_settings_repository_test,settings_use_cases_test,settings_screen_test}.dart` — التوثيق: `docs/DAY-3_ui_wiring.md` — 2026-10-13 — Big Pickle
  - **إصلاح تكامل مرافق (القاعدة 5):** ثُبِّت خطأ كامن في سلسلة التدقيق `P0-15`/`P0-16` (دقة الطابع الزمني) — التفاصيل في القسم 7.

- [DONE] `P1-01` — **تعداد `Permission` + مصفوفة الأدوار الافتراضية (مالك، كاشير، مخزون، محاسب)** — **(Phase 1 — الهوية والصلاحيات)**:
  - **الملفات:** `lib/features/auth/domain/permission.dart` (31 صلاحية مغلقة، كل واحدة بـ`code` ثابت + `Permission.fromCode`)، `lib/features/auth/domain/user_role.dart` (`UserRole` الأربعة + `UserRole.fromCode`)، `lib/features/auth/domain/role_matrix.dart` (واجهة `RoleMatrix` + `DefaultRoleMatrix`).
  - **تصميم:** `RoleMatrix` واجهة (interface first) ليُستبدل تنفيذها بالأدوار المخصصة في `P1-14` دون لمس حالات الاستخدام؛ `permissionsFor` تعبير `switch` **شامل**، فإضافة دور جديد تُصبح خطأ تصريف لا منحًا صامتًا لصفر صلاحيات؛ المجموعات `const` وغير قابلة للتعديل.
  - **الاختبارات:** `test/features/auth/domain/{permission,user_role,role_matrix}_test.dart` — **اختبار لكل خلية** (4 أدوار × 31 صلاحية = 124 خلية) + حراسة «المالك يملك كل الصلاحيات» + ثبات المجموعات. المجموع الكلي 318/318.
  - **التوثيق:** `docs/P1-01_permissions.md` (المصفوفة كاملة + تبرير كل دور + الحرّاس المقصودون).
  - ⚠️ **تحفّظ مقصود:** معيار القبول «تطابق مصفوفة PRD القسم 2 خلية بخلية» **غير قابل للتحقق** لأن وثيقة PRD غير موجودة في المستودع (يذكرها هذا الملف كمرجع خارجي). بموافقة مالك المشروع (2026-10-13) **اشتُقّت المصفوفة من المجالات الوظيفية**، وهي **مؤقتة بانتظار مصادقة PRD** وتُراجَع خلية بخلية عند توفّر الوثيقة. القرار مسجَّل أيضًا في القسم 7.
  - 2026-10-13 — Big Pickle

- [DONE] `P1-02` — **جداول `users` و`roles` + المستودعات + الترحيل الأول** — **(Phase 1 — الهوية والصلاحيات)**:
  - **المخطط:** Drift v3 → v4. جدولان جديدان: `roles` (`code` PK، `name`، `description`، `is_built_in`، `disabled_at`، `created_at`، `updated_at`) و`users` (`id` PK، `username` فريد، `display_name`، `role_code` يشير إلى `roles.code`، `password_hash`، `pin_hash`، `disabled_at`، `created_at`، `updated_at`). **تعطيل منطقي فقط، بلا حذف نهائي.**
  - **الترحيل:** فرع `from < 4` في `onUpgrade` ينشئ `roles` ثم `users` (الترتيب مهم بسبب المفتاح الأجنبي)، ثم يُعيد تفعيل حرّاس الجداول اللاحقة للإلحاق.
  - **آلية اللقطات (جديدة ومُعمَّمة):** `drift_schemas/drift_schema_v3.json` (الأساس قبل التغيير) و`drift_schema_v4.json`، مع `drift_dev schema generate` → `test/core/database/generated_migrations/`، واختبار `test/core/database/migration_test.dart` (ترقية v3→v4 + قاعدة جديدة مطابقة + بقاء حرّاس الإلحاق). استُثني مجلد الملفات المولَّدة من التحليل في `analysis_options.yaml`.
  - **تسمية Drift:** أُضيف `@DataClassName('RoleRow')` و`@DataClassName('UserRow')` لتفادي التعارض مع كيانات `domain` (`Role`/`User`).
  - **الطبقتان:** `domain/{role,user}.dart` + `domain/{role_repository,user_repository}.dart` + ست حالات استخدام في `domain/use_cases/` (قراءة/إنشاء/تعطيل فقط)، والتنفيذ في `data/{drift_role_repository,drift_user_repository}.dart` مع `data/auth_providers.dart`.
  - **التدقيق (I):** كل كتابة داخل `unitOfWork.run` مع `auditService.append` في **نفس المعاملة**؛ كيان التدقيق `roles`/`users` مع `entityId`؛ التعطيل المكرَّر لا يكتب سطرًا (لا تغيير)؛ وحِمل التدقيق يخلو من PII (لا اسم دخول ولا تجزئة).
  - **الاختبارات:** `test/features/auth/data/drift_role_repository_test.dart`، `test/features/auth/data/drift_user_repository_test.dart`، `test/features/auth/auth_use_cases_test.dart` — تشمل التفرّد، والدور المجهول، ورفض تعطيل الدور المدمج، وعدم الحذف، وسلامة سلسلة التدقيق. المجموع الكلي 358/358.
  - 2026-10-13 — Big Pickle

- [DONE] `P1-03` — **خدمة تجزئة كلمة المرور وPIN (Argon2id وملح لكل مستخدم)** — **(Phase 1 — الهوية والصلاحيات)**:
  - **الواجهة (domain):** `lib/features/auth/domain/password_hasher.dart` — `abstract interface class PasswordHasher` بـ`hash` و`verify` والعودة `Result<T>` فقط، بلا كشف الخوارزمية للطبقات الأعلى؛ ثابتان لأكواد الفشل: `emptySecretCode` و`malformedHashCode`.
  - **التنفيذ (data):** `lib/features/auth/data/argon2_password_hasher.dart` — `Argon2PasswordHasher` فوق `package:cryptography` (Argon2id) وبصيغة PHC: `$argon2id$v=19$m=16384,t=2,p=1$<salt>$<digest>`؛ ملح عشوائي 16 بايت من `Random.secure()` (قابل للحقن للاختبارات)؛ المقارنة **بزمن ثابت** (لا تكشف بادئة مطابقة)؛ `verify` يُعيد الاشتقاق دائمًا بمعاملات **المخزّنة داخل السلسلة** لا بالافتراضية، فالقيم القديمة تظل صالحة عند رفع المعاملات لاحقًا؛ لا يُسجَّل أي سر أو تجزئة أو ملح؛ الفشل التقني `CryptoFailure` والسر الفارغ `ValidationFailure` (لا يُخزَّن سر فارغ أصلًا).
  - **العايرة الزمنية:** قياس فعلي على آلة المرجع عبر مسبار مؤقّت (`tool/_argon2_probe.dart`، حُذف بعد القياس): `(16384 KiB, iterations=2, parallelism=1)` = **231–313ms** (متوسط ≈272ms)، وهي الأقرب إلى ميزانية ~250ms على مسار Dart الخالص. الاختبارات تستخدم معاملات رخيصة (`256 KiB`، جولة واحدة) كما يفعل `KeyManager`.
  - **المزوّد:** `passwordHasher` في `lib/features/auth/data/auth_providers.dart` (بـ`keepAlive`).
  - **الاختبارات:** `test/features/auth/data/argon2_password_hasher_test.dart` — **11 اختبارًا**: ثبات المعاملات الافتراضية، تجزئة→تحقق ورفض كلمة خاطئة، المرشّح الفارغ = عدم تطابق لا خطأ، فريادة الملح لكل تجزئة، حقن `Random` للثبات الحتمي، ثبات صيغة PHC (ستة أجزاء)، عدم ظهور السر في الناتج، رفض السر الفارغ، صلاحية تجزئة بمعاملات أقدم، رفض القيم التالفة/الأجنبية بـ`malformedHashCode`، وحدّ زمني فضفاض لكلفة الإنتاج. المجموع الكلي 369/369.
  - **ملاحظة تصميمية:** لا `Isolate.run` — الاشتقاق على خيط المستدعي كما يفعل `KeyManager` (نمط واحد للمشروع، بلا نمطٍ موازٍ)؛ على واجهة `P1-11` عرض تقدّم والانتظار بالـ`await`.
  - **تحفّظ:** نطاق `P1-03` هو الخدمة فقط؛ لا مستهلك لها بعد (كتابة `users.password_hash`/`pin_hash` تأتي مع `P1-11`/`P1-14`).
  - 2026-10-14 — Big Pickle

- [DONE] `P1-04` — **`sessionProvider` (المستخدم، الدور، الصلاحيات، الوردية)** — **(Phase 1 — الهوية والصلاحيات)**:
  - **الكيان (domain):** `lib/features/auth/domain/session_state.dart` — `SessionState` غير قابل للتعديل (`user`, `role`, `activeShiftId`, `isLocked`) مع `isSignedIn` و`hasOpenShift`؛ `role` يبقى معروفًا بعد القفل ليقدّم `P1-07` تبديلًا سريعًا لنفس الحساب، و`activeShiftId` **معرِّف فقط** لأن كيان الوردية يأتي في `P3-11`؛ و`lock()`/`withActiveShift()` تُعيدان `this` عند عدم وجود تغيير فلا إشعار عبثي للمستمعين.
  - **المزوّد (data):** `lib/features/auth/data/session_notifier.dart` — `Session` (Riverpod، `keepAlive`) بعمليات صريحة: `signIn` و`signOut` و`lock` و`setActiveShift`؛ `signIn` يستبدل الحالة كاملة في إسناد واحد (لا حالة جزئية أبدًا) ويرفض الحساب المعطّل بـ`ValidationFailure(code: Session.disabledAccountCode)` بلا أي تغيير في الحالة؛ ورمز الدور غير المدمج ⇒ `role == null` ⇒ **صفر صلاحيات** (فشل مغلق بانتظار `P1-14`).
  - **الصلاحيات مشتقّة لا مخزّنة:** `sessionPermissions` يقرأ المصفوفة **حيًّا** من `roleMatrixProvider` في كل قراءة، فلا يمكن أن تبقى صلاحية قديمة بعد تعديل المصفوفة، ولا يوجد نسخ يدوي للصلاحيات في أي مكان.
  - **معيار القبول (A):** `lock()` يسحب كل الصلاحيات ويجعل `isSignedIn`/`hasOpenShift` خطأ مع الاحتفاظ بالحساب والدور والوردية للعرض فقط — «القفل يُبطل الجلسة» ✅.
  - **حل الحدود (I):** `lib/features/auth/auth.dart` — **أول برميل (barrel) في المستودع** يُصدِّر السطح العام للميزة (`sessionProvider`، `sessionPermissionsProvider`، `roleMatrixProvider`، `SessionState`، `User`، `UserRole`، `Permission`، `RoleMatrix`، `PasswordHasher`)، وهو ما يجعل «يُستهلك من كل ميزة» ممكنًا دون خرق الحدود التي يفرضها `tool/check_boundaries.dart` ✅.
  - **الاختبارات:** `test/features/auth/data/session_notifier_test.dart` — **9 اختبارات**: الحالة الابتدائية، الدخول واستنتاج الدور، **أن الصلاحيات تأتي من المصفوفة الحيّة لا من نسخة مخزّنة**، رفض الحساب المعطّل، دور غير مدمج بلا صلاحيات، الخروج، **القفل يُبطل الجلسة**، تبديل المستخدم بلا تسريب حالة، وفتح/إغلاق الوردية. المجموع الكلي 378/378.
  - **تحفّظ:** المزوّد حالة نقية فقط (بلا واجهة وبلا `KeyManager` وبلا Drift)، ولم يُستهلك فعليًا بعد؛ أول مستهلك هو `P1-05` (شاشة الدخول) ثم `P1-09` (الحراس).
  - 2026-10-14 — Big Pickle

- [DONE] `P1-05` — **شاشة الدخول (كلمة مرور / PIN)** — **(Phase 1 — الهوية والصلاحيات)**:
  - **حالة الاستخدام (domain):** `lib/features/auth/domain/use_cases/sign_in.dart` — `SignIn(UserRepository, PasswordHasher)` يُرجع `Result<User>` جاهزًا لـ`Session.signIn`؛ **رمز واحد** `invalidCredentialsCode` يجمع «حساب غير موجود» و«سر خاطئ» و«لا سر مخزّن» فلا يتسرّب وجود الحساب؛ و**ترتيب الفحص أمني**: يُتحقَّق من السر **أولًا** ثم يُبلَّغ عن الحساب المعطّل (`accountDisabledCode`) فلا يُكشف التعطيل إلا لمن أثبت هويته؛ وخلل تخزين/تشفير حقيقي يُمرَّر كما هو ولا يتنكّر في هيئة «كلمة خاطئة»؛ **بلا أي كتابة وبلا تدقيق** لأن تسجيل المحاولات الفاشلة وحدّها من نطاق `P1-06`.
  - **حقل سر واحد (لا مبدّل نمط):** يُفحص السر مقابل `passwordHash` ثم `pinHash` (أول مطابقة تفوز) فيستخدم المشغّل كلمة مروره أو رمزه بلا تصريح بنوعه — وهذا ما يلبّي «كلمة مرور / PIN» دون اختراع أنواع؛ أسوأ حالة اشتقاقان Argon2id (≈550ms) وهي التي تتكفّل بها `P1-06`.
  - **المزوّد:** `signInProvider` في `lib/features/auth/data/auth_providers.dart` (`keepAlive`) يربط `userRepositoryProvider` + `passwordHasherProvider`.
  - **الواجهة (presentation):** `lib/features/auth/presentation/login_screen.dart` — **أول ملف في مجلد عرض الميزة**؛ `LoginScreen` يستقبل `onSignedIn` **بحقن** فلا تستورد طبقة العرض `app/` ولا `go_router` (الحدود مصونة)؛ يملك `Scaffold` خاصًا به لأنه خارج الهيكل؛ `CustomTextField` لاسم الدخول والسر (مع `obscureText` وكشف/إخفاء) و`CustomButton(isLoading)` يُظهر تقدّمًا أثناء الاشتقاق بلا حجب أي إطار؛ عند الفشل **يُفرَّغ حقل السر ويُعاد التركيز إليه** (أجهزة مشتركة)؛ الرسائل كلها من ARB (ar/en) في 12 مفتاح `login*` تُعرض داخل `_ErrorBanner`.
  - **المسار المؤقّت (I):** `AppRoutes.login = '/login'` + `GoRoute` خارج الهيكل في `lib/app/router/router.dart` مع تعليق صريح بأن **الحراس وإعادة التوجيه من نطاق `P1-09`**؛ لا يوجد `redirect` بعد.
  - **الاختبارات:** `test/features/auth/sign_in_test.dart` (**10**: كلمة المرور، PIN، الاثنان، تشذيب المسافات، سر خاطئ، حساب مجهول بنفس الرمز، حساب بلا سر بعد، الحساب المعطّل بعد سر صحيح، اسم مطلوب، سر مطلوب) + `test/features/auth/login_screen_test.dart` (**4**) = **14 اختبارًا جديدًا**؛ المجموع **392/392**.
  - **تحفّظات معلنة (شفافية):**
    1. **لا يمكن تجربة الدخول يدويًا اليوم:** لا مسار في المستودع يكتب `passwordHash`/`pinHash` (كتابتها `P1-11`) ولا يوجد مالك مُهيّأ (المعالج `P1-10`)؛ فالشاشة صحيحة لكن لا حساب يُدخل به بعد. لذلك تُنشئ اختباراتُ هذه الخطوة مستخدمًا ببصمة Argon2id **حقيقية** مباشرة عبر `DriftUserRepository.create` فيتحقّق المسار كاملًا في الاختبارات.
    2. **معيار التكامل (I) «يعتمد على `KeyManager` لفتح القاعدة» غير مُنفَّذ:** لا يوجد مزوّد لـ`KeyManager` في المستودع بعد، وفتح القاعدة يتم في `bootstrap` بكلمة مشتقّة من HWID (مؤقّت موثّق)؛ وإعادة اللفّ تحت كلمة المالك من نطاق `P1-11`. أُبقي هذا البند **مفتوحًا بمُعلن** ولم يُخترع له منفذ موازٍ.
    3. معيار القبول `FR-AUTH-002` يخصّ PRD غير الموجود في المستودع، فلا يمكن التحقق منه معيارًا بمعيار (نفس تحفّظ `P1-01`).
  - 2026-10-14 — Big Pickle

- [DONE] `OWNER-INIT` — **تهيئة حساب المالك الأول (Owner Account Initialization)** — **(Phase 1 — محتوى `P1-10`/`P1-11` منفَّذ مبكرًا بطلب المالك)**:
  - **بذر الأدوار (domain):** `lib/features/auth/domain/use_cases/seed_built_in_roles.dart` — `SeedBuiltInRoles(RoleRepository, Clock)` **idempotent**: يمرّ على `UserRole.values`، يتخطّى الموجود، وينشئ الباقي بـ`isBuiltIn: true` وأسماء إنجليزية ثابتة (`Owner`/`Cashier`/`Inventory`/`Accountant`)، ويُمرّر أي خطأ قراءة لا يكون `RoleRepository.notFoundCode` كما هو.
  - **إنشاء المالك (domain):** `lib/features/auth/domain/use_cases/initialize_owner.dart` — `InitializeOwner(UserRepository, PasswordHasher, UuidV7Generator, Clock)` يتحقّق (اسم مطلوب / نمط `^[A-Za-z0-9._-]{3,32}$` / سر مطلوب / طول أدنى 8)، ثم **يرفض إن كان في القاعدة أي حساب** (`alreadyInitialisedCode`)، ثم يجزّئ السر عبر `PasswordHasher` (لا سر صريح أبدًا) وينشئ المستخدم بدور `UserRole.owner` عبر `UserRepository.create` (تدقيق في نفس المعاملة)؛ اسم الدخول يُستخدم اسمًا معروضًا لأن الطلب اقتصر على اسم دخول وسر.
  - **المزوّدات:** `lib/features/auth/data/auth_providers.dart` — `allUsers` (غلاف غير متزامن حول `LoadUsers` لأن `loadUsers` متزامن) + `seedBuiltInRoles` + `initializeOwner` + `ownerSetupRequired` (يُرجع `true` **فقط** إذا نجحت القراءة وكانت القائمة فارغة؛ أي خطأ قاعدة يُرجع `false` فلا يُحبس التطبيق في شاشة الإعداد).
  - **الواجهة (presentation):** `lib/features/auth/presentation/owner_setup_screen.dart` — `OwnerSetupScreen` يستقبل `onInitialised` **بحقن** فلا تستورد طبقة العرض `app/`، ويملك `Scaffold` خاصًا به لأنه خارج الهيكل، وثلاثة حقول (اسم الدخول، السر، تأكيد السر مع `obscureText`) و`CustomButton(isLoading)`؛ عند الفشل يُفرَّغ حقلَا السر ويُعاد التركيز، وعند النجاح: بذر الأدوار ← إنشاء المالك ← `Session.signIn` ← `ref.invalidate(allUsersProvider)` ← `onInitialised`.
  - **الربط (I):** `AppRoutes.ownerSetup = '/owner-setup'` + `GoRoute` في `lib/app/router/router.dart`، و`appRouter` صار يشاهد `ownerSetupRequiredProvider` ويمرّر **بوابة إعادة توجيه مؤقتة**: كل المسارات تُحوَّل إلى `/owner-setup` ما دام لا يوجد حساب، و`/owner-setup` تُحوَّل إلى `/login` بعد وجوده، والمشغّل المُسجَّل يُحوَّل من `/login` إلى نقطة البيع. **البوابة مؤقتة، والحراس الفعليون (`PermissionGuard`) من نطاق `P1-09`.**
  - **إصلاح تكامل على كود مُلتزم (قاعدتا 1 و5):** استُخرج شريط الخطأ الخاص من `LoginScreen` إلى `lib/shared/widgets/error_banner.dart` (`ErrorBanner`) وأُضيف إلى برميل `lib/shared/widgets/widgets.dart`، فصارت الشاشتان تعرضان الخطأ بالطريقة نفسها بدل تكرار المنطق؛ اختبار الانحدار: اختبارات `LoginScreen` الأربعة القائمة (تفاصيل تقرير التكامل في القسم 7).
  - **الاختبارات:** `test/features/auth/owner_initialization_test.dart` (بذر الأدوار مرة واحدة + الفعالية المزدوجة + إنشاء المالك ببصمة Argon2id حقيقية + كل رموز التحقق) + `test/features/auth/owner_setup_screen_test.dart` (**4**: عرض النموذج، إنشاء المالك وبدء الجلسة، عدم تطابق السرَّين، سر قصير) + `test/app/owner_setup_redirect_test.dart` (**3**: تثبيت فارغ ← الإعداد، أي مسار ← الإعداد، وجود مالك ← الدخول) + إصلاح ستة اختبارات إقلاع قديمة = المجموع **409/409**.
  - **تحفّظات معلنة (شفافية):**
    1. **الترقيم:** الطلب سمّاه `P1-11`، لكن `P1-11` في القائمة هي «إنشاء حساب المالك + **مفتاح الاسترداد** + فتح بالاسترداد»؛ المُنفَّذ هنا هو **إنشاء المالك وبذر الأدوار وبوابته** فقط، ويبقى مفتاح الاسترداد وفتح بالاسترداد ضمن `P1-11` نفسها (مُعلَّم في القسم 5).
    2. **ربط `KeyManager` مؤجَّل بمُعلن:** القاعدة ما زالت تُفتح بكلمة مشتقّة من HWID (مؤقّت موثّق)؛ وربط الـDEK بكلمة المالك (`KeyManager.changePassword`) يستلزم تعديل `bootstrap`/`core/database` معًا وإلا صار التطبيق غير قابل للفتح عند الإقلاع التالي، فتم تأجيله بموافقة المالك إلى خطوة مخصّصة.
    3. معيار `FR-AUTH-010` (مفتاح الاسترداد) لم يُنفَّذ ولم يُدَّعَ تنفيذه.
  - 2026-10-15 — Big Pickle

- [DONE] `P2-01` — **التصنيفات (شجرة) والوحدات وتحويلها** — **(Phase 2 — الكتالوج والمخزون)**:
  - **المخطط (v4 → v5):** جدولان جديدان في `lib/core/database/tables/`: `categories.dart` (شجرة بالمرجع الذاتي `parentId`، مع `sortOrder` وتعطيل منطقي `disabledAt`) و`units.dart` (`baseUnitCode` مرجع ذاتي + `factorThousandths` بصورتها الصحيحة: `carton` أساسها `piece` بمعامل `12000`)؛ و`app_database.dart` رُفع إلى `schemaVersion = 5` بفرع `if (from < 5)` في `onUpgrade`؛ ووُلّدت لقطة المخطط `drift_schemas/drift_schema_v5.json` ومساعد الترحيل `test/core/database/generated_migrations/schema_v5.dart` مع اختبار ترحيل بخمس حالات.
  - **المجال (domain):** `lib/features/catalog/domain/` — `category.dart` و`unit.dart` (كيانان نقيان بلا اعتماد على Drift)، و`category_tree.dart` (`CategoryTree.build` يبني غابة `CategoryNode`؛ أي صف أبوه مفقود أو واقع في حلقة يُرقّى جذرًا فلا يُفقد صف أبدًا ولا يستمرّ العود بلا نهاية)، و`category_repository.dart` و`unit_repository.dart` (واجهتان بأكواد فشل ثابتة)، و`unit_converter.dart` (خدمة نقية تمشي سلسلة `baseUnitCode` حتى الوحدة الأساسية بضرب معاملات صحيحة مع حارس حلقة).
  - **حالات الاستخدام (7):** `LoadCategories`، `CreateCategory` (تملك الهوية عبر `UuidV7Generator` + `Clock`)، `DisableCategory`، `LoadUnits`، `CreateUnit`، `DisableUnit`، `ConvertQuantity` (تقرأ الوحدات ثم تستدعي `UnitConverter`).
  - **البيانات (data):** `drift_category_repository.dart` و`drift_unit_repository.dart` — كل كتابة داخل `UnitOfWork` مع سطر تدقيق في المعاملة نفسها (القاعدة 3)، ورفض صريح للأب المجهول ورمز الوحدة المكرر والأساس المجهول والحلقة المغلقة؛ و`catalog_providers.dart` بمزوّدات `@Riverpod(keepAlive: true)`، وبرميل الميزة `lib/features/catalog/catalog.dart`.
  - **إصلاح تكامل على كود مُلتزم (قاعدتا 1 و5):** أُضيف `Quantity.multiplyRatio(int numerator, int denominator, {RoundingMode mode})` إلى `lib/core/money/quantity.dart` لأنه لم يكن في `Quantity` سوى `*(int)` بينما يحتاج التحويل ضرب كمية بنسبة صحيحة؛ والنص مطابق لمنطق `Money.multiplyRatio` (نفس الحارس، ونفس `BigInt`، ونفس `Rounding.divide`) فأصبح التقريب موحّدًا بلا تكرار (تفاصيل تقرير التكامل في القسم 7).
  - **الاختبارات:** `test/features/catalog/domain/unit_converter_test.dart` (**11**: كرتونة→قطعة، و2 كرتونة = 24 قطعة، وسلسلة صندوق→كرتونة→قطعة، والاتجاه المعاكس، والتقريب نصف لأعلى، ووحدة مجهولة، ومعامل مفقود، وحلقة، ووحدة معطَّلة تُحوَّل) + `test/features/catalog/domain/category_tree_test.dart` (**6**: التداخل، وترتيب الأشقاء، وأب مفقود، وحلقة، وعدم فقد أي صف) + `test/features/catalog/data/drift_catalog_repositories_test.dart` (**20**: عشرة لكل مستودع على قاعدة ذاكرة حقيقية مع التحقق من سلسلة التدقيق والتراجع الذرّي) + ستة اختبارات انحدار لـ`Quantity.multiplyRatio` في `test/core/money/quantity_test.dart` = المجموع **455/455**.
  - **تحفّظات معلنة (شفافية):**
    1. **لا واجهة في هذه الخطوة:** شاشات المنتجات والتصنيفات من نطاق `P2-05`، وجدول المنتجات نفسه من نطاق `P2-02`؛ فالتجربة (T) هنا تجربة بيانات لا واجهة.
    2. معايير `FR-INV-*` تخصّ PRD غير الموجود في المستودع، فلا يمكن التحقق منها معيارًا بمعيار (نفس تحفّظ `P1-01`).
    3. **الوحدات المعطَّلة تُحوَّل عن قصد:** `UnitConverter` حسابي بحت، فتعطيل وحدة لا يمنع إعادة حساب وثيقة تاريخية تستخدمها.
  - 2026-10-15 — Big Pickle

- [DONE] `P2-02` — **جدول المنتجات + DAO + مستودع + ترحيل** — **(Phase 2 — الكتالوج والمخزون)**:
  - **المخطط (v5 → v6):** جدول `products` في `lib/core/database/tables/products.dart` (اسم، ونوع، وتصنيف، ووحدة مخزون، ووحدة شراء اختيارية، وسعر بيع، وتكلفة اختيارية، وحد إعادة طلب اختياري، وتعطيل منطقي بلا حذف نهائي)، ومرجعان إلى `units.code` باسمين صريحين عبر `@ReferenceName('productsByStockUnit')`/`@ReferenceName('productsByPurchaseUnit')` لإزالة تحذير Drift الحقيقي بتكرار اسم المرجع العكسي `productsRefs`؛ و`app_database.dart` رُفع إلى `schemaVersion = 6` بفرع `if (from < 6) createTable(products)`؛ ووُلّدت لقطة `drift_schemas/drift_schema_v6.json` ومساعد الترحيل `test/core/database/generated_migrations/schema_v6.dart`، ووُسّع اختبار الترحيل إلى **سبع حالات** (v3→v6، v4→v6، v5→v6، تثبيت جديد، وثلاث حالات تتحقق من بقاء حرّاس التدقيق والجداول السابقة وخلو الجدول الجديد).
  - **المجال (domain):** `lib/features/catalog/domain/` — `product_type.dart` (الأنواع الستة بأكواد نصية ثابتة تُخزَّن بدل أرقام التعداد، فلا تُعاد تصنيف صفوف قديمة عند إعادة ترتيب التعداد)، و`product.dart` (كيان نقي يحمل `Money`/`Quantity` ولا يحمل عملة)، و`product_validation.dart` (قواعد مشتركة بين الإنشاء والتعديل + `validateId` بموضع واحد)، و`product_repository.dart` (واجهة بأكواد فشل ثابتة)، وأربع حالات استخدام: `LoadProducts`، `CreateProduct` (تملك الهوية عبر `UuidV7Generator` + `Clock`)، `UpdateProduct` (تُبقي `created_at` والتاريخ المعطَّل من الصف المخزَّن)، `DisableProduct`.
  - **التدقيق (I):** `Product.priceAuditPayload({previous})` يبني `salePriceMinorUnitsBefore/After` و`costPriceMinorUnitsBefore/After`، و`UpdateProduct` يقرأ الصف المخزَّن أولًا ويدمج هذه الحمولة مع `toAuditPayload()`، فيصير تغيير السعر/التكلفة مدقَّقًا صراحةً بزوج «قبل/بعد»، والتحرير الذي لا يحرّك سعرًا لا يسجّل شيئًا.
  - **البيانات (data):** `drift_product_repository.dart` — كل كتابة داخل `UnitOfWork` مع سطر تدقيق في المعاملة نفسها (القاعدة 3)، وفحص التصنيف والوحدتين **داخل** المعاملة (`categoryNotFoundCode`/`stockUnitNotFoundCode`/`purchaseUnitNotFoundCode`)، و`update` يعيد `notFoundCode` إن كان الصف قد اختفى، و`disable` يبقي الصف ويختم زمن التعطيل ولا يدقّق عند تكرار التعطيل؛ و`catalog_providers.dart` اكتسب `productRepository` و`loadProducts`/`createProduct`/`updateProduct`/`disableProduct`/`allProducts`، وبرميل `catalog.dart` أعاد تصدير مجال المنتجات.
  - **قرار محوري — العملة تُقرأ ولا تُخزَّن:** لا يوجد عمود للعملة في `products`؛ المستودع يستنتج عملة المتجر من ملف النشاط (`LoadBusinessProfile`) **عند كل قراءة بلا تخزين مؤقت**، فينعكس تغيير العملة في الإعدادات على كل الأسعار فورًا؛ والعملة المجهولة/التالفة ترجع إلى `Currency.usd` (وهي `BusinessProfile.defaultCurrencyCode`) فلا يمنع إعداد تالف فتح التطبيق.
  - **إصلاح تكامل على كود مُلتزم (قاعدتا 1 و5):** أُضيف برميل `lib/features/settings/settings.dart` لأن `catalog/data` احتاج `LoadBusinessProfile` ولا يجوز له استيراد `settings/data` مباشرة (تفاصيل تقرير التكامل في القسم 7).
  - **الاختبارات:** `test/features/catalog/domain/product_type_test.dart` (**3**) + `product_validation_test.dart` (**9**) + `product_test.dart` (**12**: حمولة التدقيق وزوج قبل/بعد) + `test/features/catalog/data/drift_product_repository_test.dart` (**17**: CRUD على قاعدة ذاكرة حقيقية، ورفض المراجع المجهولة بلا أي كتابة، وترتيب الكتالوج بالاسم، وتدقيق تغيير السعر/التكلفة، وإعادة التعطيل بلا تدقيق ثانٍ، وأن العملة تُعاد قراءتها فعلًا (EGP ثم USD على الرقم المخزَّن نفسه)، وسقوط كود نوع تالف إلى `ProductType.simple`) + **7** اختبارات ترحيل v6 = المجموع **498/498**.
  - **تحفّظات معلنة (شفافية):**
    1. **لا واجهة في هذه الخطوة:** شاشات المنتجات من نطاق `P2-05` والباركود من نطاق `P2-03`؛ فالتجربة (T) هنا تجربة بيانات لا واجهة.
    2. **«الأنواع الستة» مشتقّة مؤقتًا:** PRD غير موجود في المستودع، فاشتُقّت الأنواع صراحةً (`simple`/`weighted`/`service`/`raw_material`/`composite`/`bundle`) ووُثّقت كمؤقتة بانتظار المصادقة (نفس تحفّظ `P1-01`).
    3. **كود نوع مخزَّن غير معروف يسقط إلى `ProductType.simple`** بدل إفشال القراءة كلها؛ فصف كتبه شيء آخر يبقى مقروءًا ولا يُعطّل الكتالوج.
  - 2026-10-15 — Big Pickle

- [DONE] `P2-03` — **الباركود (فريد، متعدد، مضاعِف) + رفض التكرار برابط للموجود** — **(Phase 2 — الكتالوج والمخزون)**:
  - **المخطط (v6 → v7):** جدول `barcodes` في `lib/core/database/tables/barcodes.dart` (عمود `code` بقيد `UNIQUE` على مستوى القاعدة لا فحصًا في الواجهة، ومرجع إلى `products.id`، و`multiplierThousandths` بصورته الصحيحة للباركود المضاعِف، وتعطيل منطقي بلا حذف نهائي)، ولا يحتاج `@ReferenceName` لأنه يشير إلى `products` مرة واحدة؛ و`app_database.dart` رُفع إلى `schemaVersion = 7` بفرع `if (from < 7)`؛ ووُلّدت لقطة `drift_schemas/drift_schema_v7.json` ومساعد الترحيل `test/core/database/generated_migrations/schema_v7.dart`، ووُسّع اختبار الترحيل إلى **تسع حالات** (v3→v7، v4→v7، v5→v7، v6→v7، تثبيت جديد، وأربع حالات محتوى تتحقق من بقاء حرّاس التدقيق وخلو الجداول الجديدة) مع توحيد أسماء الحرّاس في `_appendOnlyTriggers`.
  - **المجال (domain):** `lib/features/catalog/domain/` — `barcode.dart` (كيان نقي بلا عملة: `code`/`productId`/`multiplier` كـ`Quantity`، و`plainUnitMultiplier = Quantity.thousandths(1000)` بتعريف واحد لمعنى «وحدة واحدة»)، و`barcode_validation.dart` (كود مطلوب/منتج مطلوب/مضاعِف موجب + `normaliseCode` تُشذّب ما يضيفه الماسح من فراغات وأسطر جديدة)، و`barcode_repository.dart` (واجهة بأكواد فشل ثابتة)، وأربع حالات استخدام: `LoadBarcodesForProduct`، و`FindBarcodeByCode`، و`CreateBarcode` (تملك الهوية عبر `UuidV7Generator` + `Clock`)، و`DisableBarcode`.
  - **قرار محوري — الفريد يمتد إلى الصفوف المعطَّلة:** القيد على العمود نفسه فيبقى الكود محجوزًا للمنتج الذي كان يعنيه ولا يتغيّر معنى وثيقة قديمة، وإعادة تسجيل كود معطَّل ممنوعة عمدًا والرجوع يكون بإعادة التمكين؛ و`readForProduct` تُعيد المعطَّل (شاشة المنتج تُبهته) بينما `readByCode` لا تحلّ إلا الحيّ (مسار المسح).
  - **رفض التكرار برابط للموجود (FR-INV-011):** فحص التكرار **داخل** المعاملة فيُعاد `ConflictFailure` بالرمز `barcode.alreadyLinkedCode` بلا أي كتابة ولا تدقيق، ثم يأتي «الرابط» من قدرة البحث نفسها: `FindBarcodeByCode`/`readByCode` تُعيد صاحب الكود (`productId`) فيصل المنادي إلى المنتج الموجود — دون الحاجة إلى نوع فشل جديد لأن `Failure` في `core/result` هرمية `sealed` بأنواع `final` لا يجوز لميزة أن تخترع نوعًا منها (تفاصيل في القسم 7).
  - **البيانات (data):** `drift_barcode_repository.dart` — كل كتابة داخل `UnitOfWork` مع سطر تدقيق في المعاملة نفسها (القاعدة 3)، وفحص وجود المنتج (`productNotFoundCode`) والتكرار **داخل** المعاملة، و`disable` يبقي الصف ويختم زمن التعطيل ولا يدقّق عند تكرار التعطيل؛ و`catalog_providers.dart` اكتسب `barcodeRepository` و`loadBarcodesForProduct`/`findBarcodeByCode`/`createBarcode`/`disableBarcode`، وبرميل `catalog.dart` أعاد تصدير مجال الباركود.
  - **الاختبارات:** `test/features/catalog/domain/barcode_test.dart` (**12**: المضاعِف الافتراضي، وحمولة التدقيق لباركود الكرتونة 12000، والمساواة البنيوية، وتشذيب الكود، وأكواد التحقق) + `test/features/catalog/data/drift_barcode_repository_test.dart` (**16**: أكثر من باركود للمنتج نفسه، ورفض الكود المملوك لمنتج آخر بلا كتابة مع الوصول إلى المالك عبر `readByCode`، ومنتج مجهول، وأن المسح لا يحلّ كودًا معطَّلًا بينما شاشة المنتج تراه، وإعادة التعطيل بلا تدقيق ثانٍ، وأن قيد `UNIQUE` نفسه يرفض إدراجًا مباشرًا خلف المستودع) + **9** اختبارات ترحيل v7 = المجموع **530/530**.
  - **تحفّظات معلنة (شفافية):**
    1. **لا واجهة في هذه الخطوة:** شاشة المسح من نطاق `P3-05` وشاشات المنتجات من نطاق `P2-05`؛ فالتجربة (T) هنا تجربة بيانات لا واجهة.
    2. معيار `FR-INV-011` يخصّ PRD **غير موجود** في المستودع، فاشتُقّ سلوكه (فريد/متعدد/مضاعِف + رفض مكرر برابط للموجود) ووُثّق كمؤقت (نفس تحفّظ `P1-01` و`P2-02`).
  - 2026-10-15 — Big Pickle

- [DONE] `P2-04` — **شرائح الأسعار (تجزئة/جملة/مخصص) + خدمة اختيار السعر النقية** — **(Phase 2 — الكتالوج والمخزون)**:
  - **المخطط (v7 → v8):** جدول `price_tiers` في `lib/core/database/tables/price_tiers.dart` (مفتاح `id`، ومرجع إلى `products.id`، و`tier` بكود نصي ثابت لا بترتيب Enum، و`minQuantityThousandths` بصورته الصحيحة لبداية الشريحة — «الجملة من 12 قطعة» = 12000، وللموزون 2500 — و`priceMinorUnits` بأصغر وحدة صحيحة بلا `double`، وتعطيل منطقي بلا حذف نهائي)، و**قيد `UNIQUE` على الثلاثي `(productId, tier, minQuantityThousandths)`** عبر `uniqueKeys` فلا يمكن لشريحتين من المستوى نفسه أن تبدآ من الكمية نفسها (وإلا لحسم ترتيب الصفوف السعر)؛ و`app_database.dart` رُفع إلى `schemaVersion = 8` بفرع `if (from < 8)`؛ ووُلّدت لقطة `drift_schemas/drift_schema_v8.json` ومساعد الترحيل `test/core/database/generated_migrations/schema_v8.dart`، ووُسّع اختبار الترحيل إلى **إحدى عشرة حالة** (v3→v8 … v7→v8، وتثبيت جديد، وخمس حالات محتوى تتحقق من بقاء حرّاس التدقيق وخلو الجداول).
  - **قرار محوري — الشريحة تُختار بالشريحة «والكمية» معًا:** `PriceSelector.select(...)` خدمة **نقية** في `domain/` (بنمط `UnitConverter`، بلا قاعدة بيانات) تأخذ الأشرطة والشريحة والكمية وسعرًا احتياطيًا فتُعيد `Money`: تفوز الشريحة **المطبَّقة الأقرب** (أكبر `minQuantity` لا تتجاوز الكمية) فتتراكم الأشرطة (12+ ثم 100+)؛ وإن لم تنطبق أي شريحة من المستوى المطلوب (لا توجد، أو كلها معطَّلة، أو الكمية أقل من أصغر شريحة) يُعاد **السعر الاحتياطي** (سعر المنتج نفسه) لأن غياب قاعدة جملة **لا يجوز أن يعني المجان**؛ وتُتجاهل الأشرطة المعطَّلة وأشرطة المستوى الآخر تمامًا، والجواب مستقل عن ترتيب القائمة.
  - **المجال (domain):** `price_tier.dart` يحمل **معًا** `enum PriceTier` (`retail`/`wholesale`/`custom`، بكود نصي مخزَّن و`fromCode` تُعيد `null` للمجهول بلا رمي) والكيان `TierPrice` (باسم لا يتصادم مع اسم الـEnum: `id`/`productId`/`tier`/`price` كـ`Money`/`minQuantity` كـ`Quantity`/`disabledAt`/`createdAt`/`updatedAt`، و`firstBandQuantity = Quantity.thousandths(1000)`، و`toAuditPayload()`، و`priceAuditPayload(previous:)` بزوج «قبل/بعد» **لما تغيّر فقط**)؛ و`price_tier_validation.dart` (منتج مطلوب/كمية موجبة/سعر غير سالب + `validateId`)؛ و`tier_price_repository.dart` (واجهة بأكواد `notFound`/`productNotFound`/`duplicateBand`)؛ وخمس حالات استخدام: `LoadTierPricesForProduct` و`CreateTierPrice` و`UpdateTierPrice` و`DisableTierPrice` و**`SelectPrice`** (تقود معيار القبول: تقرأ المنتج لسعرها الاحتياطي ثم الأشرطة ثم تستدعي `PriceSelector`).
  - **البيانات (data):** `drift_tier_price_repository.dart` — كل كتابة داخل `UnitOfWork` مع سطر تدقيق في المعاملة نفسها (القاعدة 3)، وفحص وجود المنتج وفحص **تكرار الشريحة داخل المعاملة** (بلا أي كتابة عند الرفض)، و`update`/`disable` يعيدان القراءة داخل المعاملة (`notFound` لمن اختفى) و`disable` لا يدقّق عند تكرار التعطيل، والعملة **لا تُخزَّن** في صف الشريحة بل تُقرأ من ملف النشاط عند كل قراءة ويسقط الكود التالف إلى `Currency.usd`؛ و`catalog_providers.dart` اكتسب `tierPriceRepository` و`loadTierPricesForProduct`/`createTierPrice`/`updateTierPrice`/`disableTierPrice`/`selectPrice`، وبرميل `catalog.dart` أعاد تصدير مجال شرائح الأسعار.
  - **معايير القبول (A):** اختيار السعر حسب الشريحة والكمية — مُثبَت باختبارات نقية وباختبار تكامل حقيقي (`SelectPrice` فوق مستودعَي Drift): 12 قطعة بالجملة تأخذ سعر أول شريحة، و150 تأخذ سعر الشريحة الأعلى، ومنتج بلا أشرطة يبيع بسعره، وكمية أقل من أصغر شريحة ترجع للسعر الاحتياطي، وشريحة معطَّلة تتوقف عن التسعير.
  - **الاختبارات:** `test/features/catalog/domain/price_tier_test.dart` (**12**: أكواد الـEnum، وحمولة التدقيق وزوج «قبل/بعد» لما تغيّر فقط) + `price_tier_validation_test.dart` (**8**) + `price_selector_test.dart` (**10**: معيار القبول، وتراكم الأشرطة، وأقل من أصغر شريحة، وشريحة أخرى لا تسعّر، وشريحة معطَّلة، وقائمة فارغة، واستقلال عن الترتيب، وبداية موزونة 2500) + `test/features/catalog/data/drift_tier_price_repository_test.dart` (**20**: تخزين/قراءة العملة/الترتيب بالشريحة والبداية/رفض منتج مجهول/رفض شريحة مكررة بلا كتابة ولا تدقيق/تعديل يعيد كتابة السعر ويسجّل «قبل/بعد»/إعادة تعطيل بلا تدقيق ثانٍ/بقاء المعطَّل مرئيًا/أن قيد `UNIQUE` نفسه يرفض إدراجًا مباشرًا خلف المستودع/إعادة قراءة العملة فعلًا (EGP ثم USD على الرقم نفسه)/سقوط كود شريحة تالف إلى `retail`) + `test/features/catalog/data/select_price_test.dart` (**6** تكامل: يُثبت معيار القبول من طرف إلى طرف وعلى عملة المتجر) + **11** اختبار ترحيل v8 = المجموع **588/588**.
  - **تحفّظات معلنة (شفافية):**
    1. **لا واجهة في هذه الخطوة:** شاشات المنتجات (وتبويب شرائح الأسعار فيها) من نطاق `P2-05`؛ فالتجربة (T) هنا تجربة بيانات لا واجهة.
    2. **قواعد شرائح الأسعار مشتقّة مؤقتًا:** PRD **مرجع خارجي** غير موجود في المستودع، فاشتُقّ سلوك «الأقرب المطبَّق يفوز» وسلوك السقوط إلى سعر المنتج عند غياب الشريحة، ووُثّق كمؤقت كما في `P1-01`/`P2-02`/`P2-03`.
    3. **الشريحة `custom` مخزَّنة ومقروءة لكن لا قاعدة تسعير خاصة بها بعد** (لا تُسعّر إلا إن أُضيف لها شريحة من مستواها)، وتسعير الجملة المتقدم (تحويل الوحدات والحد الأدنى للطلب) من نطاق `P7-10`.
  - 2026-10-15 — Big Pickle

- [DONE] `P2-05` — **شاشات المنتجات: قائمة / تفاصيل / تعديل** — **(Phase 2 — الكتالوج والمخزون)**:
  - **الواجهة (presentation):** `lib/features/catalog/presentation/` — `product_list_screen.dart` (قائمة كسولة `ListView.separated` بتصفية في الذاكرة على الاسم + عدّاد + حالة فارغة + إجراء «منتج جديد»)، و`product_details_screen.dart` (المنتج + بطاقة التسعير + أشرطة `P2-04` + باركودات `P2-03`)، و`product_form_screen.dart` (نموذج واحد للإنشاء والتعديل)، و`product_view.dart` (نماذج عرض `ProductView`/`TierPriceView`/`ProductFormData`)، و`product_labels.dart`، و`catalog_widgets.dart` (`CatalogBadge`/`CatalogMutedText`)، و`catalog_routes.dart` (`CatalogRoutes` + `catalogBack`)، و`catalog_ui_providers.dart`؛ وحالة استخدام قراءة واحدة `LoadProductById`.
  - **قرار محوري — بوابة السعر في موضع واحد:** تُطبَّق القاعدة **مرة واحدة** في `ProductView.from(..., showPrices:)` و`TierPriceView.from(..., showPrices:)` فتُفرَّغ حقول النقود (تصير `null`) **قبل** أن تصل إلى أي widget؛ فلا يستطيع أي widget أن «ينسى» إخفاء سعر، والقائمة لا تعرض إلا ما وصلها.
  - **قرار محوري — دور المخزون يعدّل ولا يُسعّر:** `UserRole.inventory` يملك `catalogProductManage` بلا `catalogPriceManage`، فيُسمح له بالتعديل مع **حمل السعر المخزَّن كما هو** (يُقرأ وقت الحفظ من `productForEditProvider`) لأن `UpdateProduct` يفرض سعر بيع واختلاق سعر يعيد تسعير منتج لا يراه المستخدم؛ ولذلك أيضًا لا يُعرض إجراء الإنشاء إلا لمن يملك `canManageProducts` **و**`canViewPrices` معًا (منتج جديد لا سعر مخزَّنًا له)، وتُستبدل حقول التسعير بملاحظة `catalogPricesReadOnlyNote`؛ والفحص النهائي يبقى في حالات الاستخدام (القاعدة 5).
  - **الشاشات:** القائمة تبني الصفوف كسولًا وتُصفّي في الذاكرة (مقايضة صحيحة لكتالوج محلي على القرص)، ونقرة الصف تنقل إلى `/products/:id`؛ والتفاصيل تُخفي **كل** بطاقة التسعير وبطاقة الأشرطة عند `!showsPrices` (لأن شريحة بلا مبلغ لا تقول شيئًا) بينما تبقى الباركودات وحدّ إعادة الطلب دائمًا، والمعطَّل (منتج/شريحة/باركود) يُبهَّت بشعار `Disabled` ولا يُحذف أبدًا؛ والنموذج بلا `controllers` (حقول نصية عادية + حارس `_seeded` + صفوف أزرار `Wrap` بدل القوائم المنسدلة) ويكتب **حصريًا** عبر `CreateProduct`/`UpdateProduct` (القاعدة 3).
  - **التوجيه:** `lib/app/router/router.dart` رُبط بوجهة المنتجات (`AppDestination.products` → `ProductListScreen`) وأضاف المسارين الفرعيين `/products/new` (قبل `:id`) و`/products/:id/edit` من نفس ثوابت `CatalogRoutes`؛ **ولم يُضَف أي تصدير للواجهة في برميل `catalog.dart`** (سابقة `auth`: المستهلك عبر-الميزات يجب ألا يسحب أدوات Flutter، و`lib/app` يجوز له الاستيراد مباشرة).
  - **التوطين:** نحو 55 مفتاحًا جديدًا في **كلا** الملفين `app_en.arb`/`app_ar.arb`، وإعادة استخدام مفاتيح قائمة (`actionSave`/`actionCancel`/`actionRetry`/`productSearchLabel`/`productSearchHint`/`searchNoResults`/`searchResultsCount`) بلا إعادة تعريف.
  - **معايير القبول (A):** صلاحية «بدون أسعار» مُثبَتة باختبارات واجهة على قاعدة بيانات Drift حقيقية في الذاكرة — الدور الذي لا يرى الأسعار يرى القائمة/التفاصيل/النموذج كاملة **بلا أي سعر أو تكلفة** ولا يُعرض له إجراء الإنشاء، بينما تبقى الهوية والباركودات وحدّ إعادة الطلب. **التجربة (T):** 21 اختبار واجهة. **التكامل (I):** إصلاح تكامل واحد موثَّق في القسم 7.
  - **الاختبارات:** `test/features/catalog/presentation/` — `product_view_test.dart` (**6** لقاعدة السعر النقية)، `product_list_screen_test.dart` (**7**)، `product_details_screen_test.dart` (**4**)، `product_form_screen_test.dart` (**4**، منها حسم أن تعديل دور أعمى السعر يترك السعر المخزَّن كما هو) = **21 اختبارًا جديدًا**؛ المجموع **609/609**.
  - **تحفّظات معلنة (شفافية):**
    1. **قواعد شرائح الأسعار وسلوك «بدون أسعار» مشتقّة مؤقتًا:** PRD **مرجع خارجي** غير موجود في المستودع، كما في `P1-01`/`P2-02`/`P2-03`/`P2-04`.
    2. **التجربة اليدوية على المحاكي لكل دور لم تُنفَّذ بعد** (تحقّق T آليّ فقط).
    3. **الحقول المخصصة (`P1-13`) لم تُربط بعد** بهذه الشاشات (معيار I مؤجَّل صراحةً).
  - 2026-10-15 — Big Pickle

- [DONE] `P2-06` — **البحث السريع (FTS5) + ترقيم Keyset** — **(Phase 2 — الكتالوج والمخزون)**:
  - **المخطط (v8 → v9):** جدول افتراضي `product_search` بـ`FTS5` في `lib/core/database/tables/product_search.drift` (drift لا يقبل الجداول الافتراضية إلا في ملف `.drift`) **مفتاحه `rowid` جدول `products`** — لأن `products.id` نصي فالمفتاح الرابط هو الـ`rowid` الضمني — ونسخة الاسم تُخزَّن داخل الجدول نفسه (بلا `external content`) فتُدار بكتابة عادية؛ و`app_database.dart` رُفع إلى `schemaVersion = 9` مع **تمكين وحدة `fts5`** في `build.yaml` داخل `sql.options.modules` (بهذه الصيغة وإلا أسقط drift الجدول بـ`Unknown module "fts5"`)، وثلاثة **مشغّلات** `CREATE TRIGGER IF NOT EXISTS` على `products` (إدراج / تعديل الاسم / حذف) تُنشأ بـ`customStatement` — كما يفعل `_ensureAppendOnlyGuards` — لأن لقطة المخطط لا تحوي أي مشغّل، و`_backfillProductSearch()` (تعبئة أسماء المنتجات القائمة) يُنفَّذ **عند الوصول إلى v9 فقط**.
  - **تسامح غياب FTS5 (بديل `P0-11` الدفاعي):** `_ensureProductSearchIndex()` تحاول `CREATE VIRTUAL TABLE IF NOT EXISTS` وتُرجع `true`، وإن فشلت تسجّل تحذيرًا وتُرجع `false` فيُبنى المخطط بلا الجدول الافتراضي ولا مشغّلات ولا تعبئة، وينزل البحث إلى **فحص اسم بـ`LIKE` مُهرَّب** بنفس دلالات Keyset؛ و`rebuild()` في المستودع هو المخرج المعلن من فهرس معطوب (يُصلح جدولًا أُسقط ويُعيد تعبئته داخل `UnitOfWork` بلا أي سطر تدقيق لأن الفهرس **حالة مشتقّة** لا واقعة عمل).
  - **قرار محوري — ترقيم Keyset لا `OFFSET`:** الترتيب الكلي `(name, id)`، ويُقرأ `limit + 1` صفًا فيُسقط الزائد وتُستخرج `next` من **آخر صف مُعاد** (لا من الصف الزائد)؛ فلا تكرار ولا إسقاط صفوف حتى مع إدخال صف يسبق المؤشر أثناء التقليب (مُثبَت باختبار).
  - **الباركود خارج الفهرس:** لا يُفهرَس الباركود في `FTS5` بل يُطابق بـ**مدى على الفهرس الفريد** `barcodes.code` (`code >= :term AND code < :term || U+10FFFF`) مع حصره في الأكواد الحيّة (`disabled_at IS NULL`) أسوةً بمسار المسح؛ و`matched_barcode` استعلام فرعي بـ`ORDER BY code LIMIT 1` فيستحيل أن يُكرّر منتجٌ له عدّة أكواد مطابقة صفًّا واحدًا.
  - **القراءة على مرحلتين بلا تكرار منطق:** استعلام `customSelect` خام يحسم الصفحة (`id`، `name`، `matched_barcode`) ثم قراءة مصنَّفة للمنتجات مرتَّبة بـ`(name, id)` تُمرَّر عبر `DriftProductRepository.productFromRow(row, currency)` المشترك (فلا يتكرّر فكّ تشفير السعر/العملة)، والعملة تُقرأ من ملف النشاط ولا تُخزَّن، والحقن بمتغيّرات موضعية `?` فقط في ترتيب الظهور.
  - **المجال والبيانات:** `product_search.dart` (`ProductSearchHit`/`ProductSearchCursor`/`ProductSearchPage` + `empty`) و`product_search_repository.dart` (`search`/`rebuild`) وحالتا استخدام `SearchProducts` (**افتراضي 20، سقف 50**، يقتطع الطرف، والمصطلح الفارغ يعود بصفحة فارغة **بلا رحلة إلى القاعدة**) و`RebuildProductSearchIndex`؛ و`drift_product_search_repository.dart` (إنشاء `{database, unitOfWork, loadBusinessProfile}` بلا تدقيق وبلا ساعة) ومزوّدات `productSearchRepository`/`searchProducts`/`rebuildProductSearchIndex` في `catalog_providers.dart`.
  - **عيبان حقيقيان كشفتهما الاختبارات:** (1) توقّع الاختبار أن يشير المؤشر إلى صف «التخطي» الزائد بينما الصحيح أنه يشير إلى آخر صف **مُعاد** (أُصلح الاختبار لا الكود)؛ (2) صيغة `OR EXISTS (SELECT 1 FROM barcodes WHERE product_id = p.id …)` كلّفت **164ms** على 50 ألف صف (استعلام مترابط لكل منتج) فاستُبدلت بـ`p.id IN (SELECT b.product_id FROM barcodes … AND b.code >= ? AND b.code < ?)` (بحث على الفهرس الفريد) فنزل القياس إلى **2ms**.
  - **معايير القبول (A):** مُثبَتة بقياس فعلي على **50 000 SKU** مولَّدة داخل قاعدة Drift في الذاكرة: **بحث واسع بالاسم 44ms، اسم محدَّد 2ms، مسح باركود 2ms** — كلها دون الميزانية (<100ms)، مع **7** اختبارات لدلالات `SearchProducts` + **17** اختبارًا لقاعدة البحث (اسم / بادئة كل كلمة / عربي / تسامح مع علامات الترقيم، باركود كامل وبادئة، المنتج المعطَّل يبقى مرئيًا، مشية Keyset كاملة بلا تكرار ولا إسقاط، السقوط إلى `LIKE` مع تحذير عند إسقاط الجدول، و`rebuild()` يُصلح الفهرس) — المجموع **642/642**.
  - **تحفّظات معلنة (شفافية):**
    1. **لا شاشة بحث في هذه الخطوة:** الخطوة بيانات ومزوّدات فقط؛ البحث الحقيقي في نقطة البيع من نطاق `P3-04`، وقائمة `P2-05` تحتفظ بتصفيتها في الذاكرة (لم تُمسّ)، وشاشة اليوم الأول (`home_screen.dart`/`demo_product.dart`) لم تُلمس.
    2. **لا مفاتيح ARB جديدة** في هذه الخطوة (لا نصّ جديد يظهر للمستخدم).
    3. **إصلاح تكامل واحد** في هذه الخطوة (الوحدة الافتراضية) موثَّق في القسم 7.
  - 2026-10-19 — Big Pickle

### 1.2 المراحل قيد التنفيذ `[IN-PROGRESS]`

> **خطوة واحدة فقط** (أو مجموعة متوازية معرَّفة صراحةً بعلامة ‖) في هذه الحالة في أي وقت.

**`P2-07` — المتغيّرات (Variants) والحزم** — **(Phase 2 — الكتالوج والمخزون)**

- **الحالة:** الخطوة النشطة التالية المباشرة (تلي إغلاق `P2-06`). لم يبدأ تنفيذها بعد.
- **المطلوب لإتمامها:**
  1. متغيّرات المنتج (SKU فرعية) بحدود واضحة بين المنتج الأب والمتغيّر، وباركود لكل متغيّر.
  2. إدخال أي جدول جديد بترحيل (v9 → v10) + لقطة + اختبار ترحيل (القاعدة 7)، وبلا أي `double` للنقود أو الكميات (القاعدة 6).
  3. التوطين عبر `shared/l10n` (في كلا ملفَي ARB)، وإدارة الحالة بـRiverpod 3 بمزوّدات مولَّدة، وكل الرموز البصرية من `shared/design`.
- **معايير القبول (A):** SKU فرعية وباركود لكل متغيّر. **التجربة (T):** إنشاء/بيع (لاحقًا). **التكامل (I):** —.
- **ملاحظات تسليم للموديل التالي:** ابدأ من القسم 5 سطر `P2-07` ومن كود `P2-02`/`P2-03` (جدول المنتجات، وجدول الباركود بقيد `UNIQUE` على `barcodes.code` الذي يمتد إلى الصفوف المعطَّلة) — **لا تُكرّر** منطق الباركود الموجود بل أعِد استخدامه (القاعدة 1). **لا تلمس** كودًا مُلتزمًا في `[DONE]` ولا جداول `products`/`barcodes`/`price_tiers` القائمة إلا بما تفرضه الخطوة صراحةً (القاعدة 10)، وأي جدول جديد يدخل بترحيل + لقطة + اختبار (القاعدة 7). **الحدود:** الوصول للبيانات عبر `features/catalog/data/` ومزوّدات `catalog_providers.dart`، ويبقى `dart run tool/check_boundaries.dart` عابرًا. **الأسعار:** أي عرض يمرّ بنماذج العرض القائمة (`ProductView.from(..., showPrices:)`) فلا يُخترَق قرار «بدون أسعار» (القاعدة 5). ونصّ §6 يبقى `_(لم يُلتزم بعد)_` — المالك هو من يلتزم.

### 1.3 المراحل المتبقية `[PENDING]`

> بالترتيب الصارم. **ممنوع القفز أو التخطي.** التفاصيل الكاملة لكل خطوة في القسم 5.

| الترتيب | المرحلة | الخطوات | بوابة المرحلة |
|---|---|---|---|
| 1 | Phase 0 — الأساس | `P0-02` … `P0-16` | G0 |
| 2 | Phase 1 — الهوية والصلاحيات والإعداد | `P1-01` … `P1-14` | G1 |
| 3 | Phase 2 — الكتالوج والمخزون | `P2-01` … `P2-16` | G2 |
| 4 | Phase 3 — نقطة البيع | `P3-01` … `P3-16` | G3 |
| 5 | Phase 4 — الطباعة والمستندات | `P4-01` … `P4-10` | G4 |
| 6 | Phase 5 — النسخ الاحتياطي والأمان والإعدادات (بوابة MVP) | `P5-01` … `P5-12` | G5 (MVP) |
| 7 | Phase 6 — المشتريات والعملاء والمالية | `P6-01` … `P6-11` | G6 |
| 8 | Phase 7 — أنماط الصناعات | `P7-01` … `P7-11` | G7 |
| 9 | Phase 8 — الذكاء الاصطناعي | `P8-01` … `P8-20` | G8 |
| 10 | Phase 9 — الجاهزية للإصدار | `P9-01` … `P9-07` | G9 |

---

## 2. قواعد التنفيذ والاختبار والتكامل الصارمة (Directives for AI Agents)

### القاعدة 1 — منع التكرار

قبل كتابة أي سطر: اقرأ هذا الملف، ثم افحص المشروع فعليًا (`git log`, شجرة المجلدات، الاختبارات الموجودة). **يُحظر** إعادة بناء أو إعادة كتابة أو استبدال أي كود مُدرَج في `[DONE]`. إن وجدت ملفًا موجودًا لخطوة غير مسجّلة في `[DONE]`، فافحصه وأكمله وفق الخطوة بدل إعادة إنشائه. وإن ظهر تناقض بين هذا الملف وحالة المشروع الفعلية، **توقّف** وأبلغ المستخدم ولا تخمّن.

### القاعدة 2 — المرونة وقابلية التعديل والتطوير

كود نظيف (Clean Code): مسؤولية واحدة لكل ملف/صنف، أسماء واضحة، دوال قصيرة، لا تكرار. احترم الطبقات (domain / data / presentation) وحدود الاستيراد بين الميزات. تعامل مع كل ما قد يتغير (طابعات، محركات OCR، نماذج، أنماط صناعة) عبر **واجهات (Interfaces)** وليس تنفيذات مباشرة. لا أرقام أو نصوص سحرية: استخدم ثوابت وإعدادات وملفات ترجمة (ARB). لا تضف اعتماديات جديدة دون ذكر السبب في ملاحظة الخطوة.

### القاعدة 3 — التكامل والربط مع الخطوات السابقة (Regression-Free)

قبل البدء: حدّد من عمود «تعتمد على» ما الذي ستستخدمه من الكود المكتمل. بعد الانتهاء: شغّل **كامل** مجموعة الاختبارات (وليس اختبارات الخطوة الحالية فقط) وتأكد أن كل اختبارات الخطوات السابقة ما زالت تنجح. أي ميزة جديدة يجب أن تُدمج فعليًا عبر المزوّدات (Providers) والمستودعات الموجودة وليس بنسخ موازية.

### القاعدة 4 — شرط التجربة الفردية والاختبار الدقيق

**يُمنع منعًا باتًا** نقل أي خطوة من `[IN-PROGRESS]` إلى `[DONE]` أو الانتقال للخطوة التالية قبل:

1. تشغيل الخطوة بمفردها وتجربتها عمليًا (اختبار وحدة/تكامل + تجربة يدوية على المحاكي أو الجهاز عند وجود واجهة).
2. اجتياز **أوامر التحقق القياسية** (القسم 4) بصفر أخطاء وصفر تحذيرات.
3. اجتياز **معايير القبول** المكتوبة للخطوة في القسم 5 بندًا بندًا.

### القاعدة 5 — الشفافية وتقرير مشاكل التكامل

عند ظهور أي مشكلة تكامل أو تعارض مع الكود السابق: **أصلحها فورًا**، ثم أرسل للمستخدم تقريرًا مختصرًا بالقالب التالي، وسجّله في القسم 7:

```
تقرير تكامل — <ID الخطوة>
المشكلة: ما الذي حصل ومع أي ملف/خطوة سابقة.
السبب الجذري: لماذا حصلت.
الحل: ما الذي تغيّر (ملفات وقرارات).
التحقق: أي اختبارات أثبتت أن الربط سليم وأن لا شيء انكسر.
```

إن كان الحل يتطلب تعديل كود مكتمل من خطوة سابقة: عدّله بأقل تغيير ممكن، وأضف اختبار انحدار (Regression Test) يغطي المشكلة، ودوّن ذلك في تقرير التكامل.

### القاعدة 6 — تحديث الحالات

بعد نجاح التجربة والربط وجودة الكود: حدّث هذا الملف في **نفس الـ commit**: (أ) انقل الخطوة إلى `[DONE]` مع الملفات والاختبارات، (ب) علّم الخانة في القسم 5، (ج) انقل الخطوة التالية إلى `[IN-PROGRESS]` بتفاصيلها، (د) حدّث الترويسة (القسم 0) والعدّاد، (هـ) أضف سطرًا في سجل التغييرات (القسم 6).

### قواعد ملزمة إضافية (من المواصفات التقنية)

1. **المال** من نوع `Money` (عدد صحيح بأصغر وحدة) والكميات `Quantity`؛ ممنوع `double`.
2. كل كتابة تغيّر حالة الأعمال تمر عبر `UnitOfWork` وتُلحق سجل تدقيق في **نفس المعاملة**.
3. الجداول المخصصة للإضافة فقط (audit_log, stock_movements, payments, customer_ledger, sale_lines) لا تُعدَّل ولا تُحذف؛ التصحيح بمستند تعويضي.
4. كل إجراء حرج يتحقق من الصلاحية و`PinChallenge` **داخل حالة الاستخدام (Use Case)** وليس في الواجهة فقط.
5. لا استدعاءات شبكة ولا أسرار بنص صريح ولا تسجيل لبيانات شخصية.
6. كل تغيير في المخطط = ترحيل (Migration) + لقطة مخطط + اختبار ترحيل. لا تعدّل ترحيلًا سبق إصداره.
7. لا تعدّل `*.g.dart` أو `*.freezed.dart` يدويًا.
8. عند الشك في إضافة تخص منصة: أنشئ واجهة، ونفّذ أأمن بديل، ودوّن القيد، ولا تخمّن.
9. **نطاق الخطوة:** نفّذ الخطوة المطلوبة فقط. لا تلمس ميزات غير مرتبطة ولا «تحسّن» كود مكتملًا خارج إطار إصلاح مشكلة تكامل.

---

## 3. تعريف الإنجاز (Definition of Done) — يُطبَّق على كل خطوة

لا تُنقل خطوة إلى `[DONE]` إلا بتحقق **كل** البنود:

- [ ] كل معايير القبول (A) في القسم 5 متحققة.
- [ ] اختبارات الوحدة/البيانات/الواجهات الخاصة بالخطوة مكتوبة وتنجح (والاختبارات تغطي الحالات الحدّية المذكورة في PRD).
- [ ] تجربة فردية فعلية (T) أُجريت ونجحت.
- [ ] فحص التكامل (I) أُجري، وكامل مجموعة الاختبارات تنجح (لا انحدار).
- [ ] أوامر التحقق القياسية (القسم 4) بصفر أخطاء/تحذيرات.
- [ ] لا TODO معلّقة بلا رقم خطوة مستقبلية تخصها.
- [ ] نصوص الواجهة مترجمة عبر ARB (عربي + إنجليزي) وتعمل في RTL (للخطوات ذات الواجهة).
- [ ] هذا الملف محدَّث (القاعدة 6).

---

## 4. أوامر التحقق القياسية

```bash
dart format --set-exit-if-changed .
dart run build_runner build
flutter analyze            # يجب: No issues found
flutter test               # كامل المجموعة، وليس الخطوة الحالية فقط
# عند تغيّر المخطط:
dart run drift_dev schema dump ... && flutter test test/migrations
# عند وجود واجهة: تجربة يدوية على المحاكي + اختبار golden لـ LTR وRTL
```

---

## 5. قائمة الفحص التفصيلية (Micro-Checklist)

**طريقة الاستخدام:** كل صف خطوة صغيرة مستقلة. العمود الأخير يحدد: **A** = معايير القبول، **T** = التجربة الفردية، **I** = فحص التكامل مع السابق. علّم الخانة بـ `[x]` فقط بعد استيفاء القاعدة 4 والقاعدة 6.

### Phase 0 — الأساس

| ☐ | ID | الخطوة | تعتمد على | A / T / I |
|---|---|---|---|---|
| [x] | P0-01 | مشروع Flutter + هيكل المجلدات + نكهات dev/prod | — | A: يبني ويشتغل بالنكهتين. T: تشغيل على محاكي. I: —. |
| [x] | P0-02 | `analysis_options.yaml` + قاعدة منع الاستيراد بين الميزات + `tool/check_boundaries.dart` | P0-01 | A: يفشل التحليل/الفحص عند استيراد مخالف. T: `test/tool/check_boundaries_test.dart` (10 حالات). I: لا تحذيرات على الكود الحالي. |
| [x] | P0-03 | مسار CI (format, analyze, boundaries, test) | P0-02 | A: يعمل أخضر محليًا بنفس الأوامر. T: `.github/workflows/ci.yml`. I: —. |
| [x] | P0-04 | ملف `AGENTS.md` في الجذر (قواعد القسم 2 وقواعد المواصفات) | P0-01 | A: مطابق للقواعد الملزمة. T: مراجعة يدوية. I: مرتبط بهذا الملف. |
| [x] | P0-05 | `core/result`: `Result<T, Failure>` وأنواع `Failure` | P0-01 | A: أنواع مغلقة (sealed) مع `map/fold`. T: اختبارات وحدة. I: —. |
| [x] | P0-06 | `core/money`: كائن `Money` (أعداد صحيحة + عملة) وعمليات حسابية آمنة | P0-05 | A: لا `double`؛ جمع/طرح/ضرب بنسبة. T: اختبارات خصائص (property tests). I: —. |
| [x] | P0-07 | `Quantity` + حاسبات الضريبة والتقريب (شامل/غير شامل، توزيع الباقي) | P0-06 | A: يطابق قاعدة التقريب في PRD. T: اختبارات حالات حدّية (فرق وحدة صغرى). I: يستخدم `Money`. |
| [x] | P0-08 | `core/utils`: الساعة (Clock) وUUID v7 والمسجّل (Logger) المنزوع الحساسية | P0-01 | A: UUID مرتب زمنيًا؛ المسجّل لا يطبع payload؛ لا `DateTime.now()` خارج `SystemClock`. T: اختبارات وحدة. I: —. |
| [x] | P0-09 | التوطين: ARB (ar/en) + دعم RTL + مبدّل اللغة | P0-01 | A: لا نصوص صلبة؛ تخطيط RTL سليم. T: اختبار تبديل اللغة (ar/en). I: —. |
| [x] | P0-10 | المظهر (Theme) + القالب المتكيّف (هاتف/تابلت/سطح مكتب) + هيكل الموجّه `go_router` | P0-09 | A: 3 أحجام شاشة تعمل. T: اختبار الشريط السفلي/الجانبي + شاشة `/dev`. I: يستخدم ARB. |
| [x] | P0-11 | استكشاف (Spike): SQLCipher + FTS5 على Android وWindows (وiOS إن توفر) | P0-01 | A: تقرير توفر FTS5 وإصدار cipher لكل منصة. T: تشغيل فعلي (`test/spike` مؤقت ثم حُذف). I: قرار موثّق في `docs/P0-11_sqlite_spike.md` — FTS5 متاح؛ SQLCipher يعمل في بناء التطبيق فقط لذا الاتصال قابل للحقن. |
| [x] | P0-12 | `AppDatabase` (Drift) + اتصال SQLCipher + إعدادات PRAGMA (WAL, foreign_keys, secure_delete) | P0-11 | A: يفشل المفتاح الخاطئ؛ `cipher_version` غير فارغ. T: محاولة فتح الملف بـ SQLite عادي تفشل. I: —. |
| [x] | P0-13 | `KeyManager`: Argon2id + DEK عشوائي + التغليف AES-GCM + `SecureStore` | P0-12 | A: كلمة مرور خاطئة مرفوضة؛ تغيير كلمة المرور يعيد تغليف DEK فقط. T: اختبارات وحدة + فتح/قفل. I: يغذّي P0-12. |
| [x] | P0-14 | `UnitOfWork` (معاملة واحدة تغلّف المستودعات) | P0-12 | A: استثناء = تراجع كامل. T: اختبار تراجع. I: —. |
| [x] | P0-15 | جدول `audit_log` + Triggers تمنع UPDATE/DELETE + `AuditService.append` بسلسلة تجزئة | P0-14, P0-08 | A: كل سجل يحمل prev_hash وhash. T: محاولة تعديل/حذف تفشل. I: يُستدعى داخل `UnitOfWork`. |
| [x] | P0-16 | `verifyChain()` + اختبار العبث + تجزئات نقاط التحقق | P0-15 | A: يكشف أول حلقة مكسورة. T: تعديل يدوي للملف ثم الكشف. I: —. **(بوابة G0)** |

**بوابة G0:** CI أخضر؛ قاعدة بيانات مشفّرة غير مقروءة بدون المفتاح؛ سلسلة التدقيق تكشف العبث؛ اللغتان وRTL يعملان.

### Phase 1 — الهوية والصلاحيات (RBAC) والإعداد

| ☐ | ID | الخطوة | تعتمد على | A / T / I |
|---|---|---|---|---|
| [x] | P1-01 | تعداد `Permission` + مصفوفة الأدوار الافتراضية (مالك، كاشير، مخزون، محاسب) | P0-05 | A: تطابق مصفوفة PRD القسم 2 — ⚠️ **PRD غير موجود في المستودع**، لذلك اشتُقّت المصفوفة من المجالات الوظيفية بموافقة المالك (مؤقتة بانتظار المصادقة). T: اختبار لكل خلية في المصفوفة (124 خلية). I: —. |
| [x] | P1-02 | جداول users وroles + المستودعات + الترحيل الأول | P0-14, P0-15 | A: إنشاء/قراءة/تعطيل (بلا حذف نهائي) ✅. T: اختبارات بيانات — مستودعا الأدوار والمستخدمين + حالات الاستخدام ✅. I: سطر تدقيق لكل تغيير في نفس المعاملة وسلامة السلسلة ✅. |
| [x] | P1-03 | خدمة تجزئة كلمة المرور وPIN (Argon2id وملح لكل مستخدم) | P0-13 | A: واجهة نقية `PasswordHasher` + تنفيذ Argon2id بملح عشوائي 16 بايت وصيغة PHC (6 أجزاء)؛ لا تخزين صريح؛ الزمن المقيس 231–313ms (متوسط ≈272ms) ✅. T: 11 اختبارًا (تجزئة→تحقق، رفض كلمة خاطئة، فريادة الملح، ثبات الصيغة، رفض القيم التالفة، صلاحية تجزئة بمعاملات أقدم) + قياس زمني ✅. I: بلا تغيير مخطط (يعتمد على `P0-13`) ✅. |
| [x] | P1-04 | `sessionProvider` (المستخدم، الدور، الصلاحيات، الوردية) | P1-01, P1-02 | A: `lock()` يسحب كل الصلاحيات ويُبطل الجلسة مع إبقاء الحساب للتبديل السريع ✅. T: 9 اختبارات مزوّد (دخول/خروج/قفل/تبديل مستخدم/وردية/دور غير مدمج/حساب معطّل/مصفوفة حيّة) ✅. I: برميل `lib/features/auth/auth.dart` يُتيح الاستهلاك من كل ميزة دون خرق الحدود ✅. |
| [x] | P1-05 | شاشة الدخول (كلمة مرور / PIN) | P1-03, P1-04, P0-10 | A: FR-AUTH-002 (PRD غير موجود فلا تحقّق معيارًا بمعيار) — المُنفَّذ: حالة استخدام `SignIn` تتحقق عبر `PasswordHasher` فقط، ولا تميّز بين اسم مجهول وسر خاطئ، وتفحص السر قبل الإبلاغ عن التعطيل ✅. T: 14 اختبارًا (10 لحالة الاستخدام + 4 للواجهة) ببصمة Argon2id حقيقية ✅؛ **التجربة اليدوية مؤجّلة**: لا مسار لكتابة الكريدنشال (`P1-11`) ولا مالك مُهيّأ (`P1-10`) ⚠️. I: **غير مُنفَّذ بمُعلن** — لا مزوّد `KeyManager` بعد والقاعدة تُفتح في `bootstrap` بكلمة HWID المؤقتة، وإعادة اللفّ تحت كلمة المالك في `P1-11` ⚠️. |
| [ ] | P1-06 | سياسة القفل التدريجي بعد المحاولات الفاشلة + تسجيلها في التدقيق | P1-05 | A: 30ث/2د/15د/ساعة. T: 5 محاولات خاطئة. I: سجل تدقيق. |
| [ ] | P1-07 | القفل التلقائي + التبديل السريع بين المستخدمين مع حفظ السلة | P1-05 | A: FR-AUTH-003, FR-AUTH-006. T: قفل/فتح بدون فقدان سلة. I: السلة مرتبطة بالمستخدم. |
| [ ] | P1-08 | `PinChallengeService` (رمز لمرة واحدة صالح 60 ثانية) | P1-03, P1-04 | A: FR-AUTH-004. T: اختبار انتهاء وإعادة استخدام. I: تستهلكه حالات الاستخدام. |
| [ ] | P1-09 | حراس الموجّه (Router guards) و`PermissionGuard` في حالات الاستخدام | P1-01, P1-04 | A: شاشة محظورة تحوّل للخارج؛ وحالة الاستخدام ترفض بدون صلاحية. T: دخول بكل دور. I: دفاع متعدد (واجهة + مجال). |
| [ ] | P1-10 | معالج الإعداد: اللغة، نمط الصناعة، ملف النشاط، العملة، الضريبة | P0-09, P1-02 | A: FR-AUTH-001. T: تثبيت جديد يكمل المعالج. I: يحفظ business_profile. |
| [ ] | P1-11 | إنشاء حساب المالك + مفتاح الاسترداد (يظهر مرة واحدة + تأكيد) + فتح بالاسترداد | P1-10, P0-13 | A: FR-AUTH-010. T: فتح بمفتاح الاسترداد. I: DEK ثانٍ مغلَّف. ⚠️ **جُزئيًا (2026-10-15):** أُنجز **إنشاء المالك وبذر الأدوار وبوابة `/owner-setup`** مبكرًا في خطوة `OWNER-INIT`؛ يتبقّى مفتاح الاسترداد وفتح بالاسترداد وربط DEK بكلمة المالك. |
| [ ] | P1-12 | إعدادات الصناعة المسبقة + `featureFlagsProvider` | P1-10 | A: تبديل ميزة يخفي واجهتها ولا يحذف بياناتها. T: تبديل يدوي. I: الموجّه والقوائم تقرأ منه. |
| [ ] | P1-13 | محرك الحقول المخصصة (defs/values) + مُصيِّر النماذج الديناميكية | P1-12 | A: FR-CFG-002. T: إضافة حقل لمنتج تجريبي. I: عام وغير مرتبط بميزة بعينها. |
| [ ] | P1-14 | واجهة إدارة المستخدمين والأدوار المخصصة + حماية آخر مالك | P1-09 | A: FR-AUTH-007, FR-AUTH-008. T: محاولة تعطيل آخر مالك. I: تدقيق لكل تغيير. **(بوابة G1)** |

**بوابة G1:** دورة كاملة (إعداد → دخول → تبديل مستخدم → قفل) تعمل؛ كل صلاحية مفحوصة في المجال والواجهة.

### Phase 2 — الكتالوج والمخزون

| ☐ | ID | الخطوة | تعتمد على | A / T / I |
|---|---|---|---|---|
| [x] | P2-01 | التصنيفات (شجرة) والوحدات وتحويلها | P1-02 | A: تصنيف هرمي وتحويل كرتونة→قطعة ✅. T: اختبار بيانات ✅. I: — ✅. |
| [x] | P2-02 | جدول المنتجات + DAO + مستودع + ترحيل | P2-01, P0-07 | A: الأنواع الستة؛ الأسعار `Money` ✅. T: CRUD ✅. I: تدقيق لتغيير السعر/التكلفة ✅. |
| [x] | P2-03 | الباركود (فريد، متعدد، مضاعِف) + رفض التكرار برابط للموجود | P2-02 | A: FR-INV-011. T: إدخال مكرر. I: —. |
| [x] | P2-04 | شرائح الأسعار (تجزئة/جملة/مخصص) | P2-02 | A: اختيار السعر حسب الشريحة والكمية. T: اختبارات وحدة. I: —. |
| [x] | P2-05 | شاشات المنتجات: قائمة / تفاصيل / تعديل | P2-02, P1-09 | A: صلاحية «بدون أسعار» لأخصائي المخزون ✅. T: 21 اختبار واجهة على قاعدة بيانات Drift حقيقية ✅ (التجربة اليدوية على المحاكي مؤجَّلة). I: الحقول المخصصة (P1-13) مؤجَّلة. |
| [x] | P2-06 | البحث السريع (FTS5 أو بديل P0-11) + ترقيم Keyset | P2-02, P0-11 | A: جدول FTS5 + ترقيم Keyset بلا تكرار ولا إسقاط صفوف، وأقل من 100ms على 50 ألف SKU ✅ (قياس فعلي: 44ms بحث واسع بالاسم، 2ms اسم محدَّد، 2ms باركود). T: قياس على بيانات اختبارية مُولَّدة ✅. I: إصلاح الوحدة الافتراضية (القسم 7) ✅. |
| [ ] | P2-07 | المتغيّرات (Variants) والحزم | P2-02 | A: SKU فرعية وباركود لكل متغيّر. T: إنشاء/بيع (لاحقًا). I: —. |
| [ ] | P2-08 | دفتر `stock_movements` + `stock_balances` + أنواع الحركات | P0-14, P2-02 | A: لا تعديل مباشر للكمية. T: اختبارات خصائص: الرصيد = مجموع الدفتر. I: كل حركة تُدقَّق. |
| [ ] | P2-09 | أمر إعادة بناء الأرصدة + فحص الاتساق الليلي | P2-08 | A: يكتشف ويصلح الانحراف. T: إفساد رصيد ثم الكشف. I: —. |
| [ ] | P2-10 | الدفعات والصلاحية + مخصِّص FEFO | P2-08 | A: FR-INV-006؛ حظر المنتهي إلا بتجاوز PIN. T: اختبارات شاملة للمخصِّص. I: يستخدم `PinChallenge`. |
| [ ] | P2-11 | الأرقام التسلسلية ودورة حياتها | P2-08 | A: in_stock→sold→returned. T: اختبارات حالة. I: —. |
| [ ] | P2-12 | تسويات المخزون (تلف، سرقة، شطب) | P2-08, P1-08 | A: بـ PIN وسبب. T: تجربة يدوية. I: تدقيق مع before/after. |
| [ ] | P2-13 | جلسات الجرد (عدّ بالمسح، فروقات، ترحيل مدقَّق) | P2-12 | A: FR-INV-008. T: جرد تجريبي كامل. I: ينتج تسويات في دفتر واحد. |
| [ ] | P2-14 | محرك التنبيهات (انخفاض، قرب انتهاء، منتهي، سريع، راكد) | P2-10 | A: FR-INV-009. T: اختبارات وحدة بتواريخ ثابتة. I: يُقيَّم بعد كل بيع (لاحقًا P3-10). |
| [ ] | P2-15 | مركز الإشعارات وعرض التنبيهات | P2-14 | A: يظهر على لوحة المعلومات. T: تجربة يدوية. I: يحترم الصلاحيات. |
| [ ] | P2-16 | استيراد/تصدير CSV مع معاينة الربط وتقرير أخطاء الصفوف | P2-02 | A: اختبار ذهاب وعودة. T: ملف فيه أخطاء. I: تدقيق للاستيراد. **(بوابة G2)** |

**بوابة G2:** كتالوج كامل يعمل؛ اختبارات الخصائص للمخزون خضراء؛ البحث ضمن الميزانية.

### Phase 3 — نقطة البيع (POS)

| ☐ | ID | الخطوة | تعتمد على | A / T / I |
|---|---|---|---|---|
| [ ] | P3-01 | مجال السلة (Cart): الأسطر والإجماليات | P0-07, P2-02 | A: إجماليات صحيحة. T: اختبارات خصائص. I: يستخدم `Money`/`Quantity`. |
| [ ] | P3-02 | الخصومات (سطر/سلة) وحد الكاشير + الضرائب | P3-01, P1-08 | A: FR-POS-003/004؛ لا إجمالي سالب. T: حالات حدّية. I: تجاوز الحد يطلب PIN المدير. |
| [ ] | P3-03 | `CartController` + الحفظ التلقائي للمسودة (استرداد الأعطال) | P3-02 | A: إغلاق التطبيق لا يفقد السلة. T: قتل التطبيق ثم الفتح. I: مرتبط بالمستخدم والوردية. |
| [ ] | P3-04 | شاشة POS (تخطيطات هاتف/تابلت/سطح مكتب) | P3-03, P0-10 | A: استخدام بيد واحدة. T: تجربة بالأحجام. I: صلاحيات الكاشير. |
| [ ] | P3-05 | المسح: كاميرا (mobile_scanner) + قارئ لوحة المفاتيح (HID) + تصفية 150ms | P3-04, P2-03 | A: مسح مزدوج = زيادة واحدة. T: مسح فعلي. I: باركود مجهول يعرض الخيارات. |
| [ ] | P3-06 | شبكة الإضافة السريعة (مفضلات) | P3-04 | A: قابلة للضبط بالتصنيف. T: تجربة. I: —. |
| [ ] | P3-07 | الأصناف الموزونة (ميزان/إدخال يدوي) | P3-04, P2-02 | A: كمية عشرية دقيقة (`Quantity`). T: وزن تجريبي. I: —. |
| [ ] | P3-08 | نموذج المدفوعات المقسّمة (نقد، بطاقة، آجل، مخصص) + حساب الباقي | P3-02 | A: مجموع الوسائل = الإجمالي. T: حالات: ناقص/زائد. I: —. |
| [ ] | P3-09 | ترقيم الإيصالات (متسلسل بلا فجوات لكل جهاز) | P0-14 | A: لا فجوات ولا تكرار. T: تراجع معاملة لا يستهلك رقمًا. I: —. |
| [ ] | P3-10 | `commitSale` الذرّي: بيع + أسطر + دفعات + حركات مخزون FEFO + تدقيق | P3-08, P3-09, P2-10 | A: FR-POS-014. T: **قتل التطبيق وسط التثبيت لا يترك بيانات جزئية.** I: يشغّل تقييم التنبيهات (P2-14). |
| [ ] | P3-11 | الورديات: فتح/إغلاق + فرق النقد + تقرير Z | P3-10 | A: لا بيع بدون وردية. T: دورة كاملة. I: تدقيق. |
| [ ] | P3-12 | حركات النقد (إيداع/سحب/بدون بيع) + فتح الدرج بصلاحية | P3-11, P1-08 | A: FR-POS-009. T: تجربة بـ PIN. I: تدقيق. |
| [ ] | P3-13 | المرتجعات والإلغاء (مستند تعويضي) + إعادة المخزون | P3-10 | A: لا يتجاوز الكمية المتبقية القابلة للاسترجاع. T: استرجاع جزئي. I: يعيد حركات المخزون ويدقّق. |
| [ ] | P3-14 | السلال المعلّقة والاستدعاء | P3-03 | A: FR-POS-007. T: تعليق/استدعاء + إعادة تسعير اختيارية. I: —. |
| [ ] | P3-15 | العملاء (الحد الأدنى): كيان + اختيار عميل في السلة | P3-04 | A: ملف عميل بسيط. T: ربط عميل بسلة. I: يُوسَّع في P6-04. |
| [ ] | P3-16 | البيع الآجل مع فحص حد الائتمان وPIN المدير | P3-15, P3-10 | A: FR-POS-006. T: تجاوز الحد. I: يكتب `customer_ledger` بنفس المعاملة. **(بوابة G3)** |

**بوابة G3:** دورة بيع كاملة (فتح وردية → بيع نقدي ومقسّم وآجل → مرتجع → إغلاق وردية) تعمل بدون اتصال وبدون أخطاء، وكل خطوة مدقَّقة.

### Phase 4 — الطباعة والمستندات

| ☐ | ID | الخطوة | تعتمد على | A / T / I |
|---|---|---|---|---|
| [ ] | P4-01 | نموذج قالب الإيصال (شعار، ترويسة، تذييل، حقول مخصصة) | P3-10 | A: 58 و80 مم. T: معاينة. I: يقرأ business_profile. |
| [ ] | P4-02 | إيصال PDF ومشاركة | P4-01 | A: نسخة «COPY» عند إعادة الطباعة. T: golden. I: —. |
| [ ] | P4-03 | مولّد بايتات ESC/POS | P4-01 | A: يطابق القالب. T: اختبار بايتات. I: —. |
| [ ] | P4-04 | الوضع النقطي (Raster) للعربية | P4-03 | A: عربي سليم بدون اعتماد على code page. T: طباعة فعلية. I: —. |
| [ ] | P4-05 | `TcpTransport` (المنفذ 9100) | P4-03 | A: إرسال وإعادة محاولة. T: طابعة شبكية/محاكي. I: —. |
| [ ] | P4-06 | `BluetoothTransport` | P4-03 | A: اقتران واتصال. T: طابعة فعلية. I: واجهة `PrinterTransport` موحّدة. |
| [ ] | P4-07 | `UsbTransport` | P4-03 | A: Android USB / سطح مكتب. T: طابعة فعلية. I: خدمة القدرات تخفيه إن غير مدعوم. |
| [ ] | P4-08 | `PrinterManager`: طابور + إعادة محاولة + حالة + طباعة اختبار | P4-05 | A: فشل الطباعة لا يلغي البيع. T: فصل الطابعة أثناء الطباعة. I: يتكامل مع P3-10 (طابور إعادة الطباعة). |
| [ ] | P4-09 | نبضة فتح درج النقود عبر الطابعة | P4-08, P3-12 | A: بصلاحية. T: درج فعلي. I: تدقيق. |
| [ ] | P4-10 | شاشة إعدادات الطابعات | P4-08 | A: إضافة/اختبار/افتراضي. T: تجربة. I: مخزّنة في settings. **(بوابة G4)** |

### Phase 5 — النسخ الاحتياطي والأمان والإعدادات (بوابة MVP)

| ☐ | ID | الخطوة | تعتمد على | A / T / I |
|---|---|---|---|---|
| [ ] | P5-01 | صيغة ملف النسخة (بيان + مجموع تحقق + إصدار مخطط) | P0-13 | A: AES-256-GCM على دفعات 64KiB. T: اختبار وحدة. I: مفتاح منفصل من عبارة المرور. |
| [ ] | P5-02 | إنشاء النسخة (Checkpoint لـ WAL + تشفير + تحقق بإعادة القراءة) | P5-01 | A: FR-SEC-004. T: نسخة فعلية. I: تدقيق + تجزئة نقطة التحقق في البيان. |
| [ ] | P5-03 | الاستعادة (تحقق + ملخص + نسخة أمان + استبدال) | P5-02 | A: FR-SEC-005؛ تعيد بيانات مطابقة. T: **عبارة مرور خاطئة تفشل بسلاسة؛ نسخة أحدث إصدارًا مرفوضة.** I: ربط سلسلة التدقيق الجديدة بآخر تجزئة. |
| [ ] | P5-04 | الجدولة التلقائية + سياسة الاحتفاظ + مؤشر صحة النسخ | P5-02 | A: يومي وعند إغلاق الوردية. T: محاكاة مرور الوقت. I: يعمل بعد P3-11. |
| [ ] | P5-05 | عارض سجل التدقيق (مرشحات) + شاشة فحص السلامة | P0-16, P1-09 | A: FR-AUD-006. T: تجربة. I: مالك/محاسب فقط. |
| [ ] | P5-06 | تصدير التدقيق CSV/PDF | P5-05 | A: التصدير نفسه مسجَّل. T: تجربة. I: —. |
| [ ] | P5-07 | حماية الشاشة (FLAG_SECURE + تمويه مبدّل التطبيقات) | P1-09 | A: على الشاشات الحساسة. T: لقطة شاشة تفشل. I: قابل للضبط. |
| [ ] | P5-08 | تنظيف التسجيل + فحص CI يمنع أي عميل `http` | P0-08 | A: يفشل CI عند وجود شبكة. T: إضافة تجريبية. I: —. |
| [ ] | P5-09 | تحذير الأجهزة المعدَّلة (Root/Jailbreak) | P1-04 | A: إقرار المالك + تدقيق. T: محاكاة. I: —. |
| [ ] | P5-10 | لوحة معلومات أساسية: إيرادات، COGS، إجمالي الربح (الربح محمي بـ PIN) | P3-10, P1-08 | A: FR-ANA-001/004. T: أرقام تطابق بيانات اختبارية. I: تقرأ من المبيعات مباشرة (ويُستبدل بالتجميع في P6-08). |
| [ ] | P5-11 | شاشة الإعدادات: النشاط، الضريبة، اللغة، الأمان، النسخ، الطابعات | P1-10, P4-10, P5-04 | A: صلاحية المالك. T: تجربة. I: تجمع الإعدادات المبعثرة. |
| [ ] | P5-12 | **بوابة MVP:** تدقيق شامل واختبار تكامل كامل (إعداد→بيع→مرتجع→وردية→نسخ→استعادة) | الكل | A: كل اختبارات التكامل خضراء. T: تجربة يدوية شاملة. I: مراجعة أمان: القاعدة غير مقروءة بدون مفتاح. **(بوابة G5)** |

### Phase 6 — المشتريات والعملاء والمالية

| ☐ | ID | الخطوة | تعتمد على | A / T / I |
|---|---|---|---|---|
| [ ] | P6-01 | الموردون (ملف، شروط، رصيد) | P1-02 | A: CRUD. T: اختبار. I: تدقيق. |
| [ ] | P6-02 | أوامر الشراء ودورة حياتها | P6-01, P2-02 | A: مسودة→مرسل→مستلَم جزئيًا→مستلَم/ملغى. T: دورة كاملة. I: PDF لأمر الشراء. |
| [ ] | P6-03 | الاستلام: تحديث المخزون والمتوسط المرجّح والتنبيه عند تغيّر التكلفة | P6-02, P2-10 | A: FR-PUR-003. T: اختبارات خصائص للتكلفة. I: حركات مخزون + تدقيق. |
| [ ] | P6-04 | العملاء الكاملون: دفتر العميل وكشف الحساب | P3-15 | A: FR-CUS-001/002. T: كشف PDF. I: يوسّع P3-15 دون كسره. |
| [ ] | P6-05 | تسديد الدفعات وتوزيعها (الأقدم أولًا أو محدد) | P6-04 | A: FR-CUS-003. T: حالات حدّية. I: `customer_ledger` للإضافة فقط. |
| [ ] | P6-06 | نقاط الولاء (مفتاح ميزة) | P6-04, P1-12 | A: FR-CUS-004. T: كسب/استبدال. I: يُخفى عند إيقاف الميزة. |
| [ ] | P6-07 | المصروفات والقوالب المتكررة | P1-02 | A: تغذّي صافي الربح. T: مصروف متكرر. I: —. |
| [ ] | P6-08 | جدول التجميع `daily_sales_summary` يُحدَّث داخل معاملة البيع | P3-10 | A: يطابق الحساب المباشر. T: مقارنة تلقائية. I: يُحدَّث أيضًا عند المرتجع. |
| [ ] | P6-09 | لوحات المعلومات الكاملة (ربح صافٍ، تدفق نقدي، مبيعات حسب البعد، مقارنة فترات) | P6-08, P6-07 | A: FR-ANA-001/002. T: أقل من ثانيتين لسنة بيانات. I: يستبدل P5-10 مع بقاء الصلاحيات. |
| [ ] | P6-10 | التقارير CSV (كل تقارير PRD القسم 3.8) | P6-09 | A: تطابق إجماليات بيانات مرجعية. T: تصدير فعلي. I: كل تصدير مدقَّق. |
| [ ] | P6-11 | التقارير PDF وكشوف الحساب | P6-10 | A: عربي/إنجليزي. T: golden. I: —. **(بوابة G6)** |

### Phase 7 — أنماط الصناعات

| ☐ | ID | الخطوة | تعتمد على | A / T / I |
|---|---|---|---|---|
| [ ] | P7-01 | الصيدلية: الدفعة والصلاحية إلزاميان + FEFO إجباري | P2-10, P1-12 | A: لا بيع بدون دفعة. T: بيع دواء. I: عبر مفتاح الميزة فقط. |
| [ ] | P7-02 | الصيدلية: علم «يلزم وصفة» + تسجيل الطبيب/المريض مشفّرًا | P7-01 | A: FR-CFG-004. T: بيع بوصفة. I: مرئي بصلاحية فقط. |
| [ ] | P7-03 | الصيدلية: سجل المواد الخاضعة للرقابة + تقريره | P7-02 | A: سجل للإضافة فقط. T: تقرير. I: تدقيق. |
| [ ] | P7-04 | المطعم: الطاولات والحسابات المفتوحة | P3-10, P1-12 | A: حساب مفتوح لكل طاولة. T: تجربة. I: لا يكسر البيع العادي. |
| [ ] | P7-05 | المطعم: الإضافات (Modifiers) والبقشيش | P7-04 | A: تظهر في الإيصال. T: تجربة. I: —. |
| [ ] | P7-06 | المطعم: الوصفات وخصم المكونات من المخزون | P7-04, P2-08 | A: بيع طبق يخصم المكونات. T: اختبار حركات. I: دفتر المخزون. |
| [ ] | P7-07 | المطعم: طابعة المطبخ وتقسيم الفاتورة | P7-04, P4-08 | A: FR-POS-015. T: تجربة. I: مدير الطابعات. |
| [ ] | P7-08 | الإلكترونيات: الرقم التسلسلي عند البيع + الضمان | P2-11, P3-10 | A: رقم لكل سطر. T: بيع/مرتجع. I: دورة الأرقام. |
| [ ] | P7-09 | الخدمات: تذاكر الصيانة وحالاتها | P7-08 | A: مسار حالات. T: تجربة. I: —. |
| [ ] | P7-10 | الجملة: تحويل الوحدات والحد الأدنى للطلب | P2-04, P2-01 | A: بيع بالكرتونة. T: اختبارات تسعير. I: —. |
| [ ] | P7-11 | الجملة: التسعير بالشرائح في POS | P7-10, P3-04 | A: السعر يتبع الشريحة. T: تجربة. I: —. **(بوابة G7)** |

### Phase 8 — الذكاء الاصطناعي على الجهاز

| ☐ | ID | الخطوة | تعتمد على | A / T / I |
|---|---|---|---|---|
| [ ] | P8-01 | محمّل النماذج (بيان + SHA-256 + تحقق عند أول استخدام) | P0-01 | A: نموذج تالف يُرفض. T: تعديل بايت. I: يعمل بدون اتصال. |
| [ ] | P8-02 | مشغّل Isolates + التقدّم | P8-01 | A: لا تجميد للواجهة. T: مهمة طويلة. I: عبر `AsyncNotifier`. |
| [ ] | P8-03 | خدمة القدرات `DeviceCapabilities` (كاميرا، بلوتوث…) | P0-01 | A: تتراجع الميزات بسلاسة. T: محاكاة غياب القدرة. I: تستهلكها كل الميزات الاختيارية. |
| [ ] | P8-04 | المعالجة المسبقة للصورة (قص، تعديل ميل، عتبة) | P8-02 | A: تحسّن الجودة على عينات. T: عينات. I: —. |
| [ ] | P8-05 | محرك OCR اللاتيني (ML Kit) خلف `InvoiceOcrEngine` | P8-04 | A: صناديق كلمات صحيحة. T: فواتير اختبارية. I: واجهة قابلة للاستبدال. |
| [ ] | P8-06 | محرك OCR العربي (Tesseract/ONNX) + `OcrEngineRouter` | P8-05 | A: اختيار المحرك بحسب اللغة/المنصة. T: فواتير عربية. I: —. |
| [ ] | P8-07 | محلل التخطيط والجداول (تجميع الصفوف واكتشاف الأعمدة) | P8-06 | A: بنود صحيحة على مجموعة الاختبار. T: قياس الدقة. I: —. |
| [ ] | P8-08 | استخراج الحقول (المورد، الرقم، التاريخ، الإجماليات) + التحقق الحسابي + كشف التكرار | P8-07 | A: FR-OCR-004/006. T: حالات تناقض. I: —. |
| [ ] | P8-09 | مطابقة البنود بالمنتجات (باركود/SKU/ذاكرة/تقريبي) | P8-08, P2-03 | A: FR-OCR-002. T: اختبارات تقريب. I: يقرأ `supplier_product_map`. |
| [ ] | P8-10 | واجهة المراجعة جنبًا إلى جنب (إلزامية) | P8-09 | A: FR-OCR-003؛ لا كتابة قبل التأكيد. T: تجربة. I: صلاحية المخزون. |
| [ ] | P8-11 | من مسودة الفاتورة إلى أمر شراء مستلَم + حفظ الصورة مشفّرة | P8-10, P6-03 | A: FR-OCR-005. T: دورة كاملة. I: يستخدم الاستلام الموجود دون نسخ منطقه. |
| [ ] | P8-12 | تعلّم الربط من تصحيحات المستخدم | P8-11 | A: المسح الثاني أدق. T: مسحان لنفس المورد. I: —. |
| [ ] | P8-13 | نماذج التنبؤ (متوسط متحرك، موسمي، Holt-Winters، Croston) | P6-08 | A: تُختار حسب طول التاريخ. T: بيانات اصطناعية. I: خلف `DemandForecaster`. |
| [ ] | P8-14 | الاختبار الرجعي (Backtest) واختيار النموذج + تخزين `forecasts` | P8-13 | A: MAPE/MASE مسجَّلة. T: قياس. I: تُخفى أيام نفاد المخزون. |
| [ ] | P8-15 | شاشة التنبؤ + حالة «جارٍ التعلّم» (أقل من 14 يومًا) | P8-14 | A: FR-ANA-005/008. T: بيانات قليلة وكثيرة. I: —. |
| [ ] | P8-16 | توصيات إعادة الطلب وتحويلها لمسودات أوامر شراء مجمّعة | P8-14, P6-02 | A: FR-ANA-006. T: توصية→PO. I: يستخدم أوامر الشراء الموجودة. |
| [ ] | P8-17 | رؤى الهامش المرتفع والأصناف دون الهامش المستهدف | P6-09 | A: FR-ANA-007. T: بيانات اختبارية. I: محمية بصلاحية الربح. |
| [ ] | P8-18 | `ProductEmbedder` (TFLite) + مصفوفة المطابقة بجيب التمام | P8-01, P8-02 | A: أفضل 3 نتائج. T: عينات. I: —. |
| [ ] | P8-19 | تسجيل المنتج بالصور المرجعية وتخزين التمثيلات مشفّرة | P8-18, P2-05 | A: FR-AI-001/005. T: تسجيل 5 صور. I: يُضاف في شاشة المنتج دون تغيير بنيتها. |
| [ ] | P8-20 | التعرف في POS (التقاط عند النقر، تأكيد بنقرة، التغذية الراجعة) | P8-19, P3-04 | A: FR-AI-002/003/004؛ لا إضافة تلقائية دون تأكيد. T: تجربة. I: يتراجع للباركود عند غياب الكاميرا. **(بوابة G8)** |

### Phase 9 — الجاهزية للإصدار

| ☐ | ID | الخطوة | تعتمد على | A / T / I |
|---|---|---|---|---|
| [ ] | P9-01 | اختبارات الأداء (100 ألف منتج / مليون سطر بيع) مقابل ميزانيات NFR-02/03/09 | الكل | A: تحقق الأهداف. T: حزمة القياس. I: تُفرض في CI. |
| [ ] | P9-02 | تدقيق إمكانية الوصول (WCAG AA، أهداف لمس 48dp) | الكل | A: بلا مخالفات حرجة. T: فحص يدوي. I: —. |
| [ ] | P9-03 | مراجعة التوطين مع متحدثين أصليين (عربي/إنجليزي، RTL) | P0-09 | A: لا جمل مركّبة بالدمج. T: مراجعة. I: —. |
| [ ] | P9-04 | مراجعة أمان على نمط OWASP MASVS + فحص النصوص الصريحة في ملف القاعدة | الكل | A: لا نصوص حساسة. T: سكربت. I: —. |
| [ ] | P9-05 | تغليف الإصدارات (Android/Windows) + تعتيم الكود | الكل | A: بناء إصدار يعمل. T: تثبيت نظيف. I: —. |
| [ ] | P9-06 | وثائق المستخدم وإرشاد النسخ الاحتياطي وفقدان المفتاح | الكل | A: واضحة وكاملة. T: مراجعة. I: —. |
| [ ] | P9-07 | تمرين استعادة البيانات الكامل على جهاز جديد | P5-03 | A: استعادة ناجحة. T: جهاز نظيف. I: —. **(بوابة G9)** |

---

## 6. سجل التغييرات (Change Log)

> أضف سطرًا جديدًا في الأعلى مع كل نقل حالة. الصيغة: `التاريخ | الموديل | الخطوة | الإجراء | commit`

| التاريخ | الموديل | الخطوة | الإجراء | commit |
|---|---|---|---|---|
| 2026-10-19 | Big Pickle | `P2-06` | **البحث السريع FTS5 + ترقيم Keyset وترحيل v9:** جدول افتراضي `product_search` بـ`FTS5` (في `.drift`، مفتاحه `rowid` جدول `products`، ونسخة الاسم داخله) مع تمكين وحدة `fts5` في `build.yaml` وثلاثة مشغّلات `CREATE TRIGGER IF NOT EXISTS` على `products` تُنشأ بـ`customStatement`، وتعبئة أولية عند الوصول إلى v9، و**تسامح غياب FTS5** (`_ensureProductSearchIndex` تُرجع خطأً صامتًا + تحذير فينزل البحث إلى `LIKE` مُهرَّب — بديل `P0-11` الدفاعي)؛ **Keyset لا `OFFSET`** على `(name, id)` بقراءة `limit + 1`، والباركود يُطابق بمدى على الفهرس الفريد `barcodes.code` (الأكواد الحيّة فقط) مع `LIMIT 1` فلا تكرار، والقراءة على مرحلتين عبر `productFromRow` المشترك؛ `SearchProducts` (افتراضي 20، سقف 50، الفارغ بلا رحلة للقاعدة) + `RebuildProductSearchIndex`؛ **عيبان كشفتهما الاختبارات:** تصحيح دلالة المؤشر (آخر صف مُعاد لا الزائد)، واستبدال `EXISTS` المترابط بـ`IN` على فهرس الباركود (164ms → 2ms)؛ القياس على 50 000 SKU: **44ms/2ms/2ms**؛ لقطة `drift_schema_v9.json` + اختبار ترحيل بأربع عشرة حالة؛ **إصلاح تكامل** واحد (الوحدة الافتراضية، القسم 7) — كل الفحوص خضراء (format 279 ملفًا بلا تغيير، analyze نظيف، boundaries تعبر، 642/642) | _(لم يُلتزم بعد)_ |
| 2026-10-15 | Big Pickle | `P2-05` | **شاشات المنتجات (قائمة/تفاصيل/نموذج) وربط وجهة المنتجات:** أول خطوة واجهة في `features/catalog/presentation/` — قائمة كسولة بتصفية في الذاكرة وحالة فارغة، وتفاصيل تجمع المنتج وأشرطة `P2-04` وباركودات `P2-03` مع إبراز المعطَّل بلا إخفاء، ونموذج واحد للإنشاء والتعديل يكتب **حصريًا** عبر `CreateProduct`/`UpdateProduct`؛ **قرار محوري: بوابة السعر في `ProductView.from(showPrices:)`/`TierPriceView.from(showPrices:)`** فتُفرَّغ حقول النقود قبل وصولها لأي widget، و**دور المخزون يعدّل بلا تسعير** بحمل السعر المخزَّن كما هو وقت الحفظ، وإجراء الإنشاء لا يُعرض إلا لمن يملك `canManageProducts` و`canViewPrices` معًا؛ ربط `router.dart` بالوجهة وبمساري `/products/new` و`/products/:id/edit` بلا تصدير واجهة في البرميل؛ نحو 55 مفتاح ARB في اللغتين؛ 21 اختبارًا جديدًا + **إصلاح تكامل** واحد في `app_router_test.dart` (القسم 7) — كل الفحوص خضراء (format 269 ملفًا بلا تغيير، analyze نظيف، boundaries تعبر، 609/609) | _(لم يُلتزم بعد)_ |
| 2026-10-15 | Big Pickle | `P2-04` | **شرائح الأسعار واختيار السعر وترحيل v8:** مخطط Drift v7 → v8 بجدول `price_tiers` (مرجع إلى `products.id`، وشريحة بكود نصي ثابت، و`minQuantityThousandths` بصورته الصحيحة لبداية الشريحة، و`priceMinorUnits` بأصغر وحدة، وتعطيل منطقي) مع **قيد `UNIQUE` على `(productId, tier, minQuantityThousandths)`** عبر `uniqueKeys`، ولقطة `drift_schema_v8.json` + `schema_v8.dart` + اختبار ترحيل بإحدى عشرة حالة؛ ومجال `features/catalog` (Enum `PriceTier` + كيان `TierPrice` + تحقق + واجهة مستودع) وخمس حالات استخدام ومستودع Drift يفحص المنتج والتكرار **داخل** المعاملة؛ **خدمة اختيار السعر النقية `PriceSelector`**: تفوز الشريحة المطبَّقة الأقرب فتتراكم الأشرطة، وغياب الشريحة/تعطيلها/الكمية الأقل من أصغر شريحة ترجع إلى سعر المنتج (لا إلى المجان)، والعملة تُقرأ ولا تُخزَّن؛ 58 اختبارًا جديدًا — كل الفحوص خضراء (format 255 ملفًا بلا تغيير، analyze نظيف، boundaries تعبر، 588/588) | _(لم يُلتزم بعد)_ |
| 2026-10-15 | Big Pickle | `P2-03` | **الباركود وترحيل v7:** مخطط Drift v6 → v7 بجدول `barcodes` (كود `UNIQUE` على مستوى القاعدة يمتد إلى الصفوف المعطَّلة، ومرجع إلى `products.id`، ومضاعِف `multiplierThousandths` بصورته الصحيحة، وتعطيل منطقي) مع لقطة `drift_schema_v7.json` + `schema_v7.dart` + اختبار ترحيل بتسع حالات؛ ومجال `features/catalog` (كيان الباركود بمضاعِف `Quantity` + تحقق + واجهة مستودع) وأربع حالات استخدام ومستودع Drift يفحص المنتج والتكرار **داخل** المعاملة؛ **رفض التكرار برابط للموجود (FR-INV-011)** عبر `alreadyLinkedCode` ثم `readByCode`/`FindBarcodeByCode` التي تُعيد المنتج المالك، بلا نوع فشل جديد لأن `Failure` هرمية `sealed` بأنواع `final`؛ 37 اختبارًا جديدًا — كل الفحوص خضراء (format 238 ملفًا بلا تغيير، analyze نظيف، boundaries تعبر، 530/530) | _(لم يُلتزم بعد)_ |
| 2026-10-15 | Big Pickle | `P2-02` | **جدول المنتجات ومستودعه وترحيل v6:** مخطط Drift v5 → v6 بجدول `products` (نوع بكود نصي ثابت + تصنيف + وحدة مخزون + وحدة شراء اختيارية + سعر بيع/تكلفة بأصغر وحدة صحيحة + حد إعادة طلب + تعطيل منطقي)، مع `@ReferenceName` على مرجعَي `units.code` لإزالة تحذير Drift الحقيقي بتكرار `productsRefs`، ولقطة `drift_schema_v6.json` + `schema_v6.dart` + اختبار ترحيل بسبع حالات؛ ومجال `features/catalog` (نوع/كيان/تحقق/واجهة مستودع) وأربع حالات استخدام ومستودع Drift بكتابة ذرّية مدقَّقة تفحص المراجع داخل المعاملة؛ **قرار محوري: لا عمود للعملة** — تُقرأ من ملف النشاط عند كل قراءة بلا تخزين مؤقت وتسقط إلى `USD` عند التلف؛ **وتدقيق صريح لتغيير السعر/التكلفة** بزوج «قبل/بعد»؛ **إصلاح تكامل**: برميل `lib/features/settings/settings.dart` ليصل `catalog/data` إلى `LoadBusinessProfile` دون خرق الحدود؛ 43 اختبارًا جديدًا — كل الفحوص خضراء (format 226 ملفًا بلا تغيير، analyze نظيف، boundaries تعبر، 498/498) | _(لم يُلتزم بعد)_ |
| 2026-10-15 | Big Pickle | `P2-01` | **التصنيفات (شجرة) والوحدات وتحويلها:** مخطط Drift v4 → v5 بجدولَي `categories` (شجرة بالمرجع الذاتي + `sortOrder` + تعطيل منطقي) و`units` (مرجع ذاتي `baseUnitCode` + `factorThousandths` صحيح: كرتونة = 12000 جزء من قطعة) + لقطة `drift_schema_v5.json` + `schema_v5.dart` + اختبار ترحيل بخمس حالات (v3→v5، v4→v5، تثبيت جديد، بقاء حرّاس التدقيق، وجود الجدولين)؛ ومجال `features/catalog` (كيانان + شجرة + محوّل وحدات نقي + واجهتا مستودع) وسبع حالات استخدام ومستودعا Drift بكتابة ذرّية مدقَّقة ومزوّدات وبرميل؛ **إصلاح تكامل**: `Quantity.multiplyRatio` في `core/money` بنفس منطق `Money.multiplyRatio` بلا تكرار؛ 46 اختبارًا جديدًا — كل الفحوص خضراء (format 210 ملفًا بلا تغيير، analyze نظيف، boundaries تعبر، 455/455) | _(لم يُلتزم بعد)_ |
| 2026-10-13 | Big Pickle | `DAY-1` | **إغلاق اليوم الأول نهائيًا:** تأكيد المستخدم بمشاهدة واجهات نظام التصميم على المحاكي (تحقّق T مكتمل)؛ ثبات `[DONE]` لـ `P0-01` و`P0-05` و`DAY-1` | _(لم يُلتزم بعد)_ |
| 2026-10-13 | Big Pickle | `P0-05` + `DAY-1` | إنجاز `core/result` (Result/Failure) + نظام التصميم (Theme + CustomButton/CustomTextField/CustomCard) + تهيئة Riverpod + نظام الأخطاء والمسجّل العام + شاشة عرض نظام التصميم؛ نقل `P0-05` و`DAY-1` إلى `[DONE]` ونقل `P0-02` إلى `[IN-PROGRESS]` | _(لم يُلتزم بعد)_ |
| 2026-10-13 00:54 | Copilot SDK | `P0-01` | إنشاء مشروع Flutter وهيكل المجلدات والنكهات + اختبار دخان | `4452c32` |
| 2026-10-13 | Big Pickle | `P0-02`…`P0-08` | **اليوم الثاني:** تحليل صارم + `tool/check_boundaries.dart` + CI + `AGENTS.md` + `core/money` (Money/Rate/Quantity/Tax/Formatter) + `core/utils` (Clock/UUIDv7/ربط الساعة بالمسجّل)؛ نقل رموز التصميم إلى `lib/shared/design` لاحترام الحدود؛ كل الفحوص خضراء (analyze نظيف، boundaries تعبر، 115/115 اختبارًا) | _(لم يُلتزم بعد)_ |
| 2026-10-13 | Big Pickle | `P0-09`…`P0-10` | التوطين الكامل (ARB ar/en، RTL، مبدّل اللغة، مفاتيح رسائل الأخطاء) + التوجيه `go_router` مع قالب متكيّف (شريط سفلي للهاتف / جانبي للتابلت وسطح المكتب) + شاشة `/dev` لملعب Money/Tax؛ كل الفحوص خضراء (analyze نظيف، boundaries تعبر، 122/122 اختبارًا) | _(لم يُلتزم بعد)_ |
| 2026-10-13 | Big Pickle | بحث المنتجات (تكملة `P0-10`) | ربط خانة البحث بفلترة حيّة لقائمة منتجات تجريبية داخل الواجهة (`lib/app/shell/demo_product.dart` + بحث بالاسم/الباركود في `_DesignSystemDemo`) + مفاتيح ARB (`searchResultsCount`/`searchNoResults`/`demoProduct*`)؛ كل الفحوص خضراء (analyze نظيف، boundaries تعبر، 127/127 اختبارًا) | _(لم يُلتزم بعد)_ |
| 2026-10-13 | Big Pickle | `P0-11` | استكشاف SQLite/SQLCipher/FTS5: `SQLITE_VERSION=3.53.4`، `cipher_version` فارغ على المضيف، FTS5 مدعوم؛ القرار: FTS5 للبحث + اتصال قاعدة بيانات قابل للحقن (SQLCipher في بناء التطبيق فقط)؛ التوثيق في `docs/P0-11_sqlite_spike.md` | _(لم يُلتزم بعد)_ |
| 2026-10-13 | Big Pickle | `P0-12` | قاعدة البيانات المحلية: `AppDatabase` (Drift) + `DatabaseConnector` (اتصال قابل للحقن) + PRAGMA (WAL/foreign_keys/secure_delete) + جدول `app_settings` + مغلّف SQLCipher للإنتاج؛ التحقق على المضيف بـ SQLite عادي ونقل شروط التشفير إلى تشغيل الجهاز؛ كل الفحوص خضراء (analyze نظيف، boundaries تعبر، 129/129 اختبارًا) | _(لم يُلتزم بعد)_ |
| 2026-10-13 | Big Pickle | `P0-13` | أساس الأمان: `KeyManager` (Argon2id → KEK + DEK عشوائي 32 بايت + تغليف AES-GCM) + `SecureStore` قابل للحقن (ذاكرة للاختبار، `flutter_secure_storage` للتطبيق)؛ رفض كلمة المرور الخاطئة، تغيير كلمة المرور يعيد تغليف نفس DEK فقط؛ كل الفحوص خضراء (analyze نظيف، boundaries تعبر، 135/135 اختبارًا) | _(لم يُلتزم بعد)_ |
| 2026-10-13 | Big Pickle | `P0-14` | وحدة العمل: `UnitOfWork` + `DriftUnitOfWork` (معاملة Drift واحدة تغلّف المستودعات)؛ اختبار تثبيت الكتابة عند النجاح وتراجع كامل عند الاستثناء؛ كل الفحوص خضراء (analyze نظيف، boundaries تعبر، 137/137 اختبارًا) | _(لم يُلتزم بعد)_ |
| 2026-10-13 | Big Pickle | `P0-15` | سجل التدقيق: جدول `audit_log` (v2) + Triggerان يمنعان UPDATE/DELETE (append-only) + `AuditService.append` بسلسلة تجزئة SHA-256 داخل `UnitOfWork`؛ كل الفحوص خضراء (analyze نظيف، boundaries تعبر، 142/142 اختبارًا) | _(لم يُلتزم بعد)_ |
| 2026-10-13 | Big Pickle | `P0-16` | فحص سلامة سجل التدقيق: `verifyChain()` يكشف أول حلقة مكسورة + `checkpoint()` ونقاط التحقق (`audit_checkpoints`، v3) + Triggers تمنع تعديلها؛ اختبارات عبث بخمس حالات؛ بوابة G0 مكتملة؛ كل الفحوص خضراء (analyze نظيف، boundaries تعبر، 146/146 اختبارًا) | _(لم يُلتزم بعد)_ |
| 2026-10-13 | Big Pickle | `DAY-3` | **ربط واجهات المستخدم بقاعدة البيانات (حفظ وتحديث حي):** ميزة الإعدادات على جدول `app_settings` (ملف النشاط + العملة + المظهر + اللغة) عبر حالات استخدام + `UnitOfWork` + تدقيق؛ استعادة المظهر واللغة قبل أول إطار في `bootstrap`؛ تحويل مسار `settings` إلى شاشة حقيقية؛ ملفات جديدة تحت `lib/features/settings/**` و`lib/core/database/database_providers.dart`؛ 19 اختبارًا جديدًا؛ كل الفحوص خضراء (analyze نظيف، boundaries تعبر، 180/180 اختبارًا) | _(لم يُلتزم بعد)_ |
| 2026-10-13 | Big Pickle | `P0-15`/`P0-16` (إصلاح تكامل) | **إصلاح كامن في سلسلة التدقيق:** تطبيع الطابع الزمني إلى ثوانٍ صحيحة داخل `AuditService` قبل التجزئة والتخزين (`_toWholeSeconds`) لأن Drift يخزّن `DateTime` كثوانٍ صحيحة؛ كان `verifyChain` يُبلّغ عن عبث وهمي مع أي ساعة نظام حقيقية؛ أُضيف اختبار انحدار؛ كل الفحوص خضراء (180/180) | _(لم يُلتزم بعد)_ |
| 2026-10-13 | Big Pickle | `EXTRA-HWID` | وحدة الترخيص المحلي: بصمة الجهاز HWID + مفاتيح ترخيص موقّعة Ed25519 تُتحقق محليًا (بدون شبكة) + تخزين آمن للمفتاح؛ واستخراج `encodeCanonicalJson` كأداة مشتركة بين سلسلة التدقيق والتوقيع | _(لم يُلتزم بعد)_ |
| 2026-10-13 | Big Pickle | `P1-01` | **الصلاحيات ومصفوفة الأدوار:** تعداد `Permission` مغلق (31 صلاحية بأكواد ثابتة) + `UserRole` الأربعة + واجهة `RoleMatrix` والتنفيذ الافتراضي `DefaultRoleMatrix` (تعبير `switch` شامل)؛ **اختبار لكل خلية** (124 خلية) + حرّاس؛ المصفوفة مشتقّة من المجالات الوظيفية لأن PRD غير موجود في المستودع (مؤقتة بانتظار المصادقة، موثّقة في `docs/P1-01_permissions.md`)؛ كل الفحوص خضراء (analyze نظيف، boundaries تعبر، 318/318 اختبارًا) | _(لم يُلتزم بعد)_ |
| 2026-10-13 | Big Pickle | `P1-02` | **جداول المستخدمين والأدوار والترحيل الأول:** مخطط Drift v3 → v4 (`roles` و`users` بتعطيل منطقي بلا حذف نهائي) + استحداث آلية لقطات المخطط (`drift_schemas/`) واختبار ترحيل حقيقي؛ مستودعان (`DriftRoleRepository`, `DriftUserRepository`) وست حالات استخدام بقراءة/إنشاء/تعطيل فقط، وكل كتابة داخل `UnitOfWork` مع سطر تدقيق في نفس المعاملة؛ كل الفحوص خضراء (analyze نظيف، boundaries تعبر، 358/358 اختبارًا) | _(لم يُلتزم بعد)_ |
| 2026-10-14 | Big Pickle | `P1-03` | **خدمة تجزئة كلمة المرور وPIN (Argon2id):** واجهة نقية `PasswordHasher` في `domain` + تنفيذ `Argon2PasswordHasher` في `data` بصيغة PHC: `$argon2id$v=19$m=16384,t=2,p=1$<salt>$<digest>` (ملح عشوائي 16 بايت، مقارنة بزمن ثابت، رفض السر الفارغ، وفصل «كلمة خاطئة» عن «قيمة تالفة»)؛ عايرة الزمن على 16 MiB/جولتين = 231–313ms عبر مسبار مؤقّت حُذف بعد القياس؛ مزوّد `passwordHasher`؛ 11 اختبارًا جديدًا؛ كل الفحوص خضراء (analyze نظيف، boundaries تعبر، 369/369 اختبارًا) | _(لم يُلتزم بعد)_ |
| 2026-10-14 | Big Pickle | `P1-04` | **جلسة المستخدم (`sessionProvider`):** `SessionState` نقي في `domain` (المستخدم/الدور/الوردية/القفل) + مزوّد `Session` بعمليات صريحة (دخول/خروج/قفل/وردية) يستبدل الحالة كاملة ويرفض الحساب المعطّل؛ `sessionPermissions` مشتقّة **حيًّا** من `RoleMatrix` فلا صلاحية قديمة؛ القفل يُبطل الجلسة مع إبقاء الحساب لتبديل سريع (`P1-07`)؛ **أول برميل للميزة** `lib/features/auth/auth.dart`؛ 9 اختبارات جديدة؛ كل الفحوص خضراء (analyze نظيف، boundaries تعبر، 378/378 اختبارًا) | _(لم يُلتزم بعد)_ |
| 2026-10-14 | Big Pickle | `P1-05` | **شاشة الدخول (كلمة مرور / PIN):** حالة استخدام `SignIn` نقية تُعيد `Result<User>` جاهزًا لـ`Session.signIn`، برمز واحد للمستخدم المجهول والسر الخاطئ (لا تسريب وجود الحساب) وبترتيب أمني يفحص السر قبل الإبلاغ عن التعطيل؛ حقل سر واحد يفحص `passwordHash` ثم `pinHash`؛ مزوّد `signInProvider`؛ **أول ملف في `presentation/` للميزة** `LoginScreen` بحقن `onSignedIn` فحافظ على حدود الطبقات؛ مسار مؤقّت `/login` بلا حرّاس (الحرّاس `P1-09`)؛ 12 مفتاح ARB (ar/en)؛ 14 اختبارًا جديدًا؛ كل الفحوص خضراء (analyze نظيف، boundaries تعبر، 392/392 اختبارًا). **غير مُنفَّذ بمُعلن:** ربط `KeyManager` وكتابة الكريدنشال والتجربة اليدوية (`P1-10`/`P1-11`) | _(لم يُلتزم بعد)_ |
| 2026-10-15 | Big Pickle | `OWNER-INIT` | **تهيئة حساب المالك الأول:** بذر الأدوار المدمجة (idempotent) عبر `SeedBuiltInRoles` + حالة استخدام `InitializeOwner` (تحقق + تجزئة Argon2id + رفض وجود أي حساب سابق) + مزوّدات `allUsers`/`seedBuiltInRoles`/`initializeOwner`/`ownerSetupRequired` + شاشة `OwnerSetupScreen` (اسم دخول + سر + تأكيد) بمسار `/owner-setup` وبوابة إعادة توجيه مؤقتة (الحراس `P1-09`) والانتقال إلى نقطة البيع بعد الإنشاء؛ واستُخرج `_ErrorBanner` من `LoginScreen` إلى `ErrorBanner` مشترك في `lib/shared/widgets`؛ 7 اختبارات جديدة + **إصلاح تكامل** لستة اختبارات إقلاع قديمة (كانت تفترض أن الإقلاع يهبط على الهيكل) — كل الفحوص خضراء: analyze نظيف، boundaries تعبر، 409/409 اختبارًا. **مؤجَّل بمُعلن:** ربط DEK بكلمة المالك عبر `KeyManager.changePassword`. | _(لم يُلتزم بعد)_ |
| _(—)_ | _(—)_ | _(—)_ | إنشاء الملف | _(—)_ |

## 7. سجل مشاكل التكامل (Integration Issues Log)

> يُسجَّل هنا كل تقرير بحسب قالب القاعدة 5.

| التاريخ | الخطوة | المشكلة | السبب الجذري | الحل | اختبار الانحدار المضاف |
|---|---|---|---|---|---|
| 2026-10-13 | `DAY-1` | تغيّر واجهة `FlowApp` (أصبحت `ConsumerWidget` بلا معامل `flavor`) كسر `test/smoke_test.dart` و`test/widget_test.dart` اللذين كانا يستخدمان `FlowApp(flavor: ...)` | الانتقال من StatelessWidget إلى إدارة حالة Riverpod يتطلب قراءة النكهة من المزوّد لا تمريرها كمعامل | أُعيدت كتابة `test/smoke_test.dart` ليغلّف `ProviderScope`، وحُوِّل `test/widget_test.dart` لاختبار مزوّد الوضع الليلي | `test/smoke_test.dart` (تشغيل التطبيق) + `test/widget_test.dart` (ThemeMode) — كلها خضراء |
| 2026-10-13 | `DAY-1` | في اختبار `CustomTextField` ظهر `helperText` غير مرسوم عند وجود `errorText` | سلوك Material 3: يشارك المساعد والخطأ نفس الخانة فيُستبدل المساعد بالخطأ | فُصل الاختباران: اختبار للمساعد وآخر للخطأ | `test/shared/widgets/custom_text_field_test.dart` |
| 2026-10-13 | `DAY-1` | فشل تحليل: `Theme.maybeOf` غير موجود، و`FlutterErrorDetails.fatal` غير موجود، و`RangeError` حالة `switch` غير قابلة للوصول | اختلافات إصدار Flutter/Riverpod الحديث (Riverpod 3، Flutter 3.47) | استُبناء ألوان `AppErrorWidget` من `AppColors.light` مباشرةً دون الاعتماد على وراثة الثيم؛ إزالة `fatal` واستخدام `fatal: false` لأخطاء الإطار؛ حذف حالة `RangeError` لأنها فرع من `ArgumentError` | `flutter analyze` = No issues found |
| 2026-10-13 | `P0-15`/`P0-16` | سلسلة التدقيق كانت تُخزّن `occurred_at` بلا أجزاء ثانوية (Drift يخزّن `DateTime` كثوانٍ صحيحة) بينما يدخل التجزئة بطابع زمني كامل الدقة، فيُعيد `verifyChain` تجزئة مختلفة ويُبلّغ عن عبث وهمي مع أي ساعة نظام حقيقية | `hashEntry` استخدم `occurredAt.toUtc().toIso8601String()` بدقة كاملة، بينما Drift's default `DateTime` mapping يقتطع إلى ثوانٍ صحيحة (Unix timestamp بالأثواني) — لذلك لا يمكن للقيمة أن تعود ذهابًا وإيابًا | `AuditService._toWholeSeconds()` يطبّع الطابع الزمني في `append` **و** في `hashEntry` قبل التجزئة والتخزين، فلا يمكن لقيمة لا تعود من القاعدة أن تُنتج عبثًا وهميًا | `test/core/database/audit_chain_test.dart` → «sub-second timestamps still verify after a database round-trip» + `test/features/settings/settings_screen_test.dart` (فحص `verifyChain` بعد حفظ حقيقي عبر مزوّدات التطبيق) |
| 2026-10-13 | `P1-01` | معيار القبول «تطابق مصفوفة PRD (القسم 2) خلية بخلية» غير قابل للتحقق داخل المستودع | وثيقة PRD (والمواصفات التقنية) **مرجع خارجي** يذكره `EXECUTION_STATE.md` ولا يوجد ملف لها في المستودع؛ وقاعدة القسم 2/`AGENTS.md` تمنع التخمين عند التعارض بين الملف والواقع | أُوقفت الخطوة وأُبلغ المستخدم؛ ثم بموافقته اشتُقّت المصفوفة من المجالات الوظيفية ووُثّقت في `docs/P1-01_permissions.md` وسُجّلت صراحةً كـ«مؤقتة بانتظار مصادقة PRD» في `[DONE]` وفي القسم 5 | لا اختبار انحدار (ليست عيب كود): الحماية هي اختبارات المصفوفة (124 خلية) التي تُحدَّث عمدًا عند ربط PRD |
| 2026-10-15 | `OWNER-INIT` (P1-11) | ستة اختبارات إقلاع قديمة فشلت: `smoke_test.dart`، و`app_router_test.dart` (سلوكان)، و`home_search_test.dart` (سلوكان)، و`locale_provider_test.dart` (سلوك واحد) — كانت تتوقّع أن يفتح التطبيق على هيكل الوجهات مباشرة | التطبيق صار يفتح على `/login` (خطوة `P1-05`) وصارت بوابة المالك تحوّل التثبيت الفارغ إلى `/owner-setup`، فتغيّر سلوك الإقلاع تغيّرًا حقيقيًا مقصودًا لا عيبًا في الخطوة الجديدة | أُدخلت الاختبارات الستة إلى الهيكل كما يدخل المشغّل: `ProviderContainer` + `UncontrolledProviderScope` ثم `container.read(appRouterProvider).go(AppDestination.pointOfSale.path)` — أصغر تغيير ممكن، ولم يُلمس أي كود إنتاج | الاختبارات الستة نفسها بعد إصلاحها + `test/app/owner_setup_redirect_test.dart` للبوابة الجديدة — المجموع 409/409 |

| 2026-10-15 | `P2-01` | احتاج تحويل الوحدات ضرب كمية بنسبة صحيحة (`factorFrom / factorTo`)، ولم يكن في `Quantity` (`core/money`) سوى `operator *(int)` بينما `Money` يملك `multiplyRatio` بتقريب موحّد عبر `Rounding.divide` | لو كُتب الضرب والتقريب داخل مجال الكتالوج لتكرّر منطق التقريب الحسّاس (القاعدة 1) ولاختلف سلوك `Quantity` عن `Money` في الحالات الحدّية | أُضيف `Quantity.multiplyRatio(int numerator, int denominator, {RoundingMode mode = RoundingMode.halfUp})` **بأقل تغيير ممكن**: نفس حارس المقسوم عليه، ونفس `BigInt`، ونفس `Rounding.divide` المستخدم في `Money.multiplyRatio`، ولم يُلمس أي سلوك قائم في `Quantity` | ستة اختبارات جديدة في `test/core/money/quantity_test.dart` (حالة التحويل كرتونة→قطعة، التقريب نصف لأعلى، الأوضاع الثلاثة الأخرى، التناظر حول الصفر، الدقة الكبيرة حيث يخفق `double`، ورفض مقسوم عليه غير موجب) + `test/features/catalog/domain/unit_converter_test.dart` — المجموع 455/455 |
| 2026-10-15 | `P2-02` | احتاج مستودع المنتجات معرفة **عملة المتجر** ليحوّل أصغر وحدة مخزَّنة إلى `Money`، ولم يكن هناك باب معتمد للوصول إلى `SettingsRepository` من `features/catalog/data/` (الوصول بين الميزات مسموح فقط عبر برميل `features/<other>/<other>.dart` أو طبقة `domain/`) | ميزة `settings` لم يكن لها برميل، بينما `core/database` لا يعرف العملة و`catalog` لا يجوز أن يستورد `settings/data` مباشرة — فإما تكرار منطق قراءة الإعدادات (القاعدة 1) أو خرق الحدود | أُضيف `lib/features/settings/settings.dart` **بأقل تغيير ممكن**: تصدير `data/settings_providers.dart` وأنواع المجال (`BusinessProfile`, `SettingsRepository`, `SettingKeys`) و`LoadBusinessProfile`، بلا أي تعديل سلوكي؛ والحقن يمرّ عبر `drift_product_repository.dart` الذي يستقبل `LoadBusinessProfile` كنوع مجرّد | `dart run tool/check_boundaries.dart` = Boundary check passed + اختبار «العملة تُعاد قراءتها، لا تُخزَّن مؤقتًا» في `test/features/catalog/data/drift_product_repository_test.dart` (EGP ثم USD على الرقم المخزَّن نفسه) — المجموع 498/498 |
| 2026-10-15 | `P2-03` | احتاج رفض الباركود المكرر أن يحمل **رابطًا للمنتج المالك** (FR-INV-011: «رفض التكرار برابط للموجود»)، بينما `Failure` في `core/result` هرمية `sealed` وكل أنواعها `final` فلا يجوز لميزة `catalog` أن تخترع نوع فشل يحمل `productId` | `Failure` أساس مشترك مقصود ليبقى `Result` مغلقًا، وتغييره في خطوة ميزة يعني فتح `core/result` على احتياجات كل ميزة قادمة (توسيع غير مبرَّر لكود مُلتزم) | لم يُلمس `core/result`: أُضيف رمز `BarcodeRepository.alreadyLinkedCode`، ويُبنى «الرابط» من قدرة البحث الموجودة في الخطوة نفسها — `FindBarcodeByCode`/`readByCode` تُعيد صاحب الكود (`productId`) فيصل المنادي إلى المنتج الموجود. ولأن `code` عليه قيد `UNIQUE` على مستوى العمود (لا فحص في الواجهة) فلا يمكن لكود أن يفقد مالكه | حالات في `test/features/catalog/data/drift_barcode_repository_test.dart`: رفض الكود المملوك لمنتج آخر بـ`alreadyLinkedCode` بلا أي كتابة ولا تدقيق، ثم `readByCode` على الكود نفسه تُعيد المنتج الأصلي؛ وحالة مستقلة تُثبت أن قيد `UNIQUE` نفسه يرفض إدراجًا مباشرًا خلف المستودع — المجموع 530/530 |
| 2026-10-15 | `P2-05` | فشل اختبار قديم: `test/app/router/app_router_test.dart` → «shell switches between destinations» عند `expect(find.text('Coming soon'), findsOneWidget)` بـ«Found 0 widgets with text "Coming soon"» | خطوة `P2-05` ربطت وجهة المنتجات بشاشة حقيقية (`AppDestination.products` → `ProductListScreen`) بعد أن كانت `PlaceholderPage` — تغيّر سلوكي **مقصود** لا عيب في الخطوة الجديدة، لكن الاختبار كان يثبّت نص البديل القديم | **أصغر تغيير ممكن، في الاختبار فقط:** استُبدل تأكيد النص البديل بتأكيد النوع `expect(find.byType(ProductListScreen), findsOneWidget)` + `expect(find.text('Coming soon'), findsNothing)` مع استيراد واحد، ولم يُلمس أي كود إنتاج. التأكيد على **النوع** مقصود: الشاشة في الشجرة سواء كانت القائمة تُحمَّل أو مملوءة أو فارغة أو خاطئة، فلا يصير الاختبار هشًّا بتغيّر حالة قاعدة البيانات | الاختبار نفسه بعد إصلاحه (سلوكان في `app_router_test.dart`) + بقية الحزمة — المجموع 609/609 |
| 2026-10-19 | `P2-06` | شاشة «منتج جديد» تفشل بالحفظ على تثبيت نظيف برسالة «اختر وحدة المخزون.» (`product.stockUnitRequired`) | لا يوجد أي كود في المشروع يُنشئ وحدة قياس افتراضية: `UnitsCompanion.insert` موجودة فقط داخل `drift_unit_repository.dart`، ولا شاشة في المرحلة 2 تنادي `createUnitProvider`، و`app_database.dart` لا يبذر إلا الأدوار — فجدول `units` يبقى فارغًا، وبما أن `products.stockUnitCode` **مرجع أجنبي** إلى `units.code` فلا يمكن حلّها بحقل واجهة يُخفى بلا صف في القاعدة | **إصلاح تكامل بأقل تغيير ممكن عبر المسار المعتمد نفسه (حالة استخدام + مستودع + تدقيق):** حالة استخدام جديدة `EnsureDefaultStockUnit` في مجال الكتالوج تُنشئ وحدة أساس واحدة (`piece` / «Piece») **فقط** إن كان الجدول فارغًا، وتعتبر `UnitRepository.codeTakenCode` نجاحًا (إنشاء متزامن)، وتُستدعى عند بناء بيانات نموذج المنتج في `catalog_ui_providers._formData` قبل قراءة الوحدات؛ ولا كتابة ولا تدقيق متى وُجدت وحدة (النداء عديم الأثر)، ولم يُلمس أي كود مُلتزم | `test/features/catalog/domain/use_cases/ensure_default_stock_unit_test.dart` (5 حالات: لا كتابة عند وجود وحدة، إنشاء وحدة أساس عند الفراغ، اعتبار تكرار الكود نجاحًا، تمرير فشل القراءة، تمرير فشل الإنشاء) + حالة في `product_form_screen_test.dart` → «provisions a stock unit so a brand-new shop can save» (نموذج بلا وحدات يُحفظ بلا `product.stockUnitRequired`، ويُسجَّل `CreateUnit.auditAction` ثم `CreateProduct.auditAction`) — المجموع 642/642 |

## 8. بروتوكول بدء الجلسة (Session Start Protocol)

على أي موديل في بداية كل جلسة، بالترتيب:

1. اقرأ هذا الملف كاملًا (الترويسة، `[DONE]`، `[IN-PROGRESS]`، الدفعة القادمة من `[PENDING]`).
2. نفّذ `git status` و`git log -n 20` وتحقق أن المشروع يطابق ما في `[DONE]`. عند أي تناقض: توقّف وأبلغ المستخدم.
3. نفّذ أوامر التحقق القياسية (القسم 4) على الحالة الحالية؛ إن لم تكن نظيفة فأصلح ذلك أولًا (القاعدة 5).
4. تابع من الخطوة الموجودة في `[IN-PROGRESS]` فقط. إن لم توجد، انقل **أول** خطوة في `[PENDING]` إليها.
5. لا تبدأ خطوتين معًا إلا إن كانتا معلَّمتين بـ ‖ في الخارطة وبلا اعتماد بينهما.
6. عند التوقف في منتصف خطوة: اكتب «ملاحظات تسليم» داخل بند `[IN-PROGRESS]` (ما أُنجز، ما تبقّى، ملفات مفتوحة، قرارات مأخوذة)، وأجرِ commit.

## 9. قالب أمر لكل خطوة (للصق في الأداة)

```
اقرأ EXECUTION_STATE.md أولًا ثم AGENTS.md.
الخطوة: <ID> — <العنوان>.
نفّذ هذه الخطوة فقط وفق معايير القبول (A) والتجربة (T) والتكامل (I) في القسم 5.
التزم بالقواعد 1–6. لا تعدّل أي كود مكتمل إلا لإصلاح مشكلة تكامل مع تقرير مختصر.
عند الانتهاء: شغّل أوامر التحقق، حدّث EXECUTION_STATE.md، وأجرِ commit.
```
