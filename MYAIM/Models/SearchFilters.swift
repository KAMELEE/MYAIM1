import Foundation

/// Filter criteria for Discover/Search.
struct SearchFilters: Equatable {
    var category: ServiceCategory? = nil
    var maxPrice: Double? = nil          // SAR
    var minRating: Double? = nil         // 0...5
    var maxDistanceMeters: Double? = nil // meters
    var availableOnly: Bool = false

    /// Whether any non-default filter is active.
    var isActive: Bool {
        category != nil || maxPrice != nil || minRating != nil
            || maxDistanceMeters != nil || availableOnly
    }

    /// Number of active filters (for a badge on the filter button).
    var activeCount: Int {
        var n = 0
        if category != nil { n += 1 }
        if maxPrice != nil { n += 1 }
        if minRating != nil { n += 1 }
        if maxDistanceMeters != nil { n += 1 }
        if availableOnly { n += 1 }
        return n
    }

    static let none = SearchFilters()
}
