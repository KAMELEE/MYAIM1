import SwiftUI

/// Academy tab «الإعلانات»: buy paid ads (shown first on the trainees'
/// Home) and track their status.
struct ProviderAdsView: View {
    @Environment(Router.self) private var router
    @Environment(FeaturedStore.self) private var featured

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.md) {
                promoHeader
                MYButton(title: "إعلان مدفوع جديد", icon: "plus.circle.fill") {
                    router.push(.publishAd)
                }
                if featured.myAds.isEmpty {
                    MYEmptyState(icon: "megaphone", title: "لا إعلانات بعد",
                                 message: "أعلن عن دوراتك وعروضك ليظهر إعلانك أول شيء في رئيسية المتدربين.")
                        .padding(.top, MYSpacing.lg)
                } else {
                    MYSectionHeader(title: "إعلاناتي", actionTitle: nil)
                    ForEach(featured.myAds) { ad in
                        adRow(ad)
                            .myAppear(item: ad, in: featured.myAds)
                    }
                }
            }
            .padding(MYSpacing.screen)
        }
        .myTabBarInset()
        .myScreenBackground()
        .navigationTitle("الإعلانات")
        .navigationBarTitleDisplayMode(.inline)
        .task { await featured.reload() }
        .refreshable { await featured.reload() }
    }

    /// Why advertise — short value pitch.
    private var promoHeader: some View {
        HStack(alignment: .top, spacing: MYSpacing.md) {
            Image(systemName: "sparkles.rectangle.stack.fill")
                .font(.system(size: 22))
                .foregroundStyle(MYColor.primary)
                .frame(width: 46, height: 46)
                .background(MYColor.primaryTint)
                .clipShape(RoundedRectangle(cornerRadius: MYRadius.sm, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text("إعلانك أول شيء يشوفه المتدرب")
                    .font(MYTypography.cardTitle).foregroundStyle(MYColor.textPrimary)
                Text("يظهر في أعلى الرئيسية لكل المتدربين طوال مدة الباقة — من \(MYFormat.price(AdPackage.week.price)) للأسبوع.")
                    .font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .myCard(padding: MYSpacing.md)
    }

    private func adRow(_ ad: AcademyAd) -> some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            HStack(alignment: .top, spacing: MYSpacing.md) {
                MYRemoteImage(assetName: ad.imageAsset, accent: ad.accent)
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: MYRadius.sm, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text(ad.title)
                        .font(MYTypography.cardTitle).foregroundStyle(MYColor.textPrimary).lineLimit(1)
                    Text(ad.subtitle)
                        .font(MYTypography.caption).foregroundStyle(MYColor.textSecondary).lineLimit(2)
                }
                Spacer(minLength: 0)
                MYTag(text: ad.statusTitle, style: tagStyle(ad))
            }
            Divider()
            HStack(spacing: MYSpacing.md) {
                info("calendar", "باقة \(ad.package.title)")
                info("banknote", MYFormat.price(ad.price))
                Spacer(minLength: 0)
                if let days = ad.daysLeft, ad.isLive {
                    info("clock", "باقي \(days) يوم")
                } else if ad.status == .pendingReview, !ad.reference.isEmpty {
                    info("number", ad.reference)
                }
            }
        }
        .myCard(padding: MYSpacing.md)
    }

    private func info(_ icon: String, _ text: String) -> some View {
        HStack(spacing: MYSpacing.xxs) {
            Image(systemName: icon).font(.system(size: 12))
            Text(text).font(MYTypography.caption)
        }
        .foregroundStyle(MYColor.textSecondary)
    }

    private func tagStyle(_ ad: AcademyAd) -> MYTagStyle {
        if ad.isExpired { return .neutral }
        switch ad.status {
        case .active: return .success
        case .pendingReview: return .warning
        case .rejected: return .error
        }
    }
}

#Preview {
    NavigationStack { ProviderAdsView() }
        .environment(Router())
        .environment(FeaturedStore(repo: nil))
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
