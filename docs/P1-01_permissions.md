# `P1-01` — الصلاحيات ومصفوفة الأدوار (Phase 1 — الهوية والصلاحيات)

> الخطوة: `P1-01` — تعداد `Permission` + مصفوفة الأدوار الافتراضية — الموديل: Big Pickle — التاريخ: 2026-10-13
> المصدر الملزم: `EXECUTION_STATE.md`.

## 1) ملاحظة مصدر مهمة (اقرأها أولًا)

معيار القبول في `EXECUTION_STATE.md` هو: «تطابق مصفوفة الأدوار في PRD (القسم 2) خلية بخلية».
**وثيقة PRD (والمواصفات التقنية) غير موجودة داخل المستودع** — `EXECUTION_STATE.md` يذكرها كمراجع خارجية.

لذلك، وبناءً على موافقة مالك المشروع في 2026-10-13، **اشتُقّت المصفوفة من المجالات الوظيفية** التي تخطط
خارطة الطريق لإطلاقها، وهذه الحالة **مؤقتة بانتظار مصادقة PRD**. عند توفّر الوثيقة تُراجَع كل خلية
وتُصحَّح، ثم يُحدَّث هذا الملف و`EXECUTION_STATE.md`.

## 2) الملفات

| الملف | المحتوى |
|---|---|
| `lib/features/auth/domain/permission.dart` | `enum Permission` — 31 صلاحية، كل واحدة تحمل `code` ثابتًا (مثل `sale.create`) + `Permission.fromCode`. |
| `lib/features/auth/domain/user_role.dart` | `enum UserRole { owner, cashier, inventory, accountant }` + `code` + `UserRole.fromCode`. |
| `lib/features/auth/domain/role_matrix.dart` | واجهة `RoleMatrix` + التنفيذ الافتراضي `DefaultRoleMatrix`. |

### لماذا واجهة `RoleMatrix`؟

لأن الأدوار المخصصة تأتي في `P1-14`؛ فحالات الاستخدام تعتمد على الواجهة، ويُستبدل التنفيذ لاحقًا
(أدوار محفوظة في القاعدة) **دون تعديل أي حالة استخدام**. وهذا مبدأ «interface first» الملزم.

`DefaultRoleMatrix.permissionsFor` منفَّذ بـ**تعبير `switch` شامل**: إضافة دور جديد إلى `UserRole`
تُصبح خطأ تصريف (compile error) بدل أن تُمنح الصلاحيات صفرًا بصمت.

## 3) المصفوفة (نسخة مؤقتة — دور × صلاحية)

| الصلاحية (code) | مالك | كاشير | مخزون | محاسب |
|---|:--:|:--:|:--:|:--:|
| `sale.create` | ✅ | ✅ | — | — |
| `sale.discount` | ✅ | ✅ | — | — |
| `sale.refund` | ✅ | — | — | ✅ |
| `sale.void` | ✅ | — | — | — |
| `sale.history.view` | ✅ | ✅ | — | ✅ |
| `catalog.product.view` | ✅ | ✅ | ✅ | ✅ |
| `catalog.product.manage` | ✅ | — | ✅ | — |
| `catalog.price.manage` | ✅ | — | — | — |
| `catalog.category.manage` | ✅ | — | ✅ | — |
| `inventory.view` | ✅ | ✅ | ✅ | ✅ |
| `inventory.adjust` | ✅ | — | ✅ | — |
| `inventory.transfer` | ✅ | — | ✅ | — |
| `supplier.manage` | ✅ | — | ✅ | ✅ |
| `purchase.create` | ✅ | — | ✅ | ✅ |
| `purchase.receive` | ✅ | — | ✅ | — |
| `purchase.pay` | ✅ | — | — | ✅ |
| `customer.view` | ✅ | ✅ | — | ✅ |
| `customer.manage` | ✅ | ✅ | — | ✅ |
| `customer.payment` | ✅ | — | — | ✅ |
| `expense.manage` | ✅ | — | — | ✅ |
| `report.sales.view` | ✅ | — | — | ✅ |
| `report.inventory.view` | ✅ | — | ✅ | ✅ |
| `report.finance.view` | ✅ | — | — | ✅ |
| `report.export` | ✅ | — | ✅ | ✅ |
| `settings.manage` | ✅ | — | — | — |
| `user.manage` | ✅ | — | — | — |
| `role.manage` | ✅ | — | — | — |
| `backup.manage` | ✅ | — | — | ✅ |
| `audit.view` | ✅ | — | — | ✅ |
| `license.manage` | ✅ | — | — | — |
| `printer.configure` | ✅ | ✅ | — | — |

## 4) تبرير كل دور (لماذا هذه الخلايا)

- **مالك (`owner`)**: يملك كل الصلاحيات؛ هو الحساب المُنشأ في معالج الإعداد، والوحيد الذي يغيّر
  **الأسعار** وإعدادات النشاط ويدير **المستخدمين والأدوار والترخيص وسجل التدقيق**.
- **كاشير (`cashier`)**: حلقة البيع اليومية — إنشاء البيع، الخصم المسموح به في نقطة البيع، وعرض سجل
  المبيعات، والبحث في الكتالوج والمخزون والعملاء، وإضافة عميل جديد، وضبط الطابعة.
  **محروم** من الإرجاع والإلغاء والأسعار وتسويات المخزون وكل التقارير.
- **مخزون (`inventory`)**: البضائع والمخزون — إدارة المنتجات والتصنيفات والموردين، إنشاء أوامر شراء
  واستلامها، تسوية المخزون ونقله، وقراءة/تصدير تقارير المخزون.
  **محروم** من التسعير والبيع والدفع للموردين والإدارة.
- **محاسب (`accountant`)**: المال والتقارير — الإرجاع، سجل المبيعات، السداد للموردين، تحصيل دفعات
  العملاء، المصروفات، كل التقارير مع التصدير، النسخ الاحتياطي، وسجل التدقيق.
  **محروم** من البيع والتسعير وإدارة المستخدمين.

### حرّاس مقصودون (نمط مقصود في المصفوفة)

| الحارس | السبب |
|---|---|
| `sale.refund` و`sale.void` ليست للكاشير | حركتان ماليتان تحتاجان صلاحية أعلى (منع تسرّب نقدي). |
| `catalog.price.manage` للمالك فقط | التسعير قرار تجاري يجب أن يبقى مركزيًا. |
| `settings.manage` / `user.manage` / `role.manage` / `license.manage` للمالك فقط | صلاحيات إدارة النظام لا تُفوَّض في المرحلة 1. |
| `report.finance.view` للمالك والمحاسب فقط | أرقام الربح والخسارة ليست للكاشير. |
| `purchase.receive` للمخزون و`purchase.pay` للمحاسب | فصل «استلام البضاعة» عن «صرف المال» (فصل مهام). |

## 5) الاختبارات

- `test/features/auth/domain/permission_test.dart` — صيغة الأكواد (نقطية بحروف صغيرة)، تفرّد الأكواد،
  `fromCode` يعيد كل قيمة، ويرجع `null` لغير المعروف/الفارغ/`null`/تغيّر حالة الأحرف.
- `test/features/auth/domain/user_role_test.dart` — الأدوار الأربعة وأكوادها، و`fromCode` ذهابًا وإيابًا.
- `test/features/auth/domain/role_matrix_test.dart` — جدول توقّعات مستقل، ثم **اختبار لكل خلية**
  (4 أدوار × 31 صلاحية = 124 خلية) عبر `DefaultRoleMatrix.allows`، + حراسة أن المالك يملك كل الصلاحيات،
  + حراسة أن المجموعات المُعادة غير قابلة للتعديل (`throwsUnsupportedError`).

## 6) التحقق

- `dart format` نظيف، `flutter analyze` = No issues found، `dart run tool/check_boundaries.dart` = Boundary check passed،
  `flutter test` أخضر (التفاصيل في `EXECUTION_STATE.md`).
- `domain` نقي: لا Flutter ولا Drift ولا Riverpod في ملفات `lib/features/auth/domain/`.
