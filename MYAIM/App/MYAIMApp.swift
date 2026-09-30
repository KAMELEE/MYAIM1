import SwiftUI
import UIKit
import FirebaseCore

@main
struct MYAIMApp: App {
    init() {
        FirebaseApp.configure()
        Self.configureNavigationBarBackButton()
    }

    /// Hide the system back-button title (the English word "Back") app-wide,
    /// leaving only the chevron — SwiftUI has no modifier for this, so we set
    /// the UIKit appearance once. The chevron and bar background are untouched.
    private static func configureNavigationBarBackButton() {
        let hidden: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.clear]
        let backItem = UIBarButtonItemAppearance(style: .plain)
        backItem.normal.titleTextAttributes = hidden
        backItem.highlighted.titleTextAttributes = hidden
        backItem.focused.titleTextAttributes = hidden
        backItem.disabled.titleTextAttributes = hidden

        let bar = UINavigationBarAppearance()
        bar.configureWithDefaultBackground()
        bar.backButtonAppearance = backItem

        let proxy = UINavigationBar.appearance()
        proxy.standardAppearance = bar
        proxy.scrollEdgeAppearance = bar
        proxy.compactAppearance = bar
    }

    @State private var appState = AppState()
    @State private var favorites = FavoritesStore()
    @State private var goals = GoalsStore()
    @State private var provider = ProviderStore()
    @State private var location = LocationService()
    @State private var messages = MessagesStore()
    @State private var notifications = NotificationService()
    @State private var featured = FeaturedStore()

    var body: some Scene {
        WindowGroup {
            RootCoordinatorView()
                .environment(appState)
                .environment(favorites)
                .environment(goals)
                .environment(provider)
                .environment(location)
                .environment(messages)
                .environment(notifications)
                .environment(featured)
                // Arabic-first: force RTL layout and Arabic locale app-wide.
                .environment(\.layoutDirection, .rightToLeft)
                .environment(\.locale, Locale(identifier: "ar"))
                .preferredColorScheme(appState.preferredColorScheme)
                .tint(MYColor.primary)
        }
    }
}
