import SwiftUI

/// Decides which top-level flow to show: Onboarding → Authentication → App.
struct RootCoordinatorView: View {
    @Environment(AppState.self) private var appState
    @Environment(GoalsStore.self) private var goalsStore

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
        // After login, pull the signed-in user's real goals from Firestore.
        .onChange(of: appState.isAuthenticated) { _, signedIn in
            if signedIn { Task { await goalsStore.reload() } }
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
        .environment(NotificationService())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
