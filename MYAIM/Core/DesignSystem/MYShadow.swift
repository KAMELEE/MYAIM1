import SwiftUI

/// MY AIM — Restrained, professional shadows (no glow, no exaggeration).
struct MYShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

enum MYShadow {
    /// Subtle lift for cards.
    static let card = MYShadowStyle(
        color: Color.black.opacity(0.06),
        radius: 10, x: 0, y: 4
    )
    /// A touch stronger for floating sheets / raised controls.
    static let raised = MYShadowStyle(
        color: Color.black.opacity(0.10),
        radius: 16, x: 0, y: 8
    )
}

extension View {
    func myShadow(_ style: MYShadowStyle = MYShadow.card) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }

    /// Standard MY AIM card container: surface background, rounded, subtle border + shadow.
    func myCard(padding: CGFloat = MYSpacing.lg,
                radius: CGFloat = MYRadius.md) -> some View {
        self
            .padding(padding)
            .background(MYColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(MYColor.border, lineWidth: 0.5)
            )
            .myShadow()
    }
}
