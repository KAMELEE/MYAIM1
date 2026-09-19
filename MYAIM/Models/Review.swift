import Foundation

/// A customer review on a service/provider.
struct Review: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var authorName: String
    var rating: Double        // 0...5
    var comment: String
    var date: Date
}
