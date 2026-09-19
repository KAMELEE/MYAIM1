import SwiftUI

enum MYButtonStyle {
    case primary      // filled brand
    case secondary    // tinted brand
    case outline      // bordered
    case ghost        // text only
}

/// The single button component used across MY AIM.
struct MYButton: View {
    let title: String
    var icon: String? = nil
    var style: MYButtonStyle = .primary
    var isLoading: Bool = false
    var isEnabled: Bool = true
    var fullWidth: Bool = true
    let action: () -> Void

    var body: some View {
        Button {
            guard isEnabled, !isLoading else { return }
            Haptics.light()
            action()
        } label: {
            HStack(spacing: MYSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(foreground)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(MYTypography.button)
                }
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: 52)
            .padding(.horizontal, fullWidth ? 0 : MYSpacing.xl)
            .foregroundStyle(foreground)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: style == .outline ? 1 : 0)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1 : 0.5)
    }

    private var foreground: Color {
        switch style {
        case .primary:   return MYColor.onPrimary
        case .secondary: return MYColor.primary
        case .outline:   return MYColor.primary
        case .ghost:     return MYColor.primary
        }
    }

    private var background: Color {
        switch style {
        case .primary:   return MYColor.primary
        case .secondary: return MYColor.primaryTint
        case .outline:   return .clear
        case .ghost:     return .clear
        }
    }

    private var borderColor: Color {
        style == .outline ? MYColor.primary : .clear
    }
}

/// Subtle press-down scale used across tappable elements (150–200ms feel).
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        MYButton(title: "احجز الآن", icon: "calendar", style: .primary) {}
        MYButton(title: "متابعة الهدف", style: .secondary) {}
        MYButton(title: "عرض التفاصيل", style: .outline) {}
        MYButton(title: "تخطي", style: .ghost, fullWidth: false) {}
        MYButton(title: "جارٍ التحميل", isLoading: true) {}
    }
    .padding()
    .environment(\.layoutDirection, .rightToLeft)
}
