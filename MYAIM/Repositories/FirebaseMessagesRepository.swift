import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Firestore-backed chat, scoped to the signed-in user:
///
///     conversations/{id}                 userId · name · category · unread · updatedAt
///     conversations/{id}/messages/{id}   text · fromMe · date · audioDuration?
///
/// Voice notes are recorded locally; only a placeholder + duration is synced
/// (uploading audio needs Firebase Storage, not yet part of the project).
final class FirestoreMessagesRepository: MessagesRepository {

    private let db = Firestore.firestore()
    private static let collection = "conversations"

    private var userId: String? { Auth.auth().currentUser?.uid }

    func conversations() async throws -> [Conversation] {
        guard let uid = userId else { return [] }
        let snap = try await db.collection(Self.collection)
            .whereField("userId", isEqualTo: uid)
            .getDocuments()

        var result: [(Conversation, Date)] = []
        for doc in snap.documents {
            let data = doc.data()
            guard let name = data["name"] as? String,
                  let category = ServiceCategory(rawValue: data["category"] as? String ?? "")
            else { continue }
            let msgs = try await doc.reference.collection("messages").getDocuments()
                .documents
                .compactMap { FirestoreMappers.message(from: $0.data(), id: $0.documentID) }
                .sorted { $0.date < $1.date }
            let convo = Conversation(id: UUID(uuidString: doc.documentID) ?? UUID(),
                                     name: name,
                                     avatarAsset: data["avatarAsset"] as? String,
                                     category: category,
                                     unread: (data["unread"] as? NSNumber)?.intValue ?? 0,
                                     messages: msgs)
            let updated = (data["updatedAt"] as? Timestamp)?.dateValue()
                ?? msgs.last?.date ?? .distantPast
            result.append((convo, updated))
        }
        // Sorted client-side: avoids a composite-index requirement in Firestore.
        return result.sorted { $0.1 > $1.1 }.map { $0.0 }
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
        try await db.collection(Self.collection)
            .document(c.id.uuidString)
            .setData(data, merge: true)
    }

    func append(_ message: Message, to conversationID: UUID) async throws {
        guard userId != nil else { return }
        let thread = db.collection(Self.collection).document(conversationID.uuidString)
        try await thread.collection("messages")
            .document(message.id.uuidString)
            .setData(FirestoreMappers.messageData(message))
        try await thread.updateData(["updatedAt": FieldValue.serverTimestamp()])
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
