import SwiftUI

/// Simple, non-decorative empty state (SF Symbol + text + optional action).
struct MYEmptyState: View {
    let icon: String
    let title: String
    var message: String? = nil
    var actionTitle: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: MYSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(MYColor.textTertiary)
                .padding(.bottom, MYSpacing.xs)

            Text(title)
                .font(MYTypography.cardTitle)
                .foregroundStyle(MYColor.textPrimary)
                .multilineTextAlignment(.center)

            if let message {
                Text(message)
                    .font(MYTypography.secondary)
                    .foregroundStyle(MYColor.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let onAction {
                MYButton(title: actionTitle, style: .secondary, fullWidth: false, action: onAction)
                    .padding(.top, MYSpacing.sm)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(MYSpacing.xxl)
    }
}

#Preview {
    MYEmptyState(
        icon: "calendar.badge.exclamationmark",
        title: "ما عندك حجوزات حالياً",
        message: "اكتشف برامج وخدمات تناسب هدفك وابدأ رحلتك.",
        actionTitle: "اكتشف الآن",
        onAction: {}
    )
    .environment(\.layoutDirection, .rightToLeft)
}
