import SwiftUI

/// Academy side: trainees' threads addressed to this academy.
struct AcademyInboxView: View {
    @Environment(Router.self) private var router
    @Environment(AcademyInboxStore.self) private var store

    var body: some View {
        Group {
            if store.conversations.isEmpty {
                MYEmptyState(icon: "tray",
                             title: "لا رسائل من المتدربين بعد",
                             message: "عند نشر دوراتك، تصلك هنا استفسارات المتدربين وترد عليها مباشرة.")
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: MYSpacing.sm) {
                        ForEach(store.conversations) { convo in
                            row(convo)
                                .myAppear(item: convo, in: store.conversations)
                        }
                    }
                    .padding(MYSpacing.screen)
                }
            }
        }
        .myTabBarInset()
        .myScreenBackground()
        .navigationTitle("رسائل المتدربين")
        .navigationBarTitleDisplayMode(.inline)
        .task { await store.reload() }
        .refreshable { await store.reload() }
    }

    private func row(_ convo: Conversation) -> some View {
        Button {
            Haptics.light()
            router.push(.academyChat(convo))
        } label: {
            HStack(spacing: MYSpacing.md) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(MYColor.primary.opacity(0.85))
                    .frame(width: 52, height: 52)
                    .background(MYColor.primaryTint, in: Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text(convo.traineeName ?? "متدرب")
                        .font(MYTypography.cardTitle).foregroundStyle(MYColor.textPrimary).lineLimit(1)
                    Text(convo.lastMessage?.text ?? "")
                        .font(MYTypography.secondary).foregroundStyle(MYColor.textSecondary).lineLimit(1)
                }
                Spacer(minLength: MYSpacing.sm)
                VStack(alignment: .trailing, spacing: 6) {
                    if let d = convo.lastMessage?.date {
                        Text(MYFormat.time(d))
                            .font(MYTypography.caption).foregroundStyle(MYColor.textTertiary)
                    }
                    if convo.academyUnread > 0 {
                        Text("\(convo.academyUnread)")
                            .font(.appFont(11, weight: .bold)).foregroundStyle(.white)
                            .frame(minWidth: 20, minHeight: 20)
                            .background(MYColor.primary).clipShape(Circle())
                    }
                }
            }
            .myCard(padding: MYSpacing.md)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

/// Academy side of one thread: read the trainee's messages and reply.
struct AcademyChatView: View {
    @Environment(AcademyInboxStore.self) private var store
    let conversation: Conversation

    @State private var draft = ""
    @FocusState private var focused: Bool

    private var live: Conversation { store.conversation(conversation.id) ?? conversation }
    private var canSend: Bool { !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    /// Ready-made academy replies for the most common questions.
    private let quickReplies = ["أهلاً بك! كيف نقدر نخدمك؟",
                                "المواعيد المتاحة: مساءً من الأحد إلى الخميس.",
                                "تقدر تحجز مباشرة من صفحة الدورة في التطبيق."]

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: MYSpacing.sm) {
                        ForEach(live.messages) { msg in
                            bubble(msg).id(msg.id)
                        }
                    }
                    .padding(MYSpacing.screen)
                }
                .onChange(of: live.messages.count) { _, _ in
                    if let last = live.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
                .onAppear {
                    store.markRead(live.id)
                    if let last = live.messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            quickReplyRow
            inputBar
        }
        .myScreenBackground()
        .navigationTitle(live.traineeName ?? "متدرب")
        .navigationBarTitleDisplayMode(.inline)
        // Production: pick up new trainee messages while the thread is open.
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5))
                await store.reload()
            }
        }
    }

    private func bubble(_ msg: Message) -> some View {
        HStack {
            if !msg.fromMe { Spacer(minLength: 40) }
            VStack(alignment: msg.fromMe ? .trailing : .leading, spacing: 3) {
                Text(msg.text)
                    .font(MYTypography.body)
                    .foregroundStyle(msg.fromMe ? .white : MYColor.textPrimary)
                    .padding(.horizontal, MYSpacing.md)
                    .padding(.vertical, MYSpacing.sm)
                    .background(msg.fromMe ? MYColor.primary : MYColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous)
                            .strokeBorder(msg.fromMe ? .clear : MYColor.border, lineWidth: 0.5)
                    )
                Text(MYFormat.time(msg.date))
                    .font(MYTypography.caption).foregroundStyle(MYColor.textTertiary)
            }
            if msg.fromMe { Spacer(minLength: 40) }
        }
    }

    private var quickReplyRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MYSpacing.sm) {
                ForEach(quickReplies, id: \.self) { reply in
                    Button {
                        draft = reply
                        focused = true
                        Haptics.selection()
                    } label: {
                        Text(reply)
                            .font(MYTypography.caption)
                            .foregroundStyle(MYColor.primary)
                            .padding(.horizontal, MYSpacing.md)
                            .padding(.vertical, MYSpacing.xs + 2)
                            .background(MYColor.primaryTint)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, MYSpacing.md)
            .padding(.vertical, MYSpacing.xs)
        }
    }

    private var inputBar: some View {
        HStack(spacing: MYSpacing.sm) {
            TextField("اكتب ردك…", text: $draft, axis: .vertical)
                .font(MYTypography.body)
                .lineLimit(1...4)
                .focused($focused)
                .padding(.horizontal, MYSpacing.md)
                .frame(minHeight: 44)
                .background(MYColor.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))

            Button {
                store.reply(draft, to: live.id)
                draft = ""
                Haptics.light()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(canSend ? MYColor.primary : MYColor.textTertiary)
                    .clipShape(Circle())
            }
            .disabled(!canSend)
        }
        .padding(MYSpacing.md)
        .background(.regularMaterial)
        .overlay(alignment: .top) { Divider() }
        .myTabBarClearance()
    }
}

#Preview {
    NavigationStack { AcademyInboxView() }
        .environment(Router())
        .environment(AcademyInboxStore(repo: nil))
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
