import SwiftUI
import Observation

@MainActor
@Observable
final class SearchViewModel {
    private let repo: ServiceRepository

    var query = ""
    var suggestions: [String] = []
    var results: LoadingState<[Service]> = .idle
    private(set) var recent: [String] = []

    let popular = ["سباحة", "كرة قدم", "برمجة", "لغة إنجليزية", "لياقة", "تصميم"]

    private var task: Task<Void, Never>?
    private let recentKey = "myaim.recentSearches"

    init(repo: ServiceRepository = MockServiceRepository()) {
        self.repo = repo
        recent = UserDefaults.standard.stringArray(forKey: recentKey) ?? []
    }

    var isSearching: Bool { !query.trimmingCharacters(in: .whitespaces).isEmpty }

    func onQueryChange() {
        task?.cancel()
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else {
            suggestions = []
            results = .idle
            return
        }
        task = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            if Task.isCancelled { return }
            await fetch(q)
        }
    }

    func submit(_ text: String) {
        query = text
        addRecent(text)
        task?.cancel()
        task = Task { await fetch(text) }
    }

    private func fetch(_ q: String) async {
        results = .loading
        do {
            async let sugg = repo.suggestions(for: q)
            async let res = repo.search(q, filters: .none)
            suggestions = try await sugg
            let services = try await res
            results = services.isEmpty ? .empty : .loaded(services)
        } catch {
            results = .failed((error as? RepositoryError)?.errorDescription ?? "تعذر البحث.")
        }
    }

    // MARK: Recent
    func addRecent(_ text: String) {
        let t = text.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return }
        recent.removeAll { $0 == t }
        recent.insert(t, at: 0)
        recent = Array(recent.prefix(8))
        UserDefaults.standard.set(recent, forKey: recentKey)
    }

    func clearRecent() {
        recent = []
        UserDefaults.standard.removeObject(forKey: recentKey)
    }
}
