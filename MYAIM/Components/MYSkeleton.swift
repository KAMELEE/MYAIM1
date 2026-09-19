import SwiftUI

/// A subtle shimmering placeholder block used for skeleton loading states.
struct MYSkeleton: View {
    var cornerRadius: CGFloat = MYRadius.sm
    @State private var phase: CGFloat = -1

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(MYColor.surfaceSecondary)
            .overlay(shimmer.mask(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            ))
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 2
                }
            }
    }

    private var shimmer: some View {
        GeometryReader { geo in
            let width = geo.size.width
            LinearGradient(
                colors: [.clear, MYColor.surface.opacity(0.55), .clear],
                startPoint: .leading, endPoint: .trailing
            )
            .frame(width: width * 0.6)
            .offset(x: width * phase)
        }
    }
}

/// A convenience modifier that redacts + shimmers a view while `isLoading`.
extension View {
    @ViewBuilder
    func mySkeleton(_ isLoading: Bool) -> some View {
        if isLoading {
            self.redacted(reason: .placeholder)
                .overlay(MYSkeleton().opacity(0.0)) // keeps animation timing warm
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
