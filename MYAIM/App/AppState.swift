import SwiftUI
import Observation

/// App-wide, cross-feature state (session, theme preference, etc.).
/// Injected into the environment at the root and read where needed.
@Observable
final class AppState {
    /// Whether the user has completed onboarding (persisted across launches).
    var hasSeenOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasSeenOnboarding, forKey: Keys.onboarding) }
    }

    /// Whether a user session is active.
    var isAuthenticated: Bool = false

    /// The currently signed-in user.
    var currentUser: User?

    /// User-selected color scheme override. `nil` = follow system.
    var preferredColorScheme: ColorScheme? = nil

    init() {
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: Keys.onboarding)
        #if DEBUG
        // CI/demo: launch straight into the app with a sample session.
        if ProcessInfo.processInfo.arguments.contains("-demoMode") {
            hasSeenOnboarding = true
            isAuthenticated = true
            currentUser = .preview
        }
        #endif
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
    }

    func signIn(_ user: User) {
        currentUser = user
        isAuthenticated = true
    }

    func signOut() {
        currentUser = nil
        isAuthenticated = false
    }

    private enum Keys {
        static let onboarding = "myaim.hasSeenOnboarding"
    }
}
