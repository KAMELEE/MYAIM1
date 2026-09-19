import Foundation

/// A service provider: academy, coach, expert or company.
struct Provider: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var name: String                 // "أكاديمية النخبة الرياضية"
    var tagline: String              // "أكاديمية متخصصة في اللياقة والتدريب"
    var about: String
    var category: ServiceCategory
    var isVerified: Bool
    var rating: Double
    var reviewsCount: Int
    var location: MYLocation
    var logoURL: String?
    var coverURL: String?
}
