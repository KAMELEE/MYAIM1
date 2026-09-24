import SwiftUI
import Observation

/// App-wide favorites store, shared across Home/Discover/Details/Favorites.
/// Persists locally via UserDefaults (SwiftData can replace this later).
@Observable
final class FavoritesStore {
    private(set) var ids: Set<UUID> = []
    private let key = "myaim.favorites"

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: key) ?? []
        ids = Set(saved.compactMap { UUID(uuidString: $0) })
    }

    func contains(_ id: UUID) -> Bool { ids.contains(id) }

    func toggle(_ id: UUID) {
        if ids.contains(id) { ids.remove(id) } else { ids.insert(id) }
        persist()
    }

    /// Favorited services resolved against a catalog fetched from the active
    /// repository (Firestore in production, SampleData in DEMO).
    func services(in catalog: [Service]) -> [Service] {
        catalog.filter { ids.contains($0.id) }
    }

    private func persist() {
        UserDefaults.standard.set(ids.map(\.uuidString), forKey: key)
    }
}
