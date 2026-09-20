import Foundation

/// A course/program offered by a provider (academy side).
struct Course: Identifiable, Hashable {
    var id: UUID = UUID()
    var title: String
    var category: ServiceCategory
    var price: Double
    var students: Int
    var rating: Double
    var isPublished: Bool
    var summary: String
}
