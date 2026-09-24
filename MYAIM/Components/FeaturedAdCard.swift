import SwiftUI

/// A featured-academy ad card for the Home feed: real photo, colored edge,
/// title + subtitle. Tapping opens the featured list.
struct FeaturedAdCard: View {
    let ad: AcademyAd
    var onTap: () -> Void

    var body: some View {
        Button {
            Haptics.light()
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                if let asset = ad.imageAsset {
                    Image(asset)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 244, height: 118)
                        .clipped()
                }

                VStack(alignment: .leading, spacing: MYSpacing.xxs) {
                    Text(ad.providerName)
                        .font(MYTypography.caption)
                        .foregroundStyle(ad.accent)
                        .lineLimit(1)
                    Text(ad.title)
                        .font(MYTypography.cardTitle)
                        .foregroundStyle(MYColor.textPrimary)
                        .lineLimit(1)
                    Text(ad.subtitle)
                        .font(MYTypography.caption)
                        .foregroundStyle(MYColor.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .padding(MYSpacing.md)
            }
            .frame(width: 244, alignment: .leading)
            .background(MYColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous)
                    .strokeBorder(MYColor.border, lineWidth: 0.5)
            )
            .overlay(alignment: .topLeading) {
                MYTag(text: "إعلان", style: .brand)
                    .padding(MYSpacing.sm)
            }
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(ad.title)
    }
}

#Preview {
    FeaturedAdCard(
        ad: AcademyAd(title: "خصم ٣٠٪", subtitle: "برامج لياقة بإشراف مدربين",
                      providerName: "أكاديمية النخبة الرياضية",
                      imageAsset: "photo_sports", accentHex: "#E0533D")
    ) {}
    .padding()
    .environment(\.layoutDirection, .rightToLeft)
}
