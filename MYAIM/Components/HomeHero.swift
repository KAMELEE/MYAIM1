import SwiftUI

/// Realistic Home hero: a real photo banner with a gradient scrim,
/// clean typography and one clear CTA — like a real product's featured card.
struct HomeHero: View {
    var onCTA: (() -> Void)? = nil

    @State private var appeared = false

    var body: some View {
        Button {
            Haptics.light()
            onCTA?()
        } label: {
            ZStack(alignment: .bottomLeading) {
                if let asset = heroAsset {
                    Image(asset)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 210)
                        .clipped()
                }

                // Scrim keeps the text readable over the photo.
                LinearGradient(
                    colors: [.clear, .black.opacity(0.35), .black.opacity(0.72)],
                    startPoint: .top, endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: MYSpacing.xs) {
                    Text("مختارات هذا الأسبوع")
                        .font(MYTypography.caption)
                        .foregroundStyle(.white.opacity(0.85))

                    Text("أكاديميات ومدربون قريبون منك")
                        .font(MYTypography.pageTitle)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text("برامج موثوقة بأسعار واضحة، اختبرها بنفسك.")
                        .font(MYTypography.secondary)
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)

                    Text("اكتشف الآن")
                        .font(MYTypography.button)
                        .foregroundStyle(.white)
                        .padding(.horizontal, MYSpacing.lg)
                        .padding(.vertical, MYSpacing.sm)
                        .background(.white.opacity(0.22), in: Capsule())
                        .overlay(Capsule().strokeBorder(.white.opacity(0.45), lineWidth: 0.8))
                        .padding(.top, MYSpacing.xs)
                }
                .padding(MYSpacing.lg)
            }
            .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
            .myShadow(MYShadow.card)
        }
        .buttonStyle(PressableButtonStyle())
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.85).delay(0.08)) {
                appeared = true
            }
        }
        .accessibilityLabel("اكتشف الأكاديميات القريبة")
    }

    private var heroAsset: String? { "photo_sports" }
}

#Preview {
    HomeHero()
        .padding()
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
