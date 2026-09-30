import SwiftUI

/// A subtle shimmering placeholder block used for skeleton loading states.
///
/// All skeletons share one global, time-driven phase (via `TimelineView`) so
/// every placeholder on screen shimmers in perfect sync. Per-view `onAppear`
/// timers would each start at a slightly different moment, making a grid of
/// skeletons flicker out of phase — which reads as random, jittery movement.
struct MYSkeleton: View {
    var cornerRadius: CGFloat = MYRadius.sm

    /// One shimmer sweep every `period` seconds, shared by all instances.
    private let period: Double = 1.4

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(MYColor.surfaceSecondary)
            .overlay(
                TimelineView(.animation) { timeline in
                    shimmer(at: timeline.date)
                        .mask(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private func shimmer(at date: Date) -> some View {
        // Deterministic 0...1 progress from a shared clock → identical for every skeleton.
        let t = date.timeIntervalSinceReferenceDate
        let progress = (t.truncatingRemainder(dividingBy: period)) / period   // 0 → 1
        return GeometryReader { geo in
            let width = geo.size.width
            LinearGradient(
                colors: [.clear, MYColor.surface.opacity(0.6), .clear],
                startPoint: .leading, endPoint: .trailing
            )
            .frame(width: width * 0.6)
            // Sweep from just off the leading edge to just past the trailing edge.
            .offset(x: -width * 0.6 + (width * 1.6) * progress)
        }
    }
}

/// A convenience modifier that redacts + shimmers a view while `isLoading`.
extension View {
    @ViewBuilder
    func mySkeleton(_ isLoading: Bool) -> some View {
        if isLoading {
            self.redacted(reason: .placeholder)
        } else {
            self
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        MYSkeleton().frame(height: 120)
        MYSkeleton().frame(width: 160, height: 16)
        MYSkeleton().frame(width: 100, height: 14)
    }
    .padding()
}
