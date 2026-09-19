import SwiftUI
import Observation

enum DiscoverViewMode { case list, map }

@MainActor
@Observable
final class DiscoverViewModel {
    private let repo: ServiceRepository

    var query = ""
    var filters = SearchFilters()
    var viewMode: DiscoverViewMode = .list
    var state: LoadingState<[Service]> = .idle
    var favorites: Set<UUID> = []

    private var searchTask: Task<Void, Never>?

    init(repo: ServiceRepository = MockServiceRepository()) {
        self.repo = repo
    }

    /// Currently selected top-level category (mirrors filters.category).
    var selectedCategory: ServiceCategory? {
        get { filters.category }
        set { filters.category = newValue; runSearch() }
    }

    func loadIfNeeded() {
        if case .idle = state { runSearch() }
    }

    /// Debounced text search.
    func onQueryChange() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            if Task.isCancelled { return }
            await performSearch()
        }
    }

    func apply(_ newFilters: SearchFilters) {
        filters = newFilters
        runSearch()
    }

    func resetFilters() {
        filters = .none
        runSearch()
    }

    func runSearch() {
        searchTask?.cancel()
        searchTask = Task { await performSearch() }
    }

    private func performSearch() async {
        state = .loading
        do {
            let results = try await repo.search(query, filters: filters)
            state = results.isEmpty ? .empty : .loaded(results)
        } catch {
            state = .failed((error as? RepositoryError)?.errorDescription ?? "تعذر تحميل النتائج.")
        }
    }

    func toggleFavorite(_ service: Service) {
        if favorites.contains(service.id) { favorites.remove(service.id) }
        else { favorites.insert(service.id) }
    }

    func isFavorite(_ service: Service) -> Bool { favorites.contains(service.id) }
}
