import SwiftUI

enum MYTagStyle {
    case neutral      // gray fill
    case brand        // brand-tinted
    case success
    case warning
    case error
}

/// Small pill label used for categories, statuses, "موثّق", "جديد", distance, etc.
struct MYTag: View {
    let text: String
    var icon: String? = nil
    var style: MYTagStyle = .neutral

    var body: some View {
        HStack(spacing: MYSpacing.xxs) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(text)
                .font(MYTypography.caption)
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, MYSpacing.sm)
        .padding(.vertical, MYSpacing.xs)
        .background(background)
        .clipShape(Capsule())
    }

    private var foreground: Color {
        switch style {
        case .neutral: return MYColor.textSecondary
        case .brand:   return MYColor.primary
        case .success: return MYColor.success
        case .warning: return MYColor.warning
        case .error:   return MYColor.error
        }
    }

    private var background: Color {
        switch style {
        case .neutral: return MYColor.surfaceSecondary
        case .brand:   return MYColor.primaryTint
        case .success: return MYColor.success.opacity(0.12)
        case .warning: return MYColor.warning.opacity(0.14)
        case .error:   return MYColor.error.opacity(0.12)
        }
    }
}

/// Convenience: a "موثّق" verification badge.
struct MYVerifiedBadge: View {
    var body: some View {
        MYTag(text: "موثّق", icon: "checkmark.seal.fill", style: .brand)
    }
}

#Preview {
    HStack {
        MYTag(text: "تطوير الذات", style: .brand)
        MYVerifiedBadge()
        MYTag(text: "جديد", style: .success)
        MYTag(text: "1.2 كم", icon: "location.fill")
    }
    .padding()
    .environment(\.layoutDirection, .rightToLeft)
}
