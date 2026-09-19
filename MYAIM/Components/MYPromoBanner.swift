import SwiftUI

/// Home promo banner. Solid brand tint (no gradient, no glow), with a kicker,
/// title, subtitle, an SF Symbol mark, and a CTA.
struct MYPromoBanner: View {
    var kicker: String = "حدّد وجهتك"
    var title: String = "وش هدفك القادم؟"
    var subtitle: String = "اكتشف برامج ومدربين مصمّمين لتحقيق هدفك."
    var actionTitle: String = "ابدأ الآن"
    var icon: String = "target"
    var onTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: MYSpacing.md) {
            VStack(alignment: .leading, spacing: MYSpacing.xs) {
                Text(kicker)
                    .font(MYTypography.caption)
                    .foregroundStyle(MYColor.primary)
                Text(title)
                    .font(MYTypography.section)
                    .foregroundStyle(MYColor.textPrimary)
                Text(subtitle)
                    .font(MYTypography.description)
                    .foregroundStyle(MYColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, MYSpacing.xs)

                Button {
                    Haptics.light()
                    onTap?()
                } label: {
                    Text(actionTitle)
                        .font(.appFont(13, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, MYSpacing.lg)
                        .padding(.vertical, MYSpacing.sm)
                        .background(MYColor.primary)
                        .clipShape(Capsule())
                }
                .buttonStyle(PressableButtonStyle())
            }

            Spacer(minLength: 0)

            Image(systemName: icon)
                .font(.system(size: 40, weight: .regular))
                .foregroundStyle(.white)
                .frame(width: 84, height: 84)
                .background(MYColor.primary)
                .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
        }
        .padding(MYSpacing.lg)
        .background(MYColor.primaryTint)
        .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
    }
}

#Preview {
    MYPromoBanner(onTap: {})
        .padding()
        .myScreenBackground()
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
