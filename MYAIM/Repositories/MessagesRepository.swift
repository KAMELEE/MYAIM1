import Foundation

/// Chat data access (trainee ↔ academy threads).
///
/// DEMO builds have no repository — `MessagesStore` stays seeded/in-memory
/// with simulated academy replies.
protocol MessagesRepository {
    /// The signed-in user's threads with their messages, newest thread first.
    func conversations() async throws -> [Conversation]
    /// Creates/updates the thread header (name, unread, last activity).
    func saveConversation(_ conversation: Conversation) async throws
    /// Appends one message to a thread.
    func append(_ message: Message, to conversationID: UUID) async throws
}
