import SwiftUI

/// Root shell of the provider (academy) interface: a boxed floating tab bar
/// with Dashboard / Courses / Posts / Subscription / Account.
struct ProviderShell: View {
    @State private var selection: ProviderTab

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
                ProviderNavStack {
                    content(for: tab)
                }
                .tag(tab)
            }
        }
        .overlay(alignment: .bottom) {
            MYTabBar(items: ProviderTab.allCases, selection: $selection)
        }
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
    @State private var router = Router()
    @ViewBuilder let content: Content

    var body: some View {
        NavigationStack(path: $router.path) {
            content.withAppRoutes()
        }
        .environment(router)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    ProviderShell()
        .environment(AppState())
        .environment(ProviderStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
