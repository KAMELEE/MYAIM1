import SwiftUI
import Observation

/// App-wide chat store (trainee ↔ provider). Seeded, in-memory.
@Observable
final class MessagesStore {
    var conversations: [Conversation]

    init() {
        conversations = [
            Conversation(
                name: "أكاديمية النخبة الرياضية", avatarAsset: "photo_sports",
                category: .sports, unread: 2,
                messages: [
                    Message(text: "أهلاً بك! كيف يمكننا مساعدتك؟", fromMe: false, date: Date().addingTimeInterval(-3600 * 3)),
                    Message(text: "أريد الاستفسار عن برنامج اللياقة الشامل", fromMe: true, date: Date().addingTimeInterval(-3600 * 2.8)),
                    Message(text: "بالتأكيد، البرنامج ٨ أسابيع ويشمل خطة تغذية ومتابعة أسبوعية.", fromMe: false, date: Date().addingTimeInterval(-3600 * 2.5)),
                    Message(text: "نتطلع لرؤيتك في أول حصة 💪", fromMe: false, date: Date().addingTimeInterval(-3600))
                ]
            ),
            Conversation(
                name: "منصّة مسار لتطوير الذات", avatarAsset: "photo_selfdev",
                category: .selfDevelopment, unread: 0,
                messages: [
                    Message(text: "شكرًا لحجزك برنامج القيادة والإنتاجية!", fromMe: false, date: Date().addingTimeInterval(-86400)),
                    Message(text: "متشوّق للبدء 🙌", fromMe: true, date: Date().addingTimeInterval(-86400 + 600))
                ]
            ),
            Conversation(
                name: "تِك سوليوشنز", avatarAsset: "photo_tech",
                category: .tech, unread: 1,
                messages: [
                    Message(text: "معسكر iOS يبدأ الأحد القادم، هل أنت جاهز؟", fromMe: false, date: Date().addingTimeInterval(-86400 * 2))
                ]
            )
        ]
    }

    var totalUnread: Int { conversations.reduce(0) { $0 + $1.unread } }

    func send(_ text: String, to id: UUID) {
        guard let i = conversations.firstIndex(where: { $0.id == id }) else { return }
        let t = text.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return }
        conversations[i].messages.append(Message(text: t, fromMe: true, date: Date()))
    }

    func markRead(_ id: UUID) {
        guard let i = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[i].unread = 0
    }

    func conversation(_ id: UUID) -> Conversation? { conversations.first { $0.id == id } }

    /// Opens (or creates) a conversation with a service's academy — the
    /// "تواصل" entry point. Reuses the existing thread when present.
    @discardableResult
    func openConversation(with service: Service) -> Conversation {
        if let existing = conversations.first(where: { $0.name == service.providerName }) {
            return existing
        }
        let conversation = Conversation(
            name: service.providerName,
            avatarAsset: service.category.imageName,
            category: service.category,
            unread: 0,
            messages: [
                Message(text: "أهلاً بك في \(service.providerName)! اسألنا عن \(service.title) وسنرد عليك بسرعة.",
                        fromMe: false, date: Date())
            ]
        )
        conversations.insert(conversation, at: 0)
        return conversation
    }
}
