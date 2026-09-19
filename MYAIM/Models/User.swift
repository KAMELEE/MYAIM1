import Foundation

/// The authenticated user.
struct User: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var name: String
    var email: String
    var phone: String
    var avatarURL: String?

    static let preview = User(
        name: "أحمد",
        email: "ahmed@example.com",
        phone: "0555555555",
        avatarURL: nil
    )
}
