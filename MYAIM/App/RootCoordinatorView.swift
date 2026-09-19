import SwiftUI

/// Decides which top-level flow to show: Onboarding → Authentication → App.
struct RootCoordinatorView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if !appState.hasSeenOnboarding {
                OnboardingView()
                    .transition(.opacity)
            } else if !appState.isAuthenticated {
                AuthFlowView()
                    .transition(.opacity)
            } else {
                RootTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.hasSeenOnboarding)
        .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
    }
}

#Preview {
    RootCoordinatorView()
        .environment(AppState())
        .environment(FavoritesStore())
        .environment(GoalsStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
