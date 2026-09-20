import SwiftUI

/// Auto-advancing hero carousel for the Home screen.
/// Supports feature (photo), discount-code, and "why us" slides, with swipe,
/// page dots, and a gentle auto-advance every few seconds.
struct MYHeroCarousel: View {
    let slides: [HeroSlide]
    var height: CGFloat = 206
    var onFeatureTap: (() -> Void)? = nil

    @State private var index: Int = 0
    private let timer = Timer.publish(every: 4.5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: MYSpacing.sm) {
            TabView(selection: $index) {
                ForEach(Array(slides.enumerated()), id: \.element.id) { i, slide in
                    slideView(slide)
                        .tag(i)
                        .padding(.horizontal, 1) // avoid clipping the card shadow
                }
            }
            .frame(height: height)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onReceive(timer) { _ in
                #if DEBUG
                if ProcessInfo.processInfo.arguments.contains("-demoMode") { return } // freeze for CI capture
                #endif
                guard slides.count > 1 else { return }
                withAnimation(.easeInOut(duration: 0.5)) {
                    index = (index + 1) % slides.count
                }
            }

            pageDots
        }
    }

    // MARK: - Dots
    private var pageDots: some View {
        HStack(spacing: MYSpacing.xs) {
            ForEach(slides.indices, id: \.self) { i in
                Capsule()
                    .fill(i == index ? MYColor.primary : MYColor.border)
                    .frame(width: i == index ? 18 : 6, height: 6)
                    .animation(.easeOut(duration: 0.25), value: index)
            }
        }
    }

    // MARK: - Slide routing
    @ViewBuilder
    private func slideView(_ slide: HeroSlide) -> some View {
        switch slide {
        case let .brandHero(_, title, accent, subtitle, actionTitle):
            BrandHeroSlide(title: title, accent: accent, subtitle: subtitle,
                           actionTitle: actionTitle, onTap: onFeatureTap)
        case let .feature(_, title, subtitle, imageURL, actionTitle):
            FeatureSlide(title: title, subtitle: subtitle, imageURL: imageURL,
                         actionTitle: actionTitle, onTap: onFeatureTap)
        case let .discount(_, code, title, subtitle):
            DiscountSlide(code: code, title: title, subtitle: subtitle)
        case let .whyUs(_, title, points):
            WhyUsSlide(title: title, points: points)
        }
    }
}

// MARK: - Feature slide (photo)

private struct FeatureSlide: View {
    let title: String
    let subtitle: String
    let imageURL: String
    let actionTitle: String
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            Haptics.light()
            onTap?()
        } label: {
            ZStack(alignment: .bottomLeading) {
                MYRemoteImage(assetName: "photo_hero", urlString: imageURL,
                              fallbackIcon: "photo", accent: MYColor.primary)
                    .frame(maxWidth: .infinity)

                // Solid legibility scrim (not a glow).
                Rectangle().fill(Color.black.opacity(0.38))

                VStack(alignment: .leading, spacing: MYSpacing.xs) {
                    Text(title)
                        .font(MYTypography.section)
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(MYTypography.description)
                        .foregroundStyle(.white.opacity(0.9))
                    Text(actionTitle)
                        .font(.appFont(13, weight: .bold))
                        .foregroundStyle(MYColor.primary)
                        .padding(.horizontal, MYSpacing.md)
                        .padding(.vertical, MYSpacing.sm)
                        .background(.white)
                        .clipShape(Capsule())
                        .padding(.top, MYSpacing.xs)
                }
                .padding(MYSpacing.lg)
            }
            .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - Branded intro hero (lavender + floating icons)

private struct BrandHeroSlide: View {
    let title: String
    let accent: String
    let subtitle: String
    let actionTitle: String
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            Haptics.light()
            onTap?()
        } label: {
            HStack(spacing: MYSpacing.sm) {
                VStack(alignment: .leading, spacing: MYSpacing.xs) {
                    Text(title)
                        .font(.appFont(19, weight: .bold))
                        .foregroundStyle(MYColor.textPrimary)
                    Text(accent)
                        .font(.appFont(19, weight: .bold))
                        .foregroundStyle(MYColor.primary)
                    Text(subtitle)
                        .font(MYTypography.description)
                        .foregroundStyle(MYColor.textSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, MYSpacing.xxs)
                    Text(actionTitle)
                        .font(.appFont(13, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, MYSpacing.lg)
                        .padding(.vertical, MYSpacing.sm)
                        .background(MYColor.primary)
                        .clipShape(Capsule())
                        .padding(.top, MYSpacing.xs)
                }
                Spacer(minLength: 0)
                iconCluster
            }
            .padding(MYSpacing.lg)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(MYColor.primaryTint)
            .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var iconCluster: some View {
        ZStack {
            tile("brain.head.profile", size: 52).offset(x: -6, y: -44)
            tile("graduationcap.fill", size: 46).offset(x: 26, y: -6)
            tile("dumbbell.fill", size: 44).offset(x: -20, y: 30)
            tile("target", size: 50).offset(x: 20, y: 56)
        }
        .frame(width: 96)
    }

    private func tile(_ icon: String, size: CGFloat) -> some View {
        Image(systemName: icon)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(MYColor.primary)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.3, style: .continuous))
            .myShadow(MYShadow.raised)
    }
}

// MARK: - Discount slide (copyable code)

private struct DiscountSlide: View {
    let code: String
    let title: String
    let subtitle: String
    @State private var copied = false

    var body: some View {
        HStack(spacing: MYSpacing.lg) {
            VStack(alignment: .leading, spacing: MYSpacing.xs) {
                MYTag(text: "عرض خاص", icon: "sparkles", style: .brand)
                Text(title)
                    .font(MYTypography.section)
                    .foregroundStyle(MYColor.textPrimary)
                Text(subtitle)
                    .font(MYTypography.description)
                    .foregroundStyle(MYColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            // Ticket-style code with copy.
            Button {
                UIPasteboard.general.string = code
                Haptics.success()
                withAnimation { copied = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    withAnimation { copied = false }
                }
            } label: {
                VStack(spacing: MYSpacing.xs) {
                    Text("كود الخصم")
                        .font(MYTypography.caption)
                        .foregroundStyle(MYColor.textSecondary)
                    Text(code)
                        .font(.appFont(20, weight: .bold))
                        .foregroundStyle(MYColor.primary)
                    HStack(spacing: MYSpacing.xxs) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 11, weight: .semibold))
                        Text(copied ? "تم النسخ" : "نسخ")
                            .font(MYTypography.caption)
                    }
                    .foregroundStyle(copied ? MYColor.success : MYColor.primary)
                }
                .padding(.vertical, MYSpacing.md)
                .padding(.horizontal, MYSpacing.lg)
                .background(MYColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.2, dash: [5, 4]))
                        .foregroundStyle(MYColor.primary.opacity(0.5))
                )
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("انسخ كود الخصم \(code)")
        }
        .padding(MYSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(MYColor.primaryTint)
        .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
    }
}

// MARK: - Why us slide

private struct WhyUsSlide: View {
    let title: String
    let points: [WhyUsPoint]

    var body: some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            Text(title)
                .font(MYTypography.section)
                .foregroundStyle(MYColor.textPrimary)

            // Two-column compact grid of benefits.
            LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading),
                                GridItem(.flexible(), alignment: .leading)],
                      spacing: MYSpacing.sm) {
                ForEach(points) { point in
                    HStack(spacing: MYSpacing.sm) {
                        Image(systemName: point.icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(MYColor.primary)
                            .frame(width: 26, height: 26)
                            .background(MYColor.surface)
                            .clipShape(RoundedRectangle(cornerRadius: MYRadius.xs, style: .continuous))
                        Text(point.text)
                            .font(MYTypography.description)
                            .foregroundStyle(MYColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(MYSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(MYColor.primaryTint)
        .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
    }
}

#Preview {
    MYHeroCarousel(slides: SampleData.heroSlides)
        .padding()
        .myScreenBackground()
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
