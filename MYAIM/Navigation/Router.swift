import SwiftUI
import Observation

/// Navigation router for a single tab's NavigationStack.
/// Injected into the environment so any child view can push/pop without
/// threading closures through the whole hierarchy.
@Observable
final class Router {
    var path: [AppRoute] = []

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
