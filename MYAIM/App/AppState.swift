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

    /// Which interface is active: trainee (default) or provider (academy).
    var mode: AppMode {
        didSet { UserDefaults.standard.set(mode.rawValue, forKey: Keys.mode) }
    }

    /// User-selected color scheme override. `nil` = follow system.
    var preferredColorScheme: ColorScheme? = nil

    init() {
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: Keys.onboarding)
        self.mode = AppMode(rawValue: UserDefaults.standard.string(forKey: Keys.mode) ?? "") ?? .trainee
        #if DEBUG
        // CI/demo: launch straight into the app with a sample session.
        if ProcessInfo.processInfo.arguments.contains("-demoMode") {
            hasSeenOnboarding = true
            isAuthenticated = true
            currentUser = .preview
        }
        if ProcessInfo.processInfo.arguments.contains("-providerMode") {
            mode = .provider
        }
        #endif
    }

    func switchMode(_ newMode: AppMode) {
        mode = newMode
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
        static let mode = "myaim.mode"
    }
}

/// The two interfaces of MY AIM.
enum AppMode: String {
    case trainee
    case provider
}
