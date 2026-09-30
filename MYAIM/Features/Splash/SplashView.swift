import SwiftUI

/// Branded launch splash shown once on cold start, before the app content.
///
/// Solid brand color only — no gradients/glow (per brand guidelines). The
/// animation is a controlled, staged reveal: the logo tile springs in, the
/// wordmark and tagline rise and fade, and a slim progress bar fills, then the
/// whole splash cross-fades to the app.
struct SplashView: View {
    /// Called once the intro finishes so the coordinator can reveal the app.
    var onFinished: () -> Void

    @State private var tileIn = false      // logo tile scale/opacity
    @State private var textIn = false      // wordmark + tagline
    @State private var progress: CGFloat = 0
    @State private var leaving = false      // fade/scale the whole splash out

    // Reduce motion → skip the staged animation, respect the user's setting.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            MYColor.primary.ignoresSafeArea()

            VStack(spacing: MYSpacing.xl) {
                Spacer()

                logoTile
                    .scaleEffect(tileIn ? 1 : 0.72)
                    .opacity(tileIn ? 1 : 0)

                VStack(spacing: MYSpacing.xs) {
                    Text("MY AIM")
                        .font(.appFont(30, weight: .bold))
                        .foregroundStyle(.white)
                        .tracking(2)
                    Text("رحلتك نحو تطوير ذاتك تبدأ من هنا")
                        .font(MYTypography.secondary)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .opacity(textIn ? 1 : 0)
                .offset(y: textIn ? 0 : 12)

                Spacer()

                progressBar
                    .padding(.bottom, MYSpacing.xxxl)
                    .opacity(textIn ? 1 : 0)
            }
            .padding(.horizontal, MYSpacing.xl)
        }
        .opacity(leaving ? 0 : 1)
        .scaleEffect(leaving ? 1.04 : 1)
        .task { await run() }
    }

    private var logoTile: some View {
        Image("Logo")
            .resizable()
            .scaledToFit()
            .padding(22)
            .frame(width: 116, height: 116)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.18), radius: 22, x: 0, y: 10)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.25))
                Capsule().fill(.white)
                    .frame(width: geo.size.width * progress)
            }
        }
        .frame(width: 140, height: 4)
        .frame(maxWidth: .infinity)
    }

    @MainActor
    private func run() async {
        if reduceMotion {
            tileIn = true; textIn = true; progress = 1
            try? await Task.sleep(nanoseconds: 700_000_000)
            onFinished()
            return
        }

        withAnimation(.spring(response: 0.55, dampingFraction: 0.68)) { tileIn = true }
        try? await Task.sleep(nanoseconds: 260_000_000)
        withAnimation(.easeOut(duration: 0.45)) { textIn = true }
        withAnimation(.easeInOut(duration: 1.15)) { progress = 1 }

        try? await Task.sleep(nanoseconds: 1_350_000_000)
        withAnimation(.easeIn(duration: 0.35)) { leaving = true }
        try? await Task.sleep(nanoseconds: 360_000_000)
        onFinished()
    }
}

#Preview {
    SplashView(onFinished: {})
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
