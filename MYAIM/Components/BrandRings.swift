import SwiftUI

/// Concentric "target" rings — the MY AIM motif — drawn as solid,
/// low-opacity white strokes on a brand surface (no gradients, no glow).
struct BrandRings: View {
    /// Outer diameter of the largest ring.
    var size: CGFloat = 760
    /// 0…1 — drives the entrance (rings grow in from the center).
    var progress: CGFloat = 1

    var body: some View {
        ZStack {
            ring(diameter: size,        width: size * 0.074, opacity: 0.05, delay: 0.16)
            ring(diameter: size * 0.68, width: size * 0.063, opacity: 0.07, delay: 0.08)
            ring(diameter: size * 0.40, width: size * 0.053, opacity: 0.09, delay: 0)
        }
        .frame(width: size, height: size)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func ring(diameter: CGFloat, width: CGFloat, opacity: Double, delay: Double) -> some View {
        Circle()
            .strokeBorder(.white.opacity(opacity), lineWidth: width)
            .frame(width: diameter, height: diameter)
            .scaleEffect(0.6 + 0.4 * progress)
            .opacity(Double(progress))
            .animation(.spring(response: 0.7, dampingFraction: 0.85).delay(delay), value: progress)
    }
}

#Preview {
    ZStack {
        MYColor.brandSolid.ignoresSafeArea()
        BrandRings()
    }
}
