import SwiftUI
import Observation

@MainActor
@Observable
final class HomeViewModel {
    struct Content: Equatable {
        var currentGoal: Goal?
        var popular: [Service]
        var nearby: [Service]
        var recommended: [Service]
    }

    private let services: ServiceRepository
    private let goals: GoalRepository

    var state: LoadingState<Content> = .idle
    var favorites: Set<UUID> = []

    init(services: ServiceRepository = AppRepositories.services(),
         goals: GoalRepository = AppRepositories.goals()) {
        self.services = services
        self.goals = goals
    }

    func load() async {
        if case .loaded = state { return } // don't reload if already have data
        state = .loading
        do {
            async let popular = services.popular()
            async let nearby = services.nearby()
            async let recommended = services.recommended()
            async let current = goals.currentGoals()

            let content = Content(
                currentGoal: try await current.first,
                popular: try await popular,
                nearby: try await nearby,
                recommended: try await recommended
            )
            state = .loaded(content)
        } catch {
            state = .failed((error as? RepositoryError)?.errorDescription ?? "تعذر تحميل البيانات.")
        }
    }

    func reload() async {
        state = .idle
        await load()
    }

    func toggleFavorite(_ service: Service) {
        if favorites.contains(service.id) { favorites.remove(service.id) }
        else { favorites.insert(service.id) }
    }

    func isFavorite(_ service: Service) -> Bool {
        favorites.contains(service.id)
    }
}
