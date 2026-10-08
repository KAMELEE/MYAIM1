import SwiftUI
import Observation

/// The academy's inbox: trainees' threads addressed to this academy account.
/// Messages are held from the ACADEMY's point of view (`fromMe` = academy).
///
/// - DEMO/preview builds: two seeded trainee threads, replies stay in memory.
/// - Production builds: threads where `providerUid == signed-in uid`;
///   replies are written to Firestore and show up on the trainee's side.
@MainActor
@Observable
final class AcademyInboxStore {
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
                category: .sports, unread: 0,
                messages: [
                    Message(text: "أهلاً بك! اسألنا عن برنامج اللياقة الشامل وسنرد عليك بسرعة.",
                            fromMe: true, date: Date().addingTimeInterval(-3600 * 4)),
                    Message(text: "السلام عليكم، هل يوجد موعد مسائي للبرنامج؟",
                            fromMe: false, date: Date().addingTimeInterval(-3600 * 3.5)),
                    Message(text: "وكم سعر الاشتراك الشهري؟",
                            fromMe: false, date: Date().addingTimeInterval(-3600 * 3.4))
                ],
                traineeName: "عبدالله", academyUnread: 2
            ),
            Conversation(
                name: "أكاديمية النخبة الرياضية", avatarAsset: "photo_sports",
                category: .sports, unread: 0,
                messages: [
                    Message(text: "هل البرنامج مناسب للمبتدئين؟",
                            fromMe: false, date: Date().addingTimeInterval(-86400)),
                    Message(text: "نعم، نبدأ معك حسب مستواك 💪",
                            fromMe: true, date: Date().addingTimeInterval(-86400 + 900))
                ],
                traineeName: "سارة", academyUnread: 0
            )
        ]
    }

    var totalUnread: Int { conversations.reduce(0) { $0 + $1.academyUnread } }

    func conversation(_ id: UUID) -> Conversation? { conversations.first { $0.id == id } }

    /// Re-fetches this academy's threads (call after login / on appear).
    func reload() async {
        guard let repo else { return }
        do {
            conversations = try await repo.academyConversations()
        } catch {
            // Keep what we have; the inbox stays usable offline.
        }
    }

    func reply(_ text: String, to id: UUID) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty, let i = conversations.firstIndex(where: { $0.id == id }) else { return }
        let message = Message(text: t, fromMe: true, date: Date())
        conversations[i].messages.append(message)
        guard let repo else { return }
        Task { try? await repo.academyReply(message, to: id) }
    }

    func markRead(_ id: UUID) {
        guard let i = conversations.firstIndex(where: { $0.id == id }),
              conversations[i].academyUnread != 0 else { return }
        conversations[i].academyUnread = 0
        guard let repo else { return }
        Task { try? await repo.markAcademyRead(id) }
    }
}
