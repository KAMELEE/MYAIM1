# MY AIM — تطبيق iOS

سوق (Marketplace) عربي أولاً يساعد المستخدم على اكتشاف وحجز الأكاديميات والمدربين والدورات والبرامج التي تحقّق أهدافه.

> ✅ **حالة البناء:** يُترجَم ويعمل فعليًا على محاكي iOS (Xcode 16.4) عبر GitHub Actions — المستودع: `KAMELEE/MYAIM1`. لقطات التشغيل تُحفظ في `ci-logs/` (`shot-home.png`, `shot-discover.png`, …). لا يمكن البناء على Windows؛ الـCI يبنيه على macOS تلقائيًا عند كل رفع.

- **المنصة:** iOS 17+
- **التقنية:** Swift · SwiftUI · Swift Concurrency · MVVM · SwiftData · MapKit · CoreLocation
- **اللغة:** عربي أولاً مع دعم RTL حقيقي
- **الخط:** IBM Plex Sans Arabic

> هذه هي **المرحلة 1**: البنية المعمارية + نظام التصميم + هيكل التطبيق (App Shell).

---

## كيف أفتح المشروع وأشغّله؟ (على جهاز Mac)

### الطريقة الأسرع — XcodeGen
```bash
brew install xcodegen      # مرة واحدة
cd MYAIM                    # مجلد المشروع الذي يحوي project.yml
xcodegen generate
open MYAIM.xcodeproj
```
ثم اختر محاكي iPhone (iOS 17+) واضغط Run (⌘R).

### الطريقة اليدوية — بدون XcodeGen
1. في Xcode: File ▸ New ▸ Project ▸ iOS ▸ App، الاسم `MYAIM`، الواجهة SwiftUI، اللغة Swift.
2. احذف ملفات القالب الافتراضية (`ContentView.swift` وملف الـApp).
3. اسحب مجلد `MYAIM/` بالكامل إلى المشروع (اختر "Create groups").
4. تأكد من ضبط:
   - Deployment Target = iOS 17.0
   - Info.plist = `MYAIM/Resources/Info.plist`
5. الخطوط وأيقونة التطبيق **مُضمَّنة مسبقًا** في `Resources/` (لا حاجة لتنزيلها).

---

## هيكل المشروع

```
MYAIM/
├─ App/                    نقطة الدخول + حالة التطبيق
│  ├─ MYAIMApp.swift
│  └─ AppState.swift
├─ Core/
│  ├─ DesignSystem/        الألوان، الخطوط، المسافات، الحواف، الظلال
│  ├─ Extensions/          Color+Hex, Font+AppFont, Formatters, View+…
│  └─ Utilities/           Haptics, LoadingState
├─ Navigation/             AppTab + RootTabView (شريط التبويب)
├─ Features/               Home · Discover · Goals · Bookings · Profile
├─ Components/             MYButton · MYSectionHeader · MYEmptyState
├─ Models/                 (تُبنى مع الميزات)
├─ Repositories/           (Repository Architecture — تُبنى مع الميزات)
├─ Services/               (تُبنى مع الميزات)
└─ Resources/              Info.plist · Assets.xcassets · Fonts
```

---

## نظام التصميم (Design System)

كل الألوان تُقرأ من مصدر واحد: **`Core/DesignSystem/MYColor.swift`**.
لمطابقة شعار MY AIM الرسمي، غيّر القيم داخل `enum Brand` فقط — ويُعاد تلوين التطبيق كله دون أي تعديل آخر.

> الهوية = بنفسجي شعار MY AIM (`#5B3FBF`) مستخدَم باحتراف: ألوان **صلبة** فقط، بلا تدرجات وبلا توهّج (لا مظهر AI)، والخلفيات محايدة.

| الرمز | الاستخدام |
|------|-----------|
| `MYColor` | الألوان (Light/Dark تلقائي) |
| `MYTypography` | سلّم الخطوط (IBM Plex Sans Arabic) |
| `MYSpacing` / `MYRadius` | المسافات والحواف |
| `MYShadow` + `.myCard()` | البطاقات والظلال |

---

## ما المُنجَز في المرحلة 1
- [x] بنية مجلدات منظمة وقابلة للتوسع (MVVM + Repository-ready)
- [x] نظام تصميم مركزي: ألوان، Typography، مسافات، حواف، ظلال
- [x] دعم Light/Dark حقيقي (ألوان ديناميكية)
- [x] عربي أولاً + RTL على مستوى التطبيق
- [x] شريط تبويب أصلي بخمسة أقسام (App Shell)
- [x] مكوّنات أساسية: `MYButton`, `MYSectionHeader`, `MYEmptyState`
- [x] `LoadingState` موحّد لحالات التحميل/الفراغ/الخطأ
- [x] Haptics ومنسّقات (سعر ر.س، مسافة، تقييم، تاريخ)

## اتجاه اللايوت (مرجع المستخدم)
مستوحى من مرجع تطبيق سوق نظيف: **شريط موقع** أعلى الرئيسية، **بحث + زر فلاتر**، **بانر عرض** (لون صلب بلا تدرّج)، و**كروت شبكية بعمودين**: صورة + شارة زاوية · اسم · مقدّم الخدمة · تقييم + موقع · صف سفلي بالسعر البارز + **زر دائري** (مفضلة). أسفل الرئيسية **خانة «سجّل أكاديميتك»** للمزوّدين.

**الشريط السفلي:** شريط **Boxed عائم** (`MYTabBar`) بحاوية دائرية وظل ناعم؛ التبويب النشط يتمدّد لبطاقة بلون الهوية الخفيف مع أيقونة مملوءة ونص. 5 أقسام. **اللوقو** الحقيقي مُضاف كأصل `Logo` (`MYLogo`).

## الأصول الحقيقية (مُضافة فعليًا)
- [x] **الخطوط:** ملفات IBM Plex Sans Arabic الأربعة (.ttf) داخل `Resources/Fonts` — تعمل مباشرة.
- [x] **أيقونة التطبيق:** مولّدة من اللوقو (`AppIcon` 1024×1024، RGB بلا شفافية).
- [x] **اللوقو:** أصل `Logo` + يظهر داخل شريط الرئيسية العلوي (`MYHomeHeader`).
- [x] **الصور:** روابط صور حقيقية في `SampleData` والأقسام تُحمّل عبر `AsyncImage` (بدائل تطوير تُستبدل بصور الخادم لاحقًا).
- [x] **الأيقونات:** SF Symbols من النظام (لا تحتاج ملفات).
- [x] **الرئيسية:** بُنيت شاشة حقيقية (هيدر باللوقو + بحث/فلاتر + بانر + أقسام + شبكة بطاقات + تسجيل أكاديمية) على بيانات `SampleData` مؤقتًا لحين ربط الـViewModel في المرحلة 5.

## المرحلة 2 (مكتملة)
- [x] نماذج البيانات الأساسية: `ServiceCategory`, `Provider`, `Service`, `Goal`/`GoalStep`, `Review`, `MYLocation`
- [x] بيانات عربية واقعية للمعاينة والـMock (`SampleData`)
- [x] مكوّنات Design System الكاملة:
  - عناصر: `MYRating` · `MYPrice` · `MYTag` / `MYVerifiedBadge`
  - إدخال: `MYSearchBar` · `MYSearchButton`
  - بطاقات: `MYServiceCard` · `MYCategoryCard` · `MYProviderCard` · `MYGoalCard`
  - أخرى: `MYBottomSheet` (+ Header/Footer) · `MYSkeleton` · `MYRemoteImage` · `MYLogo` · `MYTabBar` · `MYAcademyCTA` · `MYPromoBanner` · `MYHomeHeader` · `MYHeroCarousel`

## سلايدر الهيرو
`MYHeroCarousel` — سلايدر متحرك أعلى الرئيسية يتنقّل تلقائيًا، بثلاثة أنواع شرائح: **صورة مميّزة** (خلفية صورة + طبقة تعتيم صلبة)، **كود خصم** (`AIM20` مع زر نسخ + Haptic)، و**«ليش MY AIM»** (نقاط مميّزات). مع نقاط ترقيم (Page Dots) وتمرير باللمس. الشرائح في `SampleData.heroSlides`.

## المرحلة 3 (مكتملة) — Navigation + Routing
- [x] `AppRoute` (وجهات type-safe) + `Router` (@Observable) لكل تبويب
- [x] `RootTabView` يعطي كل تبويب `NavigationStack` خاص + `withAppRoutes()`
- [x] `RouteDestination` يربط كل مسار بشاشته
- [x] الرئيسية تنقل فعليًا: بطاقة → تفاصيل الخدمة، عرض الكل → قائمة، الإشعارات، تسجيل أكاديمية
- [x] `ServiceDetailView` (تفاصيل حقيقية) + `AllServicesView` (شبكة) + `ComingSoonView` (سقالة للمراحل القادمة)

## المرحلة 4 (مكتملة) — Onboarding + Authentication
### تحديث Onboarding (سبتمبر 2026)
- محتوى جديد بأسلوب مباشر بدون عبارات مصطنعة: «اكتشف أفضل الأكاديميات والجهات التدريبية»
  (جهات تدريبية موثوقة · دورات وتخصصات متنوعة)، الأقرب لك، قارن واختر، أسعار واضحة.
- دخول متتابع (staggered) لكل صفحة: الرسم → العنوان → الوصف → المزايا،
  مع شارة أيقون متدرجة اللون تتنفس بلطف ونقاط تقدم أنعم.
- أيقونات SF Symbols حديثة وواضحة في التاب بار والفئات (scope، person.crop.circle،
  brain.filled.head.profile …).

## واجهة رئيسية جديدة (سبتمبر 2026)
- **قصص الأكاديميات** أول شيء في الرئيسية: دوائر بحلقة متدرجة، مشغل قصص
  ملء الشاشة بأشرطة تقدم وتقدم تلقائي وسحب للإغلاق (RTL).
- **هيرو مميز**: بطاقة متدرجة متعددة الطبقات مع أشكال زخرفية وشارات زجاجية
  عائمة (تقييم 4.9، موثّقة) وزر CTA واضح — بديل عن الكتابة العادية.
- **بلاطات المزايا**: ثلاث بلاطات مدمجة (موثوق/سعر واضح/حجز فوري).
- **ترتيب جديد**: الهيدر ← القصص ← البحث ← الهيرو ← البلاطات ← الأقسام ← المحتوى.
- أيقونات حديثة: bell.badge.fill، شرائح أقسام ملونة بلون كل فئة.

## التواصل مع الأكاديميات — رسائل وصوتيات (مفعّل)
- الإرسال يعمل: الرسالة تُضاف فورًا ويرد على المحادثة رد تلقائي من الأكاديمية
  مع مؤشر «يكتب الآن…» بنقاط متحركة.
- **الرسائل الصوتية**: زر ميكروفون يسجّل صوتًا حقيقيًا (m4a) ويشغّله بنقرة
  (تصريح الميكروفون مضاف إلى Info.plist).
- زر «تواصل» دائري في شريط الحجز بصفحة الخدمة يفتح محادثة فورية مع الأكاديمية
  (`MessagesStore.openConversation` — يعيد استخدام المحادثة إن وجدت).
- ردود سريعة جاهزة أول المحادثة (المواعيد؟ خصومات؟ كيف أحجز؟) لتسهيل بدء الحوار.
- المسار: الخدمة → تواصل → Chat، وقائمة الرسائل من الملف الشخصي.
- [x] `AuthRepository` (بروتوكول) + `MockAuthRepository` — **أول Repository فعلي**
- [x] `AuthViewModel` (@Observable) مع Validation حقيقي (بريد/جوال سعودي/كلمة مرور/OTP)
- [x] Onboarding 3 شاشات + `RootCoordinatorView` (Onboarding → Auth → App)
- [x] شاشات: تسجيل الدخول · إنشاء حساب · OTP (4 خانات) · نسيت كلمة المرور
- [x] `MYTextField` (حقل بأيقونة + إظهار كلمة المرور + خطأ) · تسجيل الخروج من حسابي

## المرحلة 5 (مكتملة) — Home + Repositories
- [x] `ServiceRepository` + `MockServiceRepository` · `GoalRepository` + `MockGoalRepository`
- [x] `HomeViewModel` (@Observable) يحمّل الأقسام بالتوازي مع `LoadingState`
- [x] الرئيسية: Skeleton أثناء التحميل، حالات فراغ/خطأ + إعادة محاولة، Pull-to-refresh
- [x] أقسام أفقية: الأكثر حجزاً · قريب منك · موصى لك · هدفك الحالي

## المرحلة 6 (مكتملة) — Discover + Search + Filters
- [x] `DiscoverViewModel` (بحث Debounced، فلاتر، تبديل قائمة/خريطة)
- [x] `DiscoverView`: بحث + زر فلاتر (بعدّاد) + رقاقات أقسام + تبديل قائمة/خريطة + نتائج
- [x] `FiltersSheet` (Bottom Sheet: فئة/سعر/تقييم/مسافة/توفّر + إعادة تعيين/عرض)
- [x] `SearchView` + `SearchViewModel`: بحث أخير (محفوظ) + شائع + اقتراحات مباشرة + نتائج
- [x] `MapResultsView` (MapKit): Markers بالأسعار + بطاقة مصغّرة عند الاختيار

## المراحل 8–11 (مكتملة) — بقية الصفحات
- [x] **تفاصيل الخدمة** كاملة + **صفحة مقدّم الخدمة** (`ProviderProfileView`: غلاف/شعار/نبذة/خدمات/آراء)
- [x] **الحجز** (`BookingView` + `BookingViewModel`): تاريخ → وقت → تأكيد → شاشة نجاح، عبر `BookingRepository`
- [x] **حجوزاتي** (`BookingsView`): تبويبات القادمة/السابقة + حالات (مؤكد/بانتظار/مكتمل/ملغي)
- [x] **الأهداف**: `GoalsView` (حالية/مكتملة) · `GoalDetailView` (تبديل الخطوات حيًّا) · `CreateGoalView` — عبر `GoalsStore`
- [x] **المفضلة** (`FavoritesView`) عبر `FavoritesStore` مشترك (يُحفظ محليًا، متزامن عبر كل الشاشات)
- [x] **الإشعارات** (`NotificationsView`) + نموذج `AppNotification`
- [x] **تسجيل الأكاديمية** (`RegisterAcademyView`) بنموذج وValidation وشاشة نجاح
- [x] كل المسارات موصولة في `RouteDestination` (لا شاشات وهمية متبقية)

## المرحلة 7 (مكتملة) — Live Location + Clustering
- `LocationService` يطلب صلاحية الموقع ويبثّ موقع المستخدم الحيّ للتطبيق كله.
- `DiscoverView` يعيد حساب المسافات من الموقع الحيّ ويرتّب النتائج (الأقرب أولاً) عند توفر الموقع.
- `MapResultsView`: نقطة زرقاء للمستخدم (`UserAnnotation` + `MapUserLocationButton`) مع تمركز تلقائي أول مرة.
- **Clustering**: تجميع الشارات القريبة في شبكة تتكيف مع مستوى الزوم (`onMapCameraChange`) —
  الشارة المجمّعة تعرض العدد + أرخص سعر، والنقر عليها يقرّب الكاميرا حتى تنفصل العلامات.
- إسقاط تحديد البطاقة المصغّرة تلقائيًا إذا اندمجت خدمتها في عنقود.

## البيانات الحقيقية (Firestore)
- الإنتاج (بناء Xcode المحلي بدون `DEMO`) يعمل الآن كليًا على Firestore:
  - **`services`** — كتالوج الخدمات. عند أول إطلاق، إن كانت المجموعة فارغة تُزرع
    تلقائيًا من الكتالوج العربي المدمج (`SampleData`) مرة واحدة، ثم يقرأ التطبيق
    البيانات الحية دائمًا.
  - **`bookings`** — حجوزات المستخدم (`userId` + لقطة الخدمة لحظة الحجز + التاريخ/الوقت/الحالة).
  - **`goals`** — أهداف المستخدم وخطواتها؛ الإضافة وتأشير الخطوات تُكتب فورًا إلى Firestore.
- `AppRepositories` هي نقطة القرار الوحيدة: `DEMO` → Mocks، غير ذلك → Firestore.
- ملاحظة: لوحة الأكاديمية (Provider) والدردشة ما زالتا في الذاكرة (عرض تجريبي).

### قواعد الحماية المقترحة (Firestore ▸ Rules)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /services/{doc} {
      allow read: if true;
      // بذر الكتالوج أول مرة فقط (المجموعة الفارغة)
      allow create: if true;
      allow update, delete: if false;
    }
    match /bookings/{doc} {
      allow read, update, delete: if request.auth != null
        && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null
        && request.auth.uid == request.resource.data.userId;
    }
    match /goals/{doc} {
      allow read, update, delete: if request.auth != null
        && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null
        && request.auth.uid == request.resource.data.userId;
    }
  }
}
```
> الإنتاج يحتاج أيضًا تفعيل **Email/Password** و**Phone** في Authentication
> (Console ▸ Sign-in method)، وإضافة أرقام تجريبية للجوال عند الرغبة بتجربة OTP بدون SMS.

## وضع العرض التجريبي (DEMO)
- بناء الـCI يمرر `DEMO_FLAG=DEMO` إلى xcodebuild — نسخة Appetize تستخدم
  مصادقة وهمية (`MockAuthRepository`) وبيانات Mock كاملة: أي بيانات دخول تنجح،
  والتسجيل يقبل رمز OTP `1234`.
- البناء المحلي من Xcode (بدون `DEMO`) يستخدم Firebase الحقيقي، ورسائل خطأ Firebase أصبحت
  بالعربية (حساب غير موجود / مزوّد غير مفعّل في Console …).
- أتمتة CI (`-autoLogin` / `-autoRegister` / `-autoOTP`): تشغيل مسارات الدخول والتسجيل
  كاملة مع لقطات شاشة بعد كل خطوة، فأي انهيار في المسار يظهر في `ci-logs/crash.txt`.

## المتبقّي
- **المرحلة 12–13:** لمسات حركة إضافية + اختبار شامل على Mac.

> ملاحظة: لا يمكن بناء المشروع على Windows؛ افتحه على Mac (`xcodegen generate`) وبلّغني بأي خطأ ترجمة.
