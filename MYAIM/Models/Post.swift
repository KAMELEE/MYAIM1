import Foundation

/// A post published by a provider to their followers/feed.
struct Post: Identifiable, Hashable {
    var id: UUID = UUID()
    var text: String
    var date: Date
    var likes: Int
    var comments: Int
    var imageName: String?
}
