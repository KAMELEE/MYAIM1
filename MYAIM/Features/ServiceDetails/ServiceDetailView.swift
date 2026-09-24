import SwiftUI

/// Service details. A working, well-structured screen; richer sections
/// (reviews, similar services, availability) are expanded in Phase 8.
struct ServiceDetailView: View {
    let service: Service

    @Environment(Router.self) private var router
    @Environment(FavoritesStore.self) private var favorites
    @Environment(\.dismiss) private var dismiss

    private var isFavorite: Bool { favorites.contains(service.id) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                header
                titleBlock
                Divider().background(MYColor.border)
                aboutSection
                includesSection
                locationSection
                reviewsSection
                similarSection
            }
            .padding(.bottom, MYSpacing.xxxl)
        }
        .myScreenBackground()
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom) { bookBar }
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .topLeading) { topControls }
    }

    // MARK: Header image
    private var header: some View {
        MYRemoteImage(assetName: service.category.imageName,
                      urlString: service.imageURL,
                      fallbackIcon: service.category.icon,
                      accent: service.category.accent)
            .frame(height: 280)
            .clipped()
            .overlay(alignment: .bottomLeading) {
                MYTag(text: service.category.title, style: .brand)
                    .padding(MYSpacing.lg)
            }
    }

    // MARK: Floating back / favorite / share
    private var topControls: some View {
        HStack {
            circleButton("chevron.forward") { dismiss() }
            Spacer()
            HStack(spacing: MYSpacing.sm) {
                circleButton("square.and.arrow.up") {}
                circleButton(isFavorite ? "heart.fill" : "heart",
                             tint: isFavorite ? MYColor.error : MYColor.textPrimary) {
                    Haptics.medium()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        favorites.toggle(service.id)
                    }
                }
            }
        }
        .padding(.horizontal, MYSpacing.lg)
        .padding(.top, 54)
    }

    private func circleButton(_ icon: String,
                              tint: Color = MYColor.textPrimary,
                              action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Circle())
        }
    }

    // MARK: Title / provider / rating / price
    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            Text(service.title)
                .font(MYTypography.pageTitle)
                .foregroundStyle(MYColor.textPrimary)

            Button {
                if let provider = SampleData.providers.first(where: { $0.id == service.providerId }) {
                    router.push(.providerProfile(provider))
                }
            } label: {
                HStack(spacing: MYSpacing.xs) {
                    Text(service.providerName)
                        .font(MYTypography.secondary)
                        .foregroundStyle(MYColor.primary)
                    if service.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(MYColor.primary)
                    }
                }
            }

            HStack(spacing: MYSpacing.md) {
                MYRating(rating: service.rating, reviewsCount: service.reviewsCount)
                HStack(spacing: MYSpacing.xxs) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 11))
                        .foregroundStyle(MYColor.textTertiary)
                    Text(locationText)
                        .font(MYTypography.caption)
                        .foregroundStyle(MYColor.textSecondary)
                }
            }
        }
        .padding(.horizontal, MYSpacing.screen)
    }

    private var locationText: String {
        if let d = service.distanceMeters {
            return "\(service.location.city) · \(MYFormat.distance(d))"
        }
        return service.location.city
    }

    // MARK: Sections
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            Text("عن الخدمة")
                .font(MYTypography.section)
                .foregroundStyle(MYColor.textPrimary)
            Text(service.summary)
                .font(MYTypography.body)
                .foregroundStyle(MYColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, MYSpacing.screen)
    }

    private var includesSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            Text("ماذا ستحصل عليه")
                .font(MYTypography.section)
                .foregroundStyle(MYColor.textPrimary)
            ForEach(includes, id: \.self) { item in
                HStack(spacing: MYSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(MYColor.primary)
                    Text(item)
                        .font(MYTypography.body)
                        .foregroundStyle(MYColor.textPrimary)
                }
            }
        }
        .padding(.horizontal, MYSpacing.screen)
    }

    private var includes: [String] {
        ["خطة مخصّصة حسب مستواك", "متابعة دورية مع المدرب", "شهادة إتمام معتمدة", "دعم مباشر عبر التطبيق"]
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            Text("الموقع")
                .font(MYTypography.section)
                .foregroundStyle(MYColor.textPrimary)
            HStack(spacing: MYSpacing.sm) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(MYColor.primary)
                Text([service.location.district, service.location.city].compactMap { $0 }.joined(separator: "، "))
                    .font(MYTypography.body)
                    .foregroundStyle(MYColor.textSecondary)
            }
        }
        .padding(.horizontal, MYSpacing.screen)
    }

    // MARK: Reviews
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            HStack {
                Text("آراء العملاء")
                    .font(MYTypography.section)
                    .foregroundStyle(MYColor.textPrimary)
                Spacer()
                MYRating(rating: service.rating, reviewsCount: service.reviewsCount)
            }
            ForEach(SampleData.reviews) { review in
                VStack(alignment: .leading, spacing: MYSpacing.xs) {
                    HStack {
                        Text(review.authorName)
                            .font(MYTypography.cardTitle)
                            .foregroundStyle(MYColor.textPrimary)
                        Spacer()
                        MYRating(rating: review.rating, showCount: false)
                    }
                    Text(review.comment)
                        .font(MYTypography.secondary)
                        .foregroundStyle(MYColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .myCard(padding: MYSpacing.md)
            }
        }
        .padding(.horizontal, MYSpacing.screen)
    }

    // MARK: Similar services
    private var similar: [Service] {
        SampleData.services.filter { $0.category == service.category && $0.id != service.id }
    }

    @ViewBuilder
    private var similarSection: some View {
        if !similar.isEmpty {
            VStack(alignment: .leading, spacing: MYSpacing.md) {
                Text("خدمات مشابهة")
                    .font(MYTypography.section)
                    .foregroundStyle(MYColor.textPrimary)
                    .padding(.horizontal, MYSpacing.screen)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: MYSpacing.md) {
                        ForEach(similar) { s in
                            MYServiceCard(service: s, onTap: { router.push(.serviceDetail(s)) })
                                .frame(width: 244)
                        }
                    }
                    .padding(.horizontal, MYSpacing.screen)
                }
            }
        }
    }

    // MARK: Sticky book bar
    private var bookBar: some View {
        HStack(spacing: MYSpacing.lg) {
            VStack(alignment: .leading, spacing: 0) {
                Text("السعر")
                    .font(MYTypography.caption)
                    .foregroundStyle(MYColor.textSecondary)
                Text(MYFormat.price(service.startingPrice))
                    .font(MYTypography.cardTitle)
                    .foregroundStyle(MYColor.textPrimary)
            }
            MYButton(title: "احجز الآن", icon: "calendar") {
                router.push(.booking(service))
            }
        }
        .padding(MYSpacing.lg)
        .background(.regularMaterial)
        .overlay(alignment: .top) { Divider() }
        .myTabBarClearance()
    }
}

#Preview {
    NavigationStack {
        ServiceDetailView(service: SampleData.services[0])
            .environment(Router())
            .environment(FavoritesStore())
    }
    .environment(\.layoutDirection, .rightToLeft)
    .environment(\.locale, Locale(identifier: "ar"))
}
