import SwiftUI

/// The unified service card (grid + horizontal friendly).
/// Layout: image + corner badge, name, provider, rating · location,
/// then a footer row with the price and a circular quick-action (favorite).
struct MYServiceCard: View {
    let service: Service
    var isNew: Bool = false
    var isFavorite: Bool = false
    var onFavorite: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil

    private let actionSize: CGFloat = 38

    var body: some View {
        // Favorite is overlaid as a SIBLING of the tap button (avoids nested-button
        // hit-testing issues) and aligns into the reserved footer space.
        Button {
            Haptics.light()
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                imageHeader
                info
            }
            .background(MYColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous)
                    .strokeBorder(MYColor.border, lineWidth: 0.5)
            )
            .myShadow()
        }
        .buttonStyle(PressableButtonStyle())
        .overlay(alignment: .bottomTrailing) {
            if let onFavorite {
                favoriteButton(onFavorite)
                    .padding(MYSpacing.md)
            }
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Image + badge
    private var imageHeader: some View {
        MYRemoteImage(urlString: service.imageURL,
                      fallbackIcon: service.category.icon,
                      accent: service.category.accent)
            .frame(height: 120)
            .clipped()
            .overlay(alignment: .topLeading) {
                MYTag(text: isNew ? "جديد" : service.category.title,
                      style: isNew ? .success : .brand)
                    .padding(MYSpacing.sm)
            }
    }

    // MARK: - Text + footer
    private var info: some View {
        VStack(alignment: .leading, spacing: MYSpacing.xs) {
            Text(service.title)
                .font(MYTypography.cardTitle)
                .foregroundStyle(MYColor.textPrimary)
                .lineLimit(1)

            Text(service.providerName)
                .font(MYTypography.description)
                .foregroundStyle(MYColor.textSecondary)
                .lineLimit(1)

            HStack(spacing: MYSpacing.sm) {
                MYRating(rating: service.rating, showCount: false)
                HStack(spacing: MYSpacing.xxs) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 10))
                        .foregroundStyle(MYColor.textTertiary)
                    Text(locationText)
                        .font(MYTypography.caption)
                        .foregroundStyle(MYColor.textSecondary)
                        .lineLimit(1)
                }
            }
            .padding(.top, MYSpacing.xxs)

            // Footer: price + reserved space for the overlaid circular button.
            HStack(alignment: .bottom) {
                MYPrice(amount: service.startingPrice)
                Spacer(minLength: MYSpacing.sm)
                Color.clear.frame(width: actionSize, height: actionSize)
            }
            .padding(.top, MYSpacing.xs)
        }
        .padding(MYSpacing.md)
    }

    private var locationText: String {
        if let d = service.distanceMeters {
            return "\(service.location.city) · \(MYFormat.distance(d))"
        }
        return service.location.city
    }

    // MARK: - Circular favorite action
    private func favoriteButton(_ action: @escaping () -> Void) -> some View {
        Button {
            Haptics.medium()
            action()
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: actionSize, height: actionSize)
                .background(MYColor.primary)
                .clipShape(Circle())
                .scaleEffect(isFavorite ? 1.08 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFavorite)
        }
        .accessibilityLabel(isFavorite ? "إزالة من المفضلة" : "إضافة إلى المفضلة")
    }
}

#Preview {
    ScrollView {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 13),
                            GridItem(.flexible(), spacing: 13)], spacing: 13) {
            MYServiceCard(service: SampleData.services[0], isFavorite: true, onFavorite: {}, onTap: {})
            MYServiceCard(service: SampleData.services[3], isNew: true, onFavorite: {}, onTap: {})
            MYServiceCard(service: SampleData.services[1], onFavorite: {}, onTap: {})
            MYServiceCard(service: SampleData.services[2], onFavorite: {}, onTap: {})
        }
        .padding()
    }
    .myScreenBackground()
    .environment(\.layoutDirection, .rightToLeft)
    .environment(\.locale, Locale(identifier: "ar"))
}
