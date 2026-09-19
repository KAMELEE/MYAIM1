import SwiftUI

/// Custom "boxed" floating bottom navigation.
/// - Floats above the safe area inside a rounded surface container.
/// - The active tab expands into a tinted pill showing icon + label;
///   inactive tabs show the icon only. Animated with a subtle spring.
struct MYTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: MYSpacing.xs) {
            ForEach(AppTab.allCases) { tab in
                item(for: tab)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(MYColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .strokeBorder(MYColor.border, lineWidth: 0.5)
                )
                .myShadow(MYShadow.raised)
        )
        .padding(.horizontal, MYSpacing.lg)
        .padding(.bottom, MYSpacing.xs)
    }

    @ViewBuilder
    private func item(for tab: AppTab) -> some View {
        let isActive = selection == tab

        Button {
            guard selection != tab else { return }
            Haptics.selection()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selection = tab
            }
        } label: {
            HStack(spacing: MYSpacing.xs) {
                Image(systemName: isActive ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 20, weight: isActive ? .semibold : .regular))
                    .symbolRenderingMode(.hierarchical)

                if isActive {
                    Text(tab.title)
                        .font(.appFont(12.5, weight: .semibold))
                        .lineLimit(1)
                        .fixedSize()
                }
            }
            .foregroundStyle(isActive ? MYColor.primary : MYColor.textSecondary)
            .padding(.vertical, 11)
            .padding(.horizontal, isActive ? MYSpacing.md : MYSpacing.sm)
            .frame(maxWidth: isActive ? .infinity : nil)
            .background(
                Capsule().fill(isActive ? MYColor.primaryTint : .clear)
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isActive ? [.isSelected, .isButton] : .isButton)
    }
}

#Preview {
    struct Wrap: View {
        @State var sel: AppTab = .home
        var body: some View {
            ZStack(alignment: .bottom) {
                MYColor.background.ignoresSafeArea()
                MYTabBar(selection: $sel)
            }
        }
    }
    return Wrap()
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
