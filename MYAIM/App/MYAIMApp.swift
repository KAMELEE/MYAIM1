import SwiftUI

@main
struct MYAIMApp: App {
    @State private var appState = AppState()
    @State private var favorites = FavoritesStore()
    @State private var goals = GoalsStore()

    var body: some Scene {
        WindowGroup {
            RootCoordinatorView()
                .environment(appState)
                .environment(favorites)
                .environment(goals)
                // Arabic-first: force RTL layout and Arabic locale app-wide.
                .environment(\.layoutDirection, .rightToLeft)
                .environment(\.locale, Locale(identifier: "ar"))
                .preferredColorScheme(appState.preferredColorScheme)
                .tint(MYColor.primary)
        }
    }
}
