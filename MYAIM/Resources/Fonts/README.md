# خط IBM Plex Sans Arabic

ضع ملفات الخط (.ttf) في هذا المجلد بالأسماء التالية بالضبط:

- `IBMPlexSansArabic-Regular.ttf`
- `IBMPlexSansArabic-Medium.ttf`
- `IBMPlexSansArabic-SemiBold.ttf`
- `IBMPlexSansArabic-Bold.ttf`

## من أين أحصل عليها؟
Google Fonts — IBM Plex Sans Arabic: https://fonts.google.com/specimen/IBM+Plex+Sans+Arabic
(اضغط "Get font" ثم "Download all"، وستجد ملفات .ttf.)

## ملاحظات
- الأسماء مسجّلة مسبقًا في `Info.plist` تحت `UIAppFonts`، وفي `Font+AppFont.swift`.
- إذا لم توجد الخطوط وقت التشغيل، يعود التطبيق تلقائيًا لخط النظام دون أن يتعطّل.
- بعد إضافتها عبر XcodeGen، أعد توليد المشروع: `xcodegen generate`.
- إذا أنشأت المشروع يدويًا في Xcode، تأكد أن ملفات .ttf ضمن "Copy Bundle Resources".
- لتغيير الخط لاحقًا: عدّل `fontName` في `Font+AppFont.swift` فقط.
