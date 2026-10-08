import Foundation

/// A single chat message.
struct Message: Identifiable, Hashable {
    var id: UUID = UUID()
    var text: String
    var fromMe: Bool
    var date: Date
    /// Voice note URL — a local .m4a file right after recording, or the
    /// Firebase Storage download URL once synced. nil for text messages.
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
    /// Academy account (Firebase uid) this thread is addressed to — nil when
    /// the service has no owner (sample catalog).
    var providerUid: String? = nil
    /// Trainee display name, shown in the academy inbox.
    var traineeName: String? = nil
    /// Unread count on the academy side.
    var academyUnread: Int = 0

    var lastMessage: Message? { messages.last }
}
