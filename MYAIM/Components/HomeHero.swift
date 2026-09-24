import SwiftUI

/// Distinctive Home hero: a layered gradient card with decorative shapes,
/// floating glass badges, bold Arabic typography and a clear CTA — far from
/// a plain text + icon banner.
struct HomeHero: View {
    var onCTA: (() -> Void)? = nil

    @State private var breathe = false
    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Decorative translucent circles
            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 190, height: 190)
                .offset(x: -60, y: -70)
            Circle()
                .stroke(.white.opacity(0.15), lineWidth: 1)
                .frame(width: 120, height: 120)
                .offset(x: 150, y: -160)
            Circle()
                .fill(.white.opacity(0.06))
                .frame(width: 80, height: 80)
                .offset(x: -130, y: 40)

            content
        }
        .frame(maxWidth: .infinity)
        .frame(height: 224)
        .background(
            RoundedRectangle(cornerRadius: MYRadius.xl, style: .continuous)
                .fill(LinearGradient(colors: [MYColor.primary,
                                              MYColor.primary.opacity(0.78),
                                              Color(hex: "#3B2E86")],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .clipShape(RoundedRectangle(cornerRadius: MYRadius.xl, style: .continuous))
        .myShadow(MYShadow.raised)
        .scaleEffect(breathe ? 1.01 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
                breathe = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 24)
    }

    // MARK: Content
    private var content: some View {
        HStack(alignment: .center, spacing: MYSpacing.md) {
            VStack(alignment: .leading, spacing: MYSpacing.sm) {
                Label("الأكثر حجزاً هذا الأسبوع", systemImage: "flame.fill")
                    .font(MYTypography.caption)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, MYSpacing.sm)
                    .padding(.vertical, MYSpacing.xxs)
                    .background(.white.opacity(0.16), in: Capsule())

                (Text("رحلتك نحو ")
                 + Text("تطوير ذاتك").bold()
                 + Text("\nتبدأ من هنا"))
                    .font(MYTypography.pageTitle)
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)

                Text("أكاديميات ومدربون موثوقون قريبون منك، بأسعار واضحة.")
                    .font(MYTypography.secondary)
                    .foregroundStyle(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    Haptics.light()
                    onCTA?()
                } label: {
                    HStack(spacing: MYSpacing.xs) {
                        Text("اكتشف الأكاديميات")
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .font(MYTypography.button)
                    .foregroundStyle(MYColor.primary)
                    .padding(.horizontal, MYSpacing.lg)
                    .padding(.vertical, MYSpacing.sm)
                    .background(.white, in: Capsule())
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.top, MYSpacing.xxs)
            }
            Spacer(minLength: 0)
        }
        .padding(MYSpacing.lg)
        .overlay(alignment: .topTrailing) { floatingBadges }
    }

    /// Floating glass mini-cards that give the hero depth.
    private var floatingBadges: some View {
        VStack(spacing: MYSpacing.sm) {
            glassBadge(icon: "star.fill", top: "4.9", bottom: "تقييم المشتركين")
                .offset(x: -6, y: breathe ? -4 : 4)
            glassBadge(icon: "checkmark.seal.fill", top: "موثّقة", bottom: "جهات معتمدة")
                .offset(x: -30, y: breathe ? 3 : -3)
        }
        .padding(.top, MYSpacing.sm)
        .animation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true), value: breathe)
    }

    private func glassBadge(icon: String, top: String, bottom: String) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: MYSpacing.xxs) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
                Text(top)
                    .font(MYTypography.cardTitle)
                    .foregroundStyle(.white)
            }
            Text(bottom)
                .font(MYTypography.caption)
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(MYSpacing.sm)
        .frame(width: 116)
        .background(.ultraThinMaterial.opacity(0.9), in: RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                .strokeBorder(.white.opacity(0.35), lineWidth: 0.5)
        )
    }
}

/// Compact "why" strip under the hero — three modern tiles instead of
/// a text paragraph.
struct HeroFeatureTiles: View {
    var onTap: (() -> Void)? = nil

    private let tiles: [(icon: String, title: String, subtitle: String)] = [
        ("checkmark.seal.fill", "موثوق", "جهات مراجعة"),
        ("tag.fill", "سعر واضح", "قبل الحجز"),
        ("bolt.fill", "حجز فوري", "بخطوات بسيطة")
    ]

    var body: some View {
        HStack(spacing: MYSpacing.sm) {
            ForEach(tiles, id: \.title) { tile in
                Button {
                    Haptics.selection()
                    onTap?()
                } label: {
                    VStack(spacing: MYSpacing.xxs) {
                        Image(systemName: tile.icon)
                            .font(.system(size: 17, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(MYColor.primary)
                        Text(tile.title)
                            .font(MYTypography.caption)
                            .foregroundStyle(MYColor.textPrimary)
                        Text(tile.subtitle)
                            .font(MYTypography.caption)
                            .foregroundStyle(MYColor.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, MYSpacing.md)
                    .background(MYColor.surface, in: RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous)
                            .strokeBorder(MYColor.border, lineWidth: 0.5)
                    )
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        HomeHero()
        HeroFeatureTiles()
    }
    .padding()
    .environment(\.layoutDirection, .rightToLeft)
    .environment(\.locale, Locale(identifier: "ar"))
}
