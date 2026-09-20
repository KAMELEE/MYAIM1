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
            } else if appState.mode == .provider {
                ProviderShell()
                    .transition(.opacity)
            } else {
                RootTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.hasSeenOnboarding)
        .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: appState.mode)
        .onAppear {
            #if DEBUG
            DemoScroll.applyIfNeeded()
            #endif
        }
    }
}

#Preview {
    RootCoordinatorView()
        .environment(AppState())
        .environment(FavoritesStore())
        .environment(GoalsStore())
        .environment(ProviderStore())
        .environment(LocationService())
        .environment(MessagesStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
