import SwiftUI

/// Compact provider row/card: logo, name, verified badge, rating, location.
struct MYProviderCard: View {
    let provider: Provider
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            Haptics.light()
            onTap?()
        } label: {
            HStack(spacing: MYSpacing.md) {
                MYRemoteImage(assetName: provider.category.imageName,
                              urlString: provider.logoURL,
                              fallbackIcon: provider.category.icon,
                              accent: provider.category.accent)
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: MYRadius.sm, style: .continuous))

                VStack(alignment: .leading, spacing: MYSpacing.xxs) {
                    HStack(spacing: MYSpacing.xs) {
                        Text(provider.name)
                            .font(MYTypography.cardTitle)
                            .foregroundStyle(MYColor.textPrimary)
                            .lineLimit(1)
                        if provider.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(MYColor.primary)
                        }
                    }
                    Text(provider.tagline)
                        .font(MYTypography.description)
                        .foregroundStyle(MYColor.textSecondary)
                        .lineLimit(1)
                    HStack(spacing: MYSpacing.sm) {
                        MYRating(rating: provider.rating, reviewsCount: provider.reviewsCount)
                        Text("· \(provider.location.city)")
                            .font(MYTypography.caption)
                            .foregroundStyle(MYColor.textSecondary)
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.forward")   // layout-aware: points to trailing edge in RTL/LTR
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(MYColor.textTertiary)
            }
            .myCard(padding: MYSpacing.md)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(SampleData.providers) { MYProviderCard(provider: $0) }
    }
    .padding()
    .myScreenBackground()
    .environment(\.layoutDirection, .rightToLeft)
}
