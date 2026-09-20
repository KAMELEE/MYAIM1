import SwiftUI

struct SubscriptionView: View {
    @Environment(ProviderStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                Text("اختر الباقة المناسبة لأكاديميتك")
                    .font(MYTypography.section).foregroundStyle(MYColor.textPrimary)
                Text("طوّر حضورك على MY AIM بمزايا أكثر ووصول أوسع.")
                    .font(MYTypography.secondary).foregroundStyle(MYColor.textSecondary)

                ForEach(store.plans) { plan in
                    planCard(plan)
                }
            }
            .padding(MYSpacing.screen)
        }
        .myTabBarInset()
        .myScreenBackground()
        .navigationTitle("الاشتراك")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func planCard(_ plan: SubscriptionPlan) -> some View {
        let isCurrent = plan.id == store.currentPlanID
        return VStack(alignment: .leading, spacing: MYSpacing.md) {
            HStack {
                Text(plan.name).font(MYTypography.section).foregroundStyle(MYColor.textPrimary)
                if plan.isPopular { MYTag(text: "الأكثر اختيارًا", icon: "star.fill", style: .brand) }
                Spacer()
            }
            HStack(alignment: .firstTextBaseline, spacing: MYSpacing.xxs) {
                if plan.price > 0 {
                    Text(MYFormat.price(plan.price)).font(MYTypography.pageTitle).foregroundStyle(MYColor.primary)
                    Text("/ \(plan.period)").font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
                } else {
                    Text(plan.period).font(MYTypography.pageTitle).foregroundStyle(MYColor.primary)
                }
            }
            VStack(alignment: .leading, spacing: MYSpacing.sm) {
                ForEach(plan.features, id: \.self) { f in
                    HStack(spacing: MYSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 15)).foregroundStyle(MYColor.success)
                        Text(f).font(MYTypography.secondary).foregroundStyle(MYColor.textPrimary)
                    }
                }
            }
            MYButton(title: isCurrent ? "باقتك الحالية" : "اختيار الباقة",
                     style: isCurrent ? .outline : .primary,
                     isEnabled: !isCurrent) {
                store.selectPlan(plan)
                Haptics.success()
            }
        }
        .padding(MYSpacing.lg)
        .background(isCurrent ? MYColor.primaryTint : MYColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous)
                .strokeBorder(plan.isPopular ? MYColor.primary : MYColor.border,
                              lineWidth: plan.isPopular ? 1.5 : 0.5)
        )
    }
}

#Preview {
    NavigationStack { SubscriptionView() }
        .environment(ProviderStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
