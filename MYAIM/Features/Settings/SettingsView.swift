import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @AppStorage("myaim.notifications") private var notificationsEnabled = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                appearanceSection
                preferencesSection
                aboutSection
            }
            .padding(MYSpacing.screen)
        }
        .myTabBarInset()
        .myScreenBackground()
        .navigationTitle("الإعدادات")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Appearance
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            sectionTitle("المظهر")
            HStack(spacing: MYSpacing.sm) {
                appearanceOption("نظام", nil, "iphone")
                appearanceOption("فاتح", .light, "sun.max")
                appearanceOption("داكن", .dark, "moon")
            }
        }
    }

    private func appearanceOption(_ title: String, _ scheme: ColorScheme?, _ icon: String) -> some View {
        let isOn = appState.preferredColorScheme == scheme
        return Button {
            Haptics.selection()
            withAnimation { appState.preferredColorScheme = scheme }
        } label: {
            VStack(spacing: MYSpacing.sm) {
                Image(systemName: icon).font(.system(size: 20))
                Text(title).font(MYTypography.secondary)
            }
            .foregroundStyle(isOn ? .white : MYColor.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, MYSpacing.lg)
            .background(isOn ? MYColor.primary : MYColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                .strokeBorder(isOn ? .clear : MYColor.border, lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: Preferences
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            sectionTitle("التفضيلات")
            VStack(spacing: 0) {
                Toggle(isOn: $notificationsEnabled) {
                    Label("الإشعارات", systemImage: "bell")
                        .font(MYTypography.body).foregroundStyle(MYColor.textPrimary)
                }
                .tint(MYColor.primary)
                .padding(MYSpacing.md)
                Divider().background(MYColor.border)
                row("globe", "اللغة", value: "العربية")
                Divider().background(MYColor.border)
                row("location", "الموقع", value: "مفعّل")
            }
            .myCard(padding: 0)
        }
    }

    // MARK: About
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            sectionTitle("عن التطبيق")
            VStack(spacing: 0) {
                row("info.circle", "الإصدار", value: "1.0.0")
                Divider().background(MYColor.border)
                row("doc.text", "الشروط والأحكام")
                Divider().background(MYColor.border)
                row("hand.raised", "سياسة الخصوصية")
            }
            .myCard(padding: 0)
        }
    }

    private func sectionTitle(_ t: String) -> some View {
        Text(t).font(MYTypography.cardTitle).foregroundStyle(MYColor.textSecondary)
    }

    private func row(_ icon: String, _ title: String, value: String? = nil) -> some View {
        HStack(spacing: MYSpacing.md) {
            Image(systemName: icon).font(.system(size: 16)).foregroundStyle(MYColor.primary).frame(width: 24)
            Text(title).font(MYTypography.body).foregroundStyle(MYColor.textPrimary)
            Spacer()
            if let value {
                Text(value).font(MYTypography.secondary).foregroundStyle(MYColor.textSecondary)
            } else {
                Image(systemName: "chevron.forward").font(.system(size: 13, weight: .semibold)).foregroundStyle(MYColor.textTertiary)
            }
        }
        .padding(MYSpacing.md)
    }
}

#Preview {
    NavigationStack { SettingsView() }
        .environment(AppState())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
