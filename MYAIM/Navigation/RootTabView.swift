import SwiftUI

/// Root shell: a `TabView` (native bar hidden) with a custom boxed `MYTabBar`.
/// Each tab owns a `Router` + NavigationStack and registers app routes.
struct RootTabView: View {
    @State private var selection: AppTab = .home

    var body: some View {
        TabView(selection: $selection) {
            ForEach(AppTab.allCases) { tab in
                TabNavigationStack {
                    tabContent(for: tab)
                }
                .tag(tab)
            }
        }
        .overlay(alignment: .bottom) {
            MYTabBar(selection: $selection)
        }
    }

    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .home:     HomeView()
        case .discover: DiscoverView()
        case .goals:    GoalsView()
        case .bookings: BookingsView()
        case .profile:  ProfileView()
        }
    }
}

/// A per-tab NavigationStack bound to its own Router, with routes registered
/// and the native tab bar hidden (the custom MYTabBar is drawn by RootTabView).
private struct TabNavigationStack<Content: View>: View {
    @State private var router = Router()
    @ViewBuilder let content: Content

    var body: some View {
        NavigationStack(path: $router.path) {
            content
                .withAppRoutes()
        }
        .environment(router)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    RootTabView()
        .environment(AppState())
        .environment(FavoritesStore())
        .environment(GoalsStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
