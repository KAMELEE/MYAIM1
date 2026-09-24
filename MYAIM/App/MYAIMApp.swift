import SwiftUI
import FirebaseCore

@main
struct MYAIMApp: App {
    init() {
        FirebaseApp.configure()
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
