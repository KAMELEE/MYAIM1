import SwiftUI

@main
struct MYAIMApp: App {
    @State private var appState = AppState()
    @State private var favorites = FavoritesStore()
    @State private var goals = GoalsStore()
    @State private var provider = ProviderStore()
    @State private var location = LocationService()
    @State private var messages = MessagesStore()

    var body: some Scene {
        WindowGroup {
            RootCoordinatorView()
                .environment(appState)
                .environment(favorites)
                .environment(goals)
                .environment(provider)
                .environment(location)
                .environment(messages)
                // Arabic-first: force RTL layout and Arabic locale app-wide.
                .environment(\.layoutDirection, .rightToLeft)
                .environment(\.locale, Locale(identifier: "ar"))
                .preferredColorScheme(appState.preferredColorScheme)
                .tint(MYColor.primary)
        }
    }
}
