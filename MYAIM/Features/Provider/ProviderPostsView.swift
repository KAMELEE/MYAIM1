import SwiftUI

struct ProviderPostsView: View {
    @Environment(Router.self) private var router
    @Environment(ProviderStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.md) {
                MYButton(title: "نشر منشور جديد", icon: "square.and.pencil") {
                    router.push(.publishPost)
                }
                if store.posts.isEmpty {
                    MYEmptyState(icon: "megaphone", title: "لا منشورات بعد",
                                 message: "شارك أخبار أكاديميتك ونصائحك مع متابعيك.")
                        .padding(.top, MYSpacing.xl)
                } else {
                    ForEach(store.posts) { post in
                        postCard(post)
                    }
                }
            }
            .padding(MYSpacing.screen)
        }
        .myTabBarInset()
        .myScreenBackground()
        .navigationTitle("المنشورات")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func postCard(_ post: Post) -> some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            HStack(spacing: MYSpacing.sm) {
                MYRemoteImage(assetName: store.category.imageName, accent: store.category.accent)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 1) {
                    Text(store.academyName).font(MYTypography.cardTitle).foregroundStyle(MYColor.textPrimary)
                    Text(relative(post.date)).font(MYTypography.caption).foregroundStyle(MYColor.textTertiary)
                }
                Spacer()
            }
            Text(post.text)
                .font(MYTypography.body).foregroundStyle(MYColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            if let img = post.imageName {
                MYRemoteImage(assetName: img, accent: store.category.accent)
                    .frame(height: 160).frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
            }
            HStack(spacing: MYSpacing.lg) {
                label("heart", "\(post.likes)")
                label("bubble.left", "\(post.comments)")
                Spacer()
                Image(systemName: "square.and.arrow.up").font(.system(size: 14)).foregroundStyle(MYColor.textTertiary)
            }
        }
        .myCard()
    }

    private func label(_ icon: String, _ text: String) -> some View {
        HStack(spacing: MYSpacing.xxs) {
            Image(systemName: icon).font(.system(size: 14)).foregroundStyle(MYColor.textSecondary)
            Text(text).font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
        }
    }

    private func relative(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter(); f.locale = Locale(identifier: "ar"); f.unitsStyle = .short
        return f.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    NavigationStack { ProviderPostsView() }
        .environment(Router())
        .environment(ProviderStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
