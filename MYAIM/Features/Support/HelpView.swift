import SwiftUI

/// Simple help center: common questions + contact options.
struct HelpView: View {
    private let faqs: [(q: String, a: String)] = [
        ("كيف أحجز خدمة؟",
         "افتح الخدمة التي تناسبك، اضغط «احجز الآن»، راجع التفاصيل، ثم حوّل المبلغ عبر التحويل البنكي أو رمز QR. تؤكّد الأكاديمية حجزك بعد التحقق من التحويل."),
        ("كيف يتم الدفع؟",
         "الدفع يتم مباشرة لحساب الأكاديمية عبر التحويل البنكي أو رمز QR الظاهر في التطبيق. احتفظ بإيصال التحويل والرقم المرجعي."),
        ("متى يتأكّد حجزي؟",
         "بعد إرسال الطلب، تراجع الأكاديمية التحويل وتؤكّد الحجز وتتواصل معك لتحديد الموعد المناسب."),
        ("كيف أتواصل مع الأكاديمية؟",
         "من صفحة الخدمة أو الأكاديمية اضغط «مراسلة»، وتقدر ترسل رسائل نصية أو صوتية قبل الحجز وبعده."),
        ("كيف أسجّل أكاديميتي؟",
         "من حسابك اختر «سجّل أكاديميتك»، وبعد التفعيل تحصل على لوحة لإدارة الدورات والطلبات والإحصائيات.")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                VStack(spacing: 0) {
                    ForEach(Array(faqs.enumerated()), id: \.offset) { idx, item in
                        if idx > 0 { Divider().background(MYColor.border) }
                        FAQRow(question: item.q, answer: item.a)
                    }
                }
                .myCard(padding: MYSpacing.xs)

                VStack(alignment: .leading, spacing: MYSpacing.md) {
                    Text("تواصل معنا").font(MYTypography.cardTitle).foregroundStyle(MYColor.textPrimary)
                    contactRow("envelope", "البريد الإلكتروني", "support@myaim.app",
                               url: URL(string: "mailto:support@myaim.app"))
                }
                .myCard()
            }
            .padding(MYSpacing.screen)
        }
        .myScreenBackground()
        .navigationTitle("المساعدة")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func contactRow(_ icon: String, _ label: String, _ value: String, url: URL?) -> some View {
        Button {
            if let url { UIApplication.shared.open(url) }
        } label: {
            HStack(spacing: MYSpacing.md) {
                Image(systemName: icon).font(.system(size: 16)).foregroundStyle(MYColor.primary).frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label).font(MYTypography.secondary).foregroundStyle(MYColor.textSecondary)
                    Text(value).font(MYTypography.body).foregroundStyle(MYColor.textPrimary)
                }
                Spacer()
                Image(systemName: "chevron.forward").font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(MYColor.textTertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct FAQRow: View {
    let question: String
    let answer: String
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            Button {
                Haptics.light(); withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() }
            } label: {
                HStack(spacing: MYSpacing.md) {
                    Text(question).font(MYTypography.body).foregroundStyle(MYColor.textPrimary)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: MYSpacing.sm)
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold)).foregroundStyle(MYColor.textTertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expanded {
                Text(answer)
                    .font(MYTypography.secondary).foregroundStyle(MYColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, MYSpacing.sm)
        .padding(.horizontal, MYSpacing.md)
    }
}

#Preview {
    NavigationStack { HelpView() }
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
