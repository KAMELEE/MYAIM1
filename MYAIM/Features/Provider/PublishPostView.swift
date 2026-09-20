import SwiftUI

struct PublishPostView: View {
    @Environment(ProviderStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    @State private var attachImage = true

    private var canPublish: Bool { !text.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                HStack(spacing: MYSpacing.sm) {
                    MYRemoteImage(assetName: store.category.imageName, accent: store.category.accent)
                        .frame(width: 44, height: 44).clipShape(Circle())
                    Text(store.academyName).font(MYTypography.cardTitle).foregroundStyle(MYColor.textPrimary)
                    Spacer()
                }

                TextField("بماذا تريد أن تُخبر متابعيك؟", text: $text, axis: .vertical)
                    .font(MYTypography.body)
                    .lineLimit(5...12)
                    .padding(MYSpacing.md)
                    .background(MYColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                        .strokeBorder(MYColor.border, lineWidth: 1))

                Toggle(isOn: $attachImage) {
                    Label("إرفاق صورة الأكاديمية", systemImage: "photo")
                        .font(MYTypography.body).foregroundStyle(MYColor.textPrimary)
                }
                .tint(MYColor.primary)

                if attachImage {
                    MYRemoteImage(assetName: store.category.imageName, accent: store.category.accent)
                        .frame(height: 150).frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
                }
            }
            .padding(MYSpacing.screen)
        }
        .safeAreaInset(edge: .bottom) {
            MYButton(title: "نشر", icon: "paperplane.fill", isEnabled: canPublish) {
                store.addPost(Post(text: text.trimmingCharacters(in: .whitespaces),
                                   date: Date(), likes: 0, comments: 0,
                                   imageName: attachImage ? store.category.imageName : nil))
                Haptics.success()
                dismiss()
            }
            .padding(MYSpacing.lg)
            .background(.regularMaterial)
        }
        .myScreenBackground()
        .navigationTitle("منشور جديد")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
    }
}

#Preview {
    NavigationStack { PublishPostView() }
        .environment(ProviderStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
