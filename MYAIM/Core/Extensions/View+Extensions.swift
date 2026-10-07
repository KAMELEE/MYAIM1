import SwiftUI

extension View {
    /// Fills the screen with the MY AIM background color, ignoring safe area.
    func myScreenBackground() -> some View {
        self.background(MYColor.background.ignoresSafeArea())
    }

    /// Applies the standard horizontal screen padding.
    func myScreenPadding() -> some View {
        self.padding(.horizontal, MYSpacing.screen)
    }

    /// Ensures a minimum 44x44 tappable area (Accessibility / HIG).
    func myTappable() -> some View {
        self.frame(minWidth: 44, minHeight: 44)
    }

    /// Adds bottom inset so scrollable content clears the floating MYTabBar.
    /// No-op on pushed screens, where the floating bar is hidden.
    func myTabBarInset() -> some View {
        modifier(TabBarSpacing(kind: .inset))
    }

    /// Lifts a PINNED bottom bar (CTA) above the floating MYTabBar, which is
    /// drawn as an overlay on TabView and therefore covers pushed screens too.
    /// Use on fixed bottom bars; use `myTabBarInset()` for scroll content.
    func myTabBarClearance() -> some View {
        modifier(TabBarSpacing(kind: .clearance))
    }

    /// Conditionally apply a modifier.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool,
                             transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}

// MARK: - Floating tab bar visibility

private struct MYTabBarVisibleKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    /// `false` inside pushed (non-root) screens, where the floating MYTabBar
    /// is hidden — so tab-bar spacing collapses to zero there.
    var myTabBarVisible: Bool {
        get { self[MYTabBarVisibleKey.self] }
        set { self[MYTabBarVisibleKey.self] = newValue }
    }
}

/// Reserves room for the floating tab bar only while it is actually shown.
private struct TabBarSpacing: ViewModifier {
    enum Kind { case inset, clearance }
    let kind: Kind
    @Environment(\.myTabBarVisible) private var visible

    func body(content: Content) -> some View {
        let height: CGFloat = visible ? 84 : 0
        switch kind {
        case .inset:     content.safeAreaPadding(.bottom, height)
        case .clearance: content.padding(.bottom, height)
        }
    }
}

// MARK: - Entrance motion

extension View {
    /// Fades + lifts the view in once, the first time it appears.
    /// Respects Reduce Motion (fade only, no movement).
    func myAppear(delay: Double = 0) -> some View {
        modifier(AppearModifier(delay: delay))
    }

    /// Staggered entrance for an item of a list/grid: each item starts a beat
    /// after the previous one (capped so long lists don't lag).
    func myAppear<C: RandomAccessCollection>(item: C.Element, in collection: C) -> some View
    where C.Element: Identifiable {
        let index = collection.firstIndex { $0.id == item.id }
            .map { collection.distance(from: collection.startIndex, to: $0) } ?? 0
        return myAppear(delay: min(Double(index), 8) * 0.045)
    }
}

private struct AppearModifier: ViewModifier {
    let delay: Double
    @State private var shown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown || reduceMotion ? 0 : 16)
            .scaleEffect(shown || reduceMotion ? 1 : 0.985)
            .onAppear {
                guard !shown else { return }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.86).delay(delay)) {
                    shown = true
                }
            }
    }
}

// MARK: - Status bar scrim

extension View {
    /// For screens with a hidden navigation bar: paints the status-bar strip
    /// with the screen background so scrolled content doesn't run under the
    /// clock / Dynamic Island.
    func myStatusBarScrim() -> some View {
        overlay(alignment: .top) {
            MYColor.background
                .opacity(0.97)
                .frame(height: 0)
                .ignoresSafeArea(edges: .top)
        }
    }
}
