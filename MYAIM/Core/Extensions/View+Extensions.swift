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
    func myTabBarInset() -> some View {
        self.safeAreaPadding(.bottom, 84)
    }

    /// Conditionally apply a modifier.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool,
                             transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}
