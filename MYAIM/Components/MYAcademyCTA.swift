import SwiftUI

/// "سجّل أكاديميتك" — a call-to-action inviting providers (academies, coaches,
/// experts, companies) to join MY AIM. Placed at the bottom of Home and in Profile.
struct MYAcademyCTA: View {
    var onRegister: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            HStack(spacing: MYSpacing.md) {
                Image(systemName: "building.2.crop.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(MYColor.primary)
                    .frame(width: 48, height: 48)
                    .background(MYColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text("هل تملك أكاديمية أو تقدّم خدمة؟")
                        .font(MYTypography.cardTitle)
                        .foregroundStyle(MYColor.textPrimary)
                    Text("انضم إلى MY AIM ووصّل خدماتك لآلاف الباحثين عن أهدافهم.")
                        .font(MYTypography.description)
                        .foregroundStyle(MYColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            MYButton(title: "سجّل أكاديميتك", icon: "plus.circle.fill", style: .primary) {
                onRegister?()
            }
        }
        .padding(MYSpacing.lg)
        .background(MYColor.primaryTint)
        .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous)
                .strokeBorder(MYColor.primary.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    MYAcademyCTA(onRegister: {})
        .padding()
        .myScreenBackground()
        .environment(\.layoutDirection, .rightToLeft)
}
