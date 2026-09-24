import SwiftUI

struct ChatView: View {
    @Environment(MessagesStore.self) private var store
    let conversation: Conversation

    @State private var draft = ""
    @FocusState private var focused: Bool

    private var live: Conversation { store.conversation(conversation.id) ?? conversation }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: MYSpacing.sm) {
                        ForEach(live.messages) { msg in
                            bubble(msg).id(msg.id)
                        }
                        if !starterChips.isEmpty {
                            starterReplies
                                .id("starter")
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
            inputBar
        }
        .myScreenBackground()
        .navigationTitle(live.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func bubble(_ msg: Message) -> some View {
        HStack {
            if msg.fromMe { Spacer(minLength: 40) }
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
            if !msg.fromMe { Spacer(minLength: 40) }
        }
    }

    /// Quick starter questions, shown once at the start of a fresh thread to
    /// make contacting an academy frictionless.
    private var starterChips: [String] {
        live.messages.count == 1 && live.messages.first?.fromMe == false
            ? ["ما هي مواعيد الدورات؟", "هل توجد خصومات؟", "كيف أقدر أحجز؟"]
            : []
    }

    @ViewBuilder
    private var starterReplies: some View {
        if !starterChips.isEmpty {
            VStack(alignment: .leading, spacing: MYSpacing.sm) {
                ForEach(starterChips, id: \.self) { chip in
                    Button {
                        draft = chip
                        focused = true
                        Haptics.selection()
                    } label: {
                        Text(chip)
                            .font(MYTypography.secondary)
                            .foregroundStyle(MYColor.primary)
                            .padding(.horizontal, MYSpacing.md)
                            .padding(.vertical, MYSpacing.sm)
                            .background(MYColor.primaryTint)
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(MYColor.border, lineWidth: 0.5))
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, MYSpacing.xs)
        }
    }

    private var inputBar: some View {
        HStack(spacing: MYSpacing.sm) {
            TextField("اكتب رسالة…", text: $draft, axis: .vertical)
                .font(MYTypography.body)
                .lineLimit(1...4)
                .focused($focused)
                .padding(.horizontal, MYSpacing.md)
                .frame(minHeight: 44)
                .background(MYColor.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))

            Button {
                store.send(draft, to: live.id)
                draft = ""
                Haptics.light()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(draft.trimmingCharacters(in: .whitespaces).isEmpty ? MYColor.textTertiary : MYColor.primary)
                    .clipShape(Circle())
            }
            .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(MYSpacing.md)
        .background(.regularMaterial)
        .overlay(alignment: .top) { Divider() }
    }
}

#Preview {
    NavigationStack { ChatView(conversation: MessagesStore().conversations[0]) }
        .environment(MessagesStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
