import Foundation
import CoreLocation

/// A bookable service / program / course offered by a provider.
struct Service: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var title: String                // "برنامج اللياقة الشامل"
    var summary: String              // short description shown on cards
    var category: ServiceCategory
    var providerName: String
    var providerId: UUID
    var isVerified: Bool
    var rating: Double
    var reviewsCount: Int
    var location: MYLocation
    var startingPrice: Double        // in SAR
    var imageURL: String?

    /// Distance in meters from the user (nil if unknown). Set at load time.
    var distanceMeters: Double?

    /// Returns a copy with `distanceMeters` recomputed from a coordinate
    /// (e.g. the live user location). Unchanged if `coord` is nil.
    func distanced(from coord: CLLocationCoordinate2D?) -> Service {
        guard let coord else { return self }
        var copy = self
        copy.distanceMeters = location.distance(from: coord)
        return copy
    }
}
