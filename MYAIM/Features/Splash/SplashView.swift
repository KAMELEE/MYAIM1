import SwiftUI

/// Branded launch splash (direction «ب — جريء بالهوية»).
///
/// Solid logo violet, the concentric-rings motif, white logo + wordmark and
/// a short marketplace tagline. Matches the launch-screen color, so iOS's
/// static launch → splash hand-off is seamless. Short on purpose (~0.9s):
/// nothing is loading here, so the user isn't kept waiting.
struct SplashView: View {
    /// Called once the intro finishes so the coordinator can reveal the app.
    var onFinished: () -> Void

    @State private var ringsIn: CGFloat = 0
    @State private var logoIn = false
    @State private var textIn = false
    @State private var leaving = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geo in
            ZStack {
                MYColor.brandSolid.ignoresSafeArea()

                BrandRings(size: geo.size.width * 1.95, progress: ringsIn)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.5)

                VStack(spacing: 22) {
                    Image("LogoWhite")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 128)
                        .accessibilityLabel("MY AIM")
                    Text(verbatim: "MY AIM")
                        .font(.appFont(22, weight: .bold))
                        .tracking(8)
                        .foregroundStyle(.white)
                        .environment(\.layoutDirection, .leftToRight)
                        .accessibilityHidden(true)
                }
                .scaleEffect(logoIn ? 1 : 0.86)
                .opacity(logoIn ? 1 : 0)

                VStack(spacing: 6) {
                    Spacer()
                    Text("اكتشف. قارن. احجز.")
                        .font(.appFont(20, weight: .bold))
                        .foregroundStyle(.white)
                    Text("أكاديميات ومدرّبون لكل مهارة")
                        .font(MYTypography.secondary)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, MYSpacing.xl)
                .padding(.bottom, 64)
                .opacity(textIn ? 1 : 0)
                .offset(y: textIn ? 0 : 10)
            }
        }
        .opacity(leaving ? 0 : 1)
        .task { await run() }
    }

    @MainActor
    private func run() async {
        if reduceMotion {
            ringsIn = 1; logoIn = true; textIn = true
            try? await Task.sleep(for: .milliseconds(500))
            onFinished()
            return
        }
        ringsIn = 1
        withAnimation(.spring(response: 0.5, dampingFraction: 0.72)) { logoIn = true }
        try? await Task.sleep(for: .milliseconds(180))
        withAnimation(.easeOut(duration: 0.35)) { textIn = true }
        try? await Task.sleep(for: .milliseconds(520))
        #if DEBUG
        // CI captures the splash itself: keep it on screen.
        if ProcessInfo.processInfo.arguments.contains("-holdSplash") { return }
        #endif
        withAnimation(.easeIn(duration: 0.22)) { leaving = true }
        try? await Task.sleep(for: .milliseconds(220))
        onFinished()
    }
}

#Preview {
    SplashView(onFinished: {})
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
