import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Firestore-backed chat:
///
///     conversations/{id}
///         userId · traineeName · providerUid · name · category
///         unread (trainee side) · academyUnread · updatedAt
///     conversations/{id}/messages/{id}
///         text · fromMe (= sent by the trainee) · date · audioDuration?
///
/// Voice notes are recorded locally; only a placeholder + duration is synced
/// (uploading audio needs Firebase Storage, not yet part of the project).
final class FirestoreMessagesRepository: MessagesRepository {

    private let db = Firestore.firestore()
    private static let collection = "conversations"

    private var userId: String? { Auth.auth().currentUser?.uid }

    private func thread(_ id: UUID) -> DocumentReference {
        db.collection(Self.collection).document(id.uuidString)
    }

    // MARK: - Trainee side

    func conversations() async throws -> [Conversation] {
        guard let uid = userId else { return [] }
        let snap = try await db.collection(Self.collection)
            .whereField("userId", isEqualTo: uid)
            .getDocuments()
        return try await load(snap.documents, academySide: false)
    }

    func saveConversation(_ c: Conversation) async throws {
        guard let uid = userId else { return }
        var data: [String: Any] = [
            "userId": uid,
            "name": c.name,
            "category": c.category.rawValue,
            "unread": c.unread,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        if let avatar = c.avatarAsset { data["avatarAsset"] = avatar }
        if let provider = c.providerUid { data["providerUid"] = provider }
        if let trainee = c.traineeName { data["traineeName"] = trainee }
        try await thread(c.id).setData(data, merge: true)
    }

    func append(_ message: Message, to conversationID: UUID) async throws {
        guard userId != nil else { return }
        try await thread(conversationID).collection("messages")
            .document(message.id.uuidString)
            .setData(FirestoreMappers.messageData(message))
        var update: [String: Any] = ["updatedAt": FieldValue.serverTimestamp()]
        // Only the trainee's own messages are news for the academy (not the
        // auto greeting that opens a thread).
        if message.fromMe { update["academyUnread"] = FieldValue.increment(Int64(1)) }
        try await thread(conversationID).updateData(update)
    }

    // MARK: - Academy side

    func academyConversations() async throws -> [Conversation] {
        guard let uid = userId else { return [] }
        let snap = try await db.collection(Self.collection)
            .whereField("providerUid", isEqualTo: uid)
            .getDocuments()
        return try await load(snap.documents, academySide: true)
    }

    func academyReply(_ message: Message, to conversationID: UUID) async throws {
        guard userId != nil else { return }
        // Stored from the trainee's point of view: an academy reply is not "from me".
        var stored = message
        stored.fromMe = false
        try await thread(conversationID).collection("messages")
            .document(message.id.uuidString)
            .setData(FirestoreMappers.messageData(stored))
        try await thread(conversationID).updateData([
            "updatedAt": FieldValue.serverTimestamp(),
            "unread": FieldValue.increment(Int64(1))
        ])
    }

    func markAcademyRead(_ conversationID: UUID) async throws {
        guard userId != nil else { return }
        try await thread(conversationID).updateData(["academyUnread": 0])
    }

    // MARK: - Loading

    private func load(_ docs: [QueryDocumentSnapshot], academySide: Bool) async throws -> [Conversation] {
        var result: [(Conversation, Date)] = []
        for doc in docs {
            let data = doc.data()
            guard let name = data["name"] as? String,
                  let category = ServiceCategory(rawValue: data["category"] as? String ?? "")
            else { continue }
            let msgs = try await doc.reference.collection("messages").getDocuments()
                .documents
                .compactMap { FirestoreMappers.message(from: $0.data(), id: $0.documentID) }
                .map { m -> Message in
                    var m = m
                    if academySide { m.fromMe.toggle() }
                    return m
                }
                .sorted { $0.date < $1.date }
            let convo = Conversation(id: UUID(uuidString: doc.documentID) ?? UUID(),
                                     name: name,
                                     avatarAsset: data["avatarAsset"] as? String,
                                     category: category,
                                     unread: (data["unread"] as? NSNumber)?.intValue ?? 0,
                                     messages: msgs,
                                     providerUid: data["providerUid"] as? String,
                                     traineeName: data["traineeName"] as? String,
                                     academyUnread: (data["academyUnread"] as? NSNumber)?.intValue ?? 0)
            let updated = (data["updatedAt"] as? Timestamp)?.dateValue()
                ?? msgs.last?.date ?? .distantPast
            result.append((convo, updated))
        }
        // Sorted client-side: avoids a composite-index requirement in Firestore.
        return result.sorted { $0.1 > $1.1 }.map { $0.0 }
    }
}

// MARK: - Mappers

extension FirestoreMappers {

    static func messageData(_ m: Message) -> [String: Any] {
        var data: [String: Any] = [
            "text": m.isVoice ? "🎤 رسالة صوتية" : m.text,
            "fromMe": m.fromMe,
            "date": Timestamp(date: m.date)
        ]
        if let d = m.audioDuration { data["audioDuration"] = d }
        return data
    }

    static func message(from data: [String: Any], id: String) -> Message? {
        guard let text = data["text"] as? String else { return nil }
        // Audio files are device-local, so a synced voice note comes back as
        // its text placeholder (audioURL stays nil).
        return Message(id: UUID(uuidString: id) ?? UUID(),
                       text: text,
                       fromMe: data["fromMe"] as? Bool ?? true,
                       date: (data["date"] as? Timestamp)?.dateValue() ?? Date())
    }
}
