import SwiftUI
import Observation

/// App-wide chat store (trainee ↔ provider).
///
/// - DEMO/preview builds: seeded threads, in-memory, with simulated academy
///   replies so the demo never goes silent.
/// - Production builds: the signed-in user's threads live in Firestore
///   (`conversations`); every sent message is written through. No fake
///   replies are generated — answers come from the academy.
@MainActor
@Observable
final class MessagesStore {
    var conversations: [Conversation]

    private let repo: MessagesRepository?

    init(repo: MessagesRepository? = AppRepositories.messages()) {
        self.repo = repo
        guard repo == nil else {
            conversations = []
            Task { await reload() }
            return
        }
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

    /// Re-fetches the signed-in user's threads (call after login).
    func reload() async {
        guard let repo else { return }
        do {
            conversations = try await repo.conversations()
        } catch {
            // Keep what we have; errors don't block the chat screen.
        }
    }

    private func persist(_ work: @escaping (MessagesRepository) async throws -> Void) {
        guard let repo else { return }
        Task { try? await work(repo) }
    }

    var totalUnread: Int { conversations.reduce(0) { $0 + $1.unread } }

    /// Conversations where the academy is "typing…" (auto-reply inbound).
    var typingIn: Set<UUID> = []

    func send(_ text: String, to id: UUID) {
        guard let i = conversations.firstIndex(where: { $0.id == id }) else { return }
        let t = text.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return }
        let message = Message(text: t, fromMe: true, date: Date())
        conversations[i].messages.append(message)
        persist { try await $0.append(message, to: id) }
        queueAutoReply(to: id)
    }

    /// Sends a locally recorded voice note into the thread.
    func sendVoice(url: URL, duration: Double, to id: UUID) {
        guard let i = conversations.firstIndex(where: { $0.id == id }) else { return }
        let message = Message(text: "", fromMe: true, date: Date(),
                              audioURL: url, audioDuration: duration)
        conversations[i].messages.append(message)
        persist { try await $0.append(message, to: id) }
        queueAutoReply(to: id)
    }

    /// Simulates the academy replying shortly after your message, so the
    /// thread stays alive instead of going silent.
    private func queueAutoReply(to id: UUID) {
        // Real accounts: no simulated academy replies.
        guard repo == nil else { return }
        typingIn.insert(id)
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.2))
            guard let i = conversations.firstIndex(where: { $0.id == id }) else { return }
            typingIn.remove(id)
            conversations[i].messages.append(
                Message(text: Self.replies[conversations[i].messages.count % Self.replies.count],
                        fromMe: false, date: Date())
            )
        }
    }

    private static let replies: [String] = [
        "وصلتنا رسالتك، نرد عليك بالتفاصيل بعد قليل 🙏",
        "شكراً لتواصلك! كيف نقدر نساعدك أكثر؟",
        "سؤال جيد — نأكد لك المواعيد المتاحة ونعود إليك.",
        "أبشر، نسويها لك 🌟",
        "نراسل الجهة المسؤولة ونرد عليك بأسرع وقت."
    ]

    func markRead(_ id: UUID) {
        guard let i = conversations.firstIndex(where: { $0.id == id }) else { return }
        guard conversations[i].unread != 0 else { return }
        conversations[i].unread = 0
        let convo = conversations[i]
        persist { try await $0.saveConversation(convo) }
    }

    func conversation(_ id: UUID) -> Conversation? { conversations.first { $0.id == id } }

    /// Opens (or creates) a conversation with a service's academy — the
    /// "تواصل" entry point. Reuses the existing thread when present.
    @discardableResult
    func openConversation(with service: Service, traineeName: String? = nil) -> Conversation {
        // Same academy → same thread. Owned services match by account,
        // sample-catalog ones by name.
        if let existing = conversations.first(where: {
            if let owner = service.ownerUid { return $0.providerUid == owner }
            return $0.providerUid == nil && $0.name == service.providerName
        }) {
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
            ],
            providerUid: service.ownerUid,
            traineeName: traineeName
        )
        conversations.insert(conversation, at: 0)
        if let welcome = conversation.messages.first {
            persist { repo in
                try await repo.saveConversation(conversation)
                try await repo.append(welcome, to: conversation.id)
            }
        }
        return conversation
    }
}
