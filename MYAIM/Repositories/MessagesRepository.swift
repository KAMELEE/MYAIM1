import Foundation

/// Chat data access (trainee ↔ academy threads).
///
/// A message's `fromMe` is stored from the TRAINEE's point of view
/// ("sent by the trainee"); the academy side flips it when reading.
///
/// DEMO builds have no repository — the stores stay seeded/in-memory.
protocol MessagesRepository {
    // MARK: Trainee side
    /// The signed-in user's threads with their messages, newest thread first.
    func conversations() async throws -> [Conversation]
    /// Creates/updates the thread header (name, owner, unread, last activity).
    func saveConversation(_ conversation: Conversation) async throws
    /// Appends one trainee message and bumps the academy's unread count.
    func append(_ message: Message, to conversationID: UUID) async throws

    // MARK: Academy side
    /// Threads addressed to the signed-in academy account, newest first.
    /// Messages come back from the academy's point of view.
    func academyConversations() async throws -> [Conversation]
    /// Appends an academy reply and bumps the trainee's unread count.
    func academyReply(_ message: Message, to conversationID: UUID) async throws
    /// Clears the academy-side unread count.
    func markAcademyRead(_ conversationID: UUID) async throws
}
