import Foundation
import CoreLocation

/// A physical location for a provider/service.
struct MYLocation: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var city: String            // "الرياض"
    var district: String?       // "حي النخيل"
    var latitude: Double
    var longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Straight-line distance in meters from a given coordinate.
    func distance(from origin: CLLocationCoordinate2D) -> Double {
        let a = CLLocation(latitude: latitude, longitude: longitude)
        let b = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
        return a.distance(from: b)
    }

    enum CodingKeys: String, CodingKey {
        case id, city, district, latitude, longitude
    }
}
