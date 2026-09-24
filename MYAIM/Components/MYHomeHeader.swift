import SwiftUI

/// Top header bar of the Home screen: logo (leading) + current location +
/// notifications (trailing). The logo lives here, inside the bar.
struct MYHomeHeader: View {
    var city: String = "الرياض، السعودية"
    var hasUnreadNotifications: Bool = true
    var onLocationTap: (() -> Void)? = nil
    var onNotificationsTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: MYSpacing.md) {
            MYLogo(size: 40)

            Button {
                Haptics.selection()
                onLocationTap?()
            } label: {
                VStack(alignment: .leading, spacing: 1) {
                    Text("موقعك الحالي")
                        .font(MYTypography.caption)
                        .foregroundStyle(MYColor.textSecondary)
                    HStack(spacing: MYSpacing.xxs) {
                        Text(city)
                            .font(MYTypography.cardTitle)
                            .foregroundStyle(MYColor.textPrimary)
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(MYColor.textSecondary)
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer(minLength: MYSpacing.sm)

            Button {
                Haptics.light()
                onNotificationsTap?()
            } label: {
                Image(systemName: hasUnreadNotifications ? "bell.badge.fill" : "bell")
                    .font(.system(size: 18, weight: .regular))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(MYColor.textPrimary)
                    .frame(width: 42, height: 42)
                    .background(MYColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                            .strokeBorder(MYColor.border, lineWidth: 0.5)
                    )
                    .overlay(alignment: .topTrailing) {
                        if hasUnreadNotifications {
                            Circle()
                                .fill(MYColor.error)
                                .frame(width: 9, height: 9)
                                .overlay(Circle().strokeBorder(MYColor.background, lineWidth: 2))
                                .offset(x: -9, y: 9)
                        }
                    }
            }
            .accessibilityLabel("الإشعارات")
        }
    }
}

#Preview {
    VStack {
        MYHomeHeader()
        Spacer()
    }
    .padding()
    .myScreenBackground()
    .environment(\.layoutDirection, .rightToLeft)
    .environment(\.locale, Locale(identifier: "ar"))
}
