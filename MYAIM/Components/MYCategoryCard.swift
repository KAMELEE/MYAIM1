import SwiftUI

/// Horizontal category card for the "استكشف الأقسام" row.
/// Sized so ~2–2.5 cards are visible on an iPhone.
struct MYCategoryCard: View {
    let category: ServiceCategory
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            Haptics.light()
            onTap?()
        } label: {
            ZStack(alignment: .bottomLeading) {
                MYRemoteImage(assetName: category.imageName,
                              fallbackIcon: category.icon,
                              accent: category.accent)
                    .frame(width: 150, height: 100)

                // Solid legibility scrim (not a decorative glow) at the bottom.
                Rectangle()
                    .fill(Color.black.opacity(0.28))
                    .frame(width: 150, height: 100)

                HStack(spacing: MYSpacing.xs) {
                    Image(systemName: category.icon)
                        .font(.system(size: 13, weight: .semibold))
                    Text(category.title)
                        .font(MYTypography.caption)
                        .lineLimit(1)
                }
                .foregroundStyle(.white)
                .padding(MYSpacing.sm)
            }
            .frame(width: 150, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(category.title)
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: MYSpacing.md) {
            ForEach(ServiceCategory.allCases) { MYCategoryCard(category: $0) }
        }
        .padding()
    }
    .environment(\.layoutDirection, .rightToLeft)
}
