import SwiftUI

struct ProviderProfileView: View {
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    let provider: Provider

    private var services: [Service] {
        SampleData.services.filter { $0.providerId == provider.id }
    }
    private var reviews: [Review] { SampleData.reviews }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                cover
                infoBlock
                Divider().background(MYColor.border).padding(.horizontal, MYSpacing.screen)
                aboutSection
                servicesSection
                reviewsSection
            }
            .padding(.bottom, MYSpacing.xxxl)
        }
        .myScreenBackground()
        .ignoresSafeArea(edges: .top)
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.forward")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(MYColor.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding(.horizontal, MYSpacing.lg)
            .padding(.top, 54)
        }
    }

    private var cover: some View {
        MYRemoteImage(urlString: provider.coverURL,
                      fallbackIcon: provider.category.icon,
                      accent: provider.category.accent)
            .frame(height: 200)
            .clipped()
    }

    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            HStack(spacing: MYSpacing.md) {
                MYRemoteImage(urlString: provider.logoURL,
                              fallbackIcon: provider.category.icon,
                              accent: provider.category.accent)
                    .frame(width: 68, height: 68)
                    .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                        .strokeBorder(MYColor.surface, lineWidth: 3))
                    .offset(y: -34)

                Spacer()
            }
            .padding(.bottom, -28)

            HStack(spacing: MYSpacing.xs) {
                Text(provider.name)
                    .font(MYTypography.pageTitle)
                    .foregroundStyle(MYColor.textPrimary)
                if provider.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(MYColor.primary)
                }
            }
            Text(provider.tagline)
                .font(MYTypography.secondary)
                .foregroundStyle(MYColor.textSecondary)

            HStack(spacing: MYSpacing.md) {
                MYRating(rating: provider.rating, reviewsCount: provider.reviewsCount)
                HStack(spacing: MYSpacing.xxs) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 11)).foregroundStyle(MYColor.textTertiary)
                    Text(provider.location.city)
                        .font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
                }
            }
        }
        .padding(.horizontal, MYSpacing.screen)
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            Text("نبذة").font(MYTypography.section).foregroundStyle(MYColor.textPrimary)
            Text(provider.about)
                .font(MYTypography.body).foregroundStyle(MYColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, MYSpacing.screen)
    }

    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            Text("الخدمات").font(MYTypography.section).foregroundStyle(MYColor.textPrimary)
                .padding(.horizontal, MYSpacing.screen)
            if services.isEmpty {
                Text("لا توجد خدمات معروضة حاليًا.")
                    .font(MYTypography.secondary).foregroundStyle(MYColor.textSecondary)
                    .padding(.horizontal, MYSpacing.screen)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: MYSpacing.md) {
                        ForEach(services) { s in
                            MYServiceCard(service: s, onTap: { router.push(.serviceDetail(s)) })
                                .frame(width: 244)
                        }
                    }
                    .padding(.horizontal, MYSpacing.screen)
                }
            }
        }
    }

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            Text("آراء العملاء").font(MYTypography.section).foregroundStyle(MYColor.textPrimary)
            ForEach(reviews) { review in
                VStack(alignment: .leading, spacing: MYSpacing.xs) {
                    HStack {
                        Text(review.authorName)
                            .font(MYTypography.cardTitle).foregroundStyle(MYColor.textPrimary)
                        Spacer()
                        MYRating(rating: review.rating, showCount: false)
                    }
                    Text(review.comment)
                        .font(MYTypography.secondary).foregroundStyle(MYColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .myCard(padding: MYSpacing.md)
            }
        }
        .padding(.horizontal, MYSpacing.screen)
    }
}

#Preview {
    NavigationStack { ProviderProfileView(provider: SampleData.providers[0]) }
        .environment(Router())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
