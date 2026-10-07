import SwiftUI

/// Decides which top-level flow to show: Onboarding → Authentication → App.
struct RootCoordinatorView: View {
    @Environment(AppState.self) private var appState
    @Environment(GoalsStore.self) private var goalsStore
    @Environment(ProviderStore.self) private var providerStore
    @Environment(MessagesStore.self) private var messagesStore
    @State private var showSplash = !RootCoordinatorView.skipSplash

    var body: some View {
        ZStack {
            content
            if showSplash {
                SplashView { withAnimation(.easeInOut(duration: 0.35)) { showSplash = false } }
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
    }

    /// Skip the intro in CI/demo captures so deep-linked screens render immediately.
    private static var skipSplash: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.arguments.contains("-demoMode")
            || ProcessInfo.processInfo.arguments.contains("-onboarding")
            || ProcessInfo.processInfo.arguments.contains("-authScreen")
        #else
        return false
        #endif
    }

    @ViewBuilder
    private var content: some View {
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
        // After login, pull the signed-in user's real data from Firestore.
        .onChange(of: appState.isAuthenticated) { _, signedIn in
            guard signedIn else { return }
            Task {
                await goalsStore.reload()
                await messagesStore.reload()
                await providerStore.reload()
            }
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
