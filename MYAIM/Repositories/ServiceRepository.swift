import Foundation

/// Service/provider data access. UI depends on this protocol only.
protocol ServiceRepository {
    func popular() async throws -> [Service]
    func nearby() async throws -> [Service]
    func recommended() async throws -> [Service]
    func services(in category: ServiceCategory?) async throws -> [Service]
    func search(_ query: String, filters: SearchFilters) async throws -> [Service]
    func suggestions(for query: String) async throws -> [String]
}

/// Mock backed by SampleData with realistic latency.
final class MockServiceRepository: ServiceRepository {

    private func delay(_ seconds: Double = 0.6) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }

    func popular() async throws -> [Service] {
        try await delay()
        return SampleData.services.sorted { $0.reviewsCount > $1.reviewsCount }
    }

    func nearby() async throws -> [Service] {
        try await delay()
        return SampleData.services.sorted { ($0.distanceMeters ?? .greatestFiniteMagnitude)
                                          < ($1.distanceMeters ?? .greatestFiniteMagnitude) }
    }

    func recommended() async throws -> [Service] {
        try await delay()
        return SampleData.services.sorted { $0.rating > $1.rating }
    }

    func services(in category: ServiceCategory?) async throws -> [Service] {
        try await delay()
        guard let category else { return SampleData.services }
        return SampleData.services.filter { $0.category == category }
    }

    func search(_ query: String, filters: SearchFilters) async throws -> [Service] {
        try await delay(0.4)
        let q = query.trimmingCharacters(in: .whitespaces)
        var results = SampleData.services

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
        guard !q.isEmpty else { return [] }
        try await delay(0.2)
        var out: [String] = []
        out.append("\(q) قريب منك")
        for c in ServiceCategory.allCases where c.title.localizedCaseInsensitiveContains(q) {
            out.append(c.title)
        }
        for s in SampleData.services where s.title.localizedCaseInsensitiveContains(q) {
            out.append(s.title)
        }
        return Array(Set(out)).prefix(6).map { $0 }
    }
}
