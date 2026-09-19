# تشغيل MY AIM على Mac

> ⚠️ لا يمكن بناء/تشغيل تطبيقات iOS على Windows. نفّذ هذه الخطوات على جهاز **Mac** فيه **Xcode 15+** (iOS 17 SDK).

## 1) الطريقة الأسرع — XcodeGen
```bash
# مرة واحدة: ثبّت الأدوات
brew install xcodegen

# داخل مجلد المشروع (الذي يحوي project.yml)
cd MYAIM_PROJECT_FOLDER
xcodegen generate
open MYAIM.xcodeproj
```
ثم في Xcode:
1. اختر الهدف **MYAIM** ومحاكي **iPhone 15/16 (iOS 17+)** من الأعلى.
2. اضغط **⌘R** (Run).

## 2) بدون XcodeGen (يدويًا)
1. Xcode ▸ File ▸ New ▸ Project ▸ iOS ▸ App، الاسم `MYAIM`، Interface: SwiftUI.
2. احذف ملفات القالب (`ContentView.swift` وملف الـApp الافتراضي).
3. اسحب مجلد `MYAIM/` بالكامل إلى المشروع (اختر "Create groups").
4. Deployment Target = **iOS 17.0**، وInfo.plist = `MYAIM/Resources/Info.plist`.
5. اضغط Run.

## ما يجب أن تراه
- شاشة **Onboarding** (٣ صفحات) → **تسجيل الدخول** → التطبيق.
- تسجيل الدخول: أدخل أي بريد صحيح (مثل `a@a.com`) وكلمة مرور ٦ أحرف فأكثر → يدخل مباشرة.
- إنشاء حساب → رمز OTP: أدخل أي **٤ أرقام** (مثل `1234`).
- الرئيسية بأقسامها، اكتشف/بحث/خريطة، تفاصيل خدمة، حجز، أهداف، مفضلة، إشعارات، حسابي.

## إن ظهر خطأ ترجمة
- **الخطوط:** مضمّنة في `MYAIM/Resources/Fonts` — تأكد أنها ضمن "Copy Bundle Resources".
- **الخريطة (`MapResultsView`):** تستخدم MapKit لـ iOS 17؛ إن ظهر خطأ في `Map(position:selection:)` أرسله لي وأصلحه.
- انسخ أي رسالة خطأ (اسم الملف + السطر) وأرسلها لي — أصلحها فورًا عن بُعد.

## تشغيل بدون Mac (خيارات)
- **Mac سحابي:** MacinCloud / MacStadium (بالساعة) — ثم اتبع القسم 1.
- **Codemagic / Xcode Cloud:** بناء آلي على محاكي وإرجاع لقطات/فيديو دون امتلاك Mac.
