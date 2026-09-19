import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(Router.self) private var router

    var body: some View {
        ScrollView {
            VStack(spacing: MYSpacing.lg) {
                header

                // Full menu (favorites, notifications, settings, etc.) is built in Phase 11.
                VStack(spacing: 0) {
                    row("heart", "المفضلة") { router.push(.favorites) }
                    row("bell", "الإشعارات") { router.push(.notifications) }
                    row("building.2", "سجّل أكاديميتك") { router.push(.registerAcademy) }
                    row("gearshape", "الإعدادات")
                    row("questionmark.circle", "المساعدة")
                    row("doc.text", "الشروط والأحكام")
                }
                .myCard(padding: MYSpacing.xs)

                MYButton(title: "تسجيل الخروج", icon: "rectangle.portrait.and.arrow.right",
                         style: .outline) {
                    withAnimation { appState.signOut() }
                }
            }
            .padding(MYSpacing.screen)
        }
        .myTabBarInset()
        .myScreenBackground()
        .navigationTitle("حسابي")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: MYSpacing.md) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(MYColor.primary)
            VStack(alignment: .leading, spacing: 2) {
                Text(appState.currentUser?.name ?? "مستخدم MY AIM")
                    .font(MYTypography.section)
                    .foregroundStyle(MYColor.textPrimary)
                Text(appState.currentUser?.email ?? "")
                    .font(MYTypography.secondary)
                    .foregroundStyle(MYColor.textSecondary)
            }
            Spacer()
        }
        .padding(MYSpacing.lg)
        .myCard(padding: MYSpacing.lg)
    }

    private func row(_ icon: String, _ title: String, action: (() -> Void)? = nil) -> some View {
        Button {
            if let action { Haptics.light(); action() }
        } label: {
            HStack(spacing: MYSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(MYColor.primary)
                    .frame(width: 24)
                Text(title)
                    .font(MYTypography.body)
                    .foregroundStyle(MYColor.textPrimary)
                Spacer()
                Image(systemName: "chevron.forward")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(MYColor.textTertiary)
            }
            .padding(.vertical, MYSpacing.md)
            .padding(.horizontal, MYSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack { ProfileView() }
        .environment(AppState())
        .environment(Router())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
