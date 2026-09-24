import Foundation
import FirebaseFirestore

/// Firestore-backed catalog. Reads the `services` collection (single source of
/// truth for the shop window); on first launch the collection is empty, so the
/// bundled Arabic catalog (SampleData) is seeded once — after that the app
/// always serves live Firestore data.
///
/// All list/search semantics mirror `MockServiceRepository` so screens behave
/// identically in DEMO (mock) and production (Firestore).
final class FirestoreServiceRepository: ServiceRepository {

    private let db = Firestore.firestore()
    private var cache: [Service]?

    private func allServices() async throws -> [Service] {
        if let cache { return cache }
        let snap = try await db.collection(Self.collection).order(by: "createdAt").getDocuments()
        let services = snap.documents.compactMap { FirestoreMappers.service(from: $0.data(), id: $0.documentID) }
        if services.isEmpty, let seeded = try? await seedIfNeeded(), !seeded.isEmpty {
            cache = seeded
            return seeded
        }
        cache = services
        return services
    }

    func invalidateCache() { cache = nil }

    /// One-time catalog bootstrap: writes SampleData into Firestore if the
    /// collection is empty. Safe to call concurrently (double seed is
    /// harmless — the shop window simply shows the catalog).
    private func seedIfNeeded() async throws -> [Service] {
        let count = try await db.collection(Self.collection).limit(to: 1).getDocuments().count
        guard count == 0 else { return [] }
        let batch = db.batch()
        for service in SampleData.services {
            batch.setData(FirestoreMappers.serviceData(service),
                          forDocument: db.collection(Self.collection).document(service.id.uuidString))
        }
        try await batch.commit()
        return SampleData.services
    }

    private static let collection = "services"

    // MARK: - ServiceRepository

    func popular() async throws -> [Service] {
        try await allServices().sorted { $0.reviewsCount > $1.reviewsCount }
    }

    func nearby() async throws -> [Service] {
        try await allServices().sorted { ($0.distanceMeters ?? .greatestFiniteMagnitude)
                                         < ($1.distanceMeters ?? .greatestFiniteMagnitude) }
    }

    func recommended() async throws -> [Service] {
        try await allServices().sorted { $0.rating > $1.rating }
    }

    func services(in category: ServiceCategory?) async throws -> [Service] {
        let all = try await allServices()
        guard let category else { return all }
        return all.filter { $0.category == category }
    }

    func search(_ query: String, filters: SearchFilters) async throws -> [Service] {
        let q = query.trimmingCharacters(in: .whitespaces)
        var results = try await allServices()

        if !q.isEmpty {
            results = results.filter {
                $0.title.localizedCaseInsensitiveContains(q)
                || $0.providerName.localizedCaseInsensitiveContains(q)
                || $0.summary.localizedCaseInsensitiveContains(q)
                || $0.category.title.localizedCaseInsensitiveContains(q)
                || $0.location.city.localizedCaseInsensitiveContains(q)
            }
        }
        if let c = filters.category { results = results.filter { $0.category == c } }
        if let p = filters.maxPrice { results = results.filter { $0.startingPrice <= p } }
        if let r = filters.minRating { results = results.filter { $0.rating >= r } }
        if let d = filters.maxDistanceMeters {
            results = results.filter { ($0.distanceMeters ?? .greatestFiniteMagnitude) <= d }
        }
        return results
    }

    func suggestions(for query: String) async throws -> [String] {
        let q = query.trimmingCharacters(in: .whitespaces)
        let all = try await allServices()
        return Array(all.filter {
            $0.title.localizedCaseInsensitiveContains(q)
            || $0.providerName.localizedCaseInsensitiveContains(q)
        }.map(\.title).prefix(6))
    }
}
