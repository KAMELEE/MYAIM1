import SwiftUI

/// Root shell of the provider (academy) interface: a boxed floating tab bar
/// with Dashboard / Courses / Posts / Subscription / Account.
struct ProviderShell: View {
    @State private var selection: ProviderTab
    /// Navigation depth per tab — the floating bar hides on pushed screens.
    @State private var depths: [ProviderTab: Int] = [:]

    init() {
        var initial: ProviderTab = .dashboard
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-demoTab"), i + 1 < args.count {
            switch args[i + 1] {
            case "courses":      initial = .courses
            case "posts":        initial = .posts
            case "subscription": initial = .subscription
            case "account":      initial = .account
            default:             initial = .dashboard
            }
        }
        #endif
        _selection = State(initialValue: initial)
    }

    var body: some View {
        TabView(selection: $selection) {
            ForEach(ProviderTab.allCases) { tab in
                ProviderNavStack(onDepthChange: { depths[tab] = $0 }) {
                    content(for: tab)
                }
                .tag(tab)
            }
        }
        .overlay(alignment: .bottom) {
            if (depths[selection] ?? 0) == 0 {
                MYTabBar(items: ProviderTab.allCases, selection: $selection)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85),
                   value: depths[selection] ?? 0)
    }

    @ViewBuilder
    private func content(for tab: ProviderTab) -> some View {
        switch tab {
        case .dashboard:    ProviderDashboardView()
        case .courses:      ProviderCoursesView()
        case .posts:        ProviderPostsView()
        case .subscription: SubscriptionView()
        case .account:      ProviderAccountView()
        }
    }
}

private struct ProviderNavStack<Content: View>: View {
    var onDepthChange: (Int) -> Void = { _ in }
    @State private var router = Router()
    @ViewBuilder let content: Content

    var body: some View {
        NavigationStack(path: $router.path) {
            content.withAppRoutes()
        }
        .environment(router)
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: router.path.count, initial: true) { _, n in onDepthChange(n) }
    }
}

#Preview {
    ProviderShell()
        .environment(AppState())
        .environment(ProviderStore())
        .environment(AcademyInboxStore(repo: nil))
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
