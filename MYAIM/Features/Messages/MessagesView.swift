import SwiftUI

struct MessagesView: View {
    @Environment(Router.self) private var router
    @Environment(MessagesStore.self) private var store

    var body: some View {
        Group {
            if store.conversations.isEmpty {
                MYEmptyState(icon: "bubble.left.and.bubble.right",
                             title: "لا رسائل بعد",
                             message: "ستظهر هنا محادثاتك مع الأكاديميات والمدربين.")
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: MYSpacing.sm) {
                        ForEach(store.conversations) { convo in
                            row(convo)
                        }
                    }
                    .padding(MYSpacing.screen)
                }
            }
        }
        .myTabBarInset()
        .myScreenBackground()
        .navigationTitle("الرسائل")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(_ convo: Conversation) -> some View {
        Button {
            router.push(.chat(convo))
        } label: {
            HStack(spacing: MYSpacing.md) {
                MYRemoteImage(assetName: convo.avatarAsset, accent: convo.category.accent)
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text(convo.name)
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
                    if convo.unread > 0 {
                        Text("\(convo.unread)")
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

#Preview {
    NavigationStack { MessagesView() }
        .environment(Router())
        .environment(MessagesStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
