import SwiftUI

/// Root shell: a `TabView` (native bar hidden) with a custom boxed `MYTabBar`.
/// Each tab owns a `Router` + NavigationStack and registers app routes.
struct RootTabView: View {
    @State private var selection: AppTab
    /// Navigation depth per tab — the floating bar hides on pushed screens.
    @State private var depths: [AppTab: Int] = [:]

    init() {
        var initial: AppTab = .home
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-demoTab"), i + 1 < args.count {
            switch args[i + 1] {
            case "discover": initial = .discover
            case "goals":    initial = .goals
            case "bookings": initial = .bookings
            case "profile":  initial = .profile
            default:         initial = .home
            }
        }
        #endif
        _selection = State(initialValue: initial)
    }

    var body: some View {
        TabView(selection: $selection) {
            ForEach(AppTab.allCases) { tab in
                TabNavigationStack(onDepthChange: { depths[tab] = $0 }) {
                    tabContent(for: tab)
                }
                .tag(tab)
            }
        }
        .overlay(alignment: .bottom) {
            if (depths[selection] ?? 0) == 0 {
                MYTabBar(items: AppTab.allCases, selection: $selection)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85),
                   value: depths[selection] ?? 0)
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
    var onDepthChange: (Int) -> Void = { _ in }
    @State private var router = Router()
    @ViewBuilder let content: Content

    var body: some View {
        NavigationStack(path: $router.path) {
            content
                .withAppRoutes()
        }
        .environment(router)
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: router.path.count, initial: true) { _, n in onDepthChange(n) }
    }
}

#Preview {
    RootTabView()
        .environment(AppState())
        .environment(FavoritesStore())
        .environment(GoalsStore())
        .environment(LocationService())
        .environment(MessagesStore())
        .environment(NotificationService())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
