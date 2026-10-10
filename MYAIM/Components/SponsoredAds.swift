import SwiftUI

/// A paid academy ad card — full width, photo background with a solid scrim,
/// «إعلان» tag, academy name, title and subtitle.
struct SponsoredAdCard: View {
    let ad: AcademyAd
    var onTap: () -> Void

    var body: some View {
        Button {
            Haptics.light()
            onTap()
        } label: {
            ZStack(alignment: .bottomLeading) {
                background
                LinearGradient(colors: [.black.opacity(0.0), .black.opacity(0.72)],
                               startPoint: .top, endPoint: .bottom)
                VStack(alignment: .leading, spacing: 4) {
                    Text(ad.providerName)
                        .font(MYTypography.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)
                    Text(ad.title)
                        .font(MYTypography.section)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(ad.subtitle)
                        .font(MYTypography.caption)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .padding(MYSpacing.lg)
            }
            .frame(height: 176)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
            .overlay(alignment: .topLeading) {
                HStack(spacing: 4) {
                    Image(systemName: "megaphone.fill").font(.system(size: 10, weight: .bold))
                    Text("إعلان").font(.appFont(11, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(ad.accent, in: Capsule())
                .padding(MYSpacing.md)
            }
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("إعلان: \(ad.title) — \(ad.providerName)")
    }

    @ViewBuilder
    private var background: some View {
        if let asset = ad.imageAsset, UIImage(named: asset) != nil {
            Image(asset).resizable().scaledToFill()
        } else {
            ad.accent
        }
    }
}

/// Auto-advancing carousel of live paid ads — the first block on the
/// trainees' Home. Hidden when there are no live ads.
struct SponsoredAdsCarousel: View {
    let ads: [AcademyAd]
    var onTap: (AcademyAd) -> Void

    @State private var index = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if !ads.isEmpty {
            VStack(spacing: MYSpacing.sm) {
                TabView(selection: $index) {
                    ForEach(Array(ads.enumerated()), id: \.element.id) { i, ad in
                        SponsoredAdCard(ad: ad) { onTap(ad) }
                            .padding(.horizontal, MYSpacing.screen)
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 176)

                if ads.count > 1 {
                    HStack(spacing: 6) {
                        ForEach(ads.indices, id: \.self) { i in
                            Capsule()
                                .fill(i == index ? MYColor.primary : MYColor.border)
                                .frame(width: i == index ? 18 : 6, height: 6)
                        }
                    }
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: index)
                }
            }
            .padding(.horizontal, -MYSpacing.screen)
            .task(id: ads.count) {
                guard ads.count > 1, !reduceMotion else { return }
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(4.5))
                    withAnimation(.easeInOut(duration: 0.5)) { index = (index + 1) % ads.count }
                }
            }
        }
    }
}

#Preview {
    SponsoredAdsCarousel(ads: [
        AcademyAd(title: "خصم ٣٠٪ على الاشتراك الشهري", subtitle: "برامج لياقة بإشراف مدربين",
                  providerName: "أكاديمية النخبة الرياضية", imageAsset: "photo_sports",
                  accentHex: "#E0533D")
    ], onTap: { _ in })
    .padding()
    .environment(\.layoutDirection, .rightToLeft)
}
