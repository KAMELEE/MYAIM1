import Foundation

/// A single chat message.
struct Message: Identifiable, Hashable {
    var id: UUID = UUID()
    var text: String
    var fromMe: Bool
    var date: Date
    /// Voice note file URL (local .m4a) — nil for text messages.
    var audioURL: URL? = nil
    /// Voice note length in seconds, nil for text messages.
    var audioDuration: Double? = nil

    var isVoice: Bool { audioURL != nil }
}

/// A conversation thread with a provider/coach.
struct Conversation: Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var avatarAsset: String?
    var category: ServiceCategory
    var unread: Int
    var messages: [Message]

    var lastMessage: Message? { messages.last }
}
