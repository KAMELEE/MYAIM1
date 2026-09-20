import SwiftUI

struct ProviderAccountView: View {
    @Environment(AppState.self) private var appState
    @Environment(ProviderStore.self) private var store
    @Environment(Router.self) private var router

    var body: some View {
        ScrollView {
            VStack(spacing: MYSpacing.lg) {
                header

                VStack(spacing: 0) {
                    row("building.2", "معلومات الأكاديمية")
                    row("photo.on.rectangle", "الصور والغلاف")
                    row("calendar", "الحجوزات والطلاب")
                    row("bubble.left.and.bubble.right", "الرسائل") { router.push(.messages) }
                    row("chart.bar", "الإحصائيات")
                    row("gearshape", "الإعدادات") { router.push(.settings) }
                }
                .myCard(padding: MYSpacing.xs)

                MYButton(title: "العودة إلى وضع المتدرّب", icon: "arrow.triangle.2.circlepath",
                         style: .secondary) {
                    Haptics.medium()
                    withAnimation { appState.switchMode(.trainee) }
                }
                MYButton(title: "تسجيل الخروج", icon: "rectangle.portrait.and.arrow.right",
                         style: .outline) {
                    withAnimation { appState.signOut() }
                }
            }
            .padding(MYSpacing.screen)
        }
        .myTabBarInset()
        .myScreenBackground()
        .navigationTitle("الأكاديمية")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: MYSpacing.md) {
            MYRemoteImage(assetName: store.category.imageName, accent: store.category.accent)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: MYSpacing.xs) {
                    Text(store.academyName).font(MYTypography.cardTitle).foregroundStyle(MYColor.textPrimary).lineLimit(1)
                    Image(systemName: "checkmark.seal.fill").font(.system(size: 13)).foregroundStyle(MYColor.primary)
                }
                Text(store.academyTagline).font(MYTypography.description).foregroundStyle(MYColor.textSecondary).lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(MYSpacing.lg)
        .myCard(padding: MYSpacing.lg)
    }

    private func row(_ icon: String, _ title: String, action: (() -> Void)? = nil) -> some View {
        Button {
            if let action { Haptics.light(); action() }
        } label: {
            HStack(spacing: MYSpacing.md) {
                Image(systemName: icon).font(.system(size: 16)).foregroundStyle(MYColor.primary).frame(width: 24)
                Text(title).font(MYTypography.body).foregroundStyle(MYColor.textPrimary)
                Spacer()
                Image(systemName: "chevron.forward").font(.system(size: 13, weight: .semibold)).foregroundStyle(MYColor.textTertiary)
            }
            .padding(.vertical, MYSpacing.md).padding(.horizontal, MYSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack { ProviderAccountView() }
        .environment(AppState())
        .environment(ProviderStore())
        .environment(Router())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
