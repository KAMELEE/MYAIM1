import SwiftUI

/// Academy-side: publish a story that appears in the trainees' stories row.
struct PublishStoryView: View {
    @Environment(ProviderStore.self) private var store
    @Environment(FeaturedStore.self) private var featured
    @Environment(\.dismiss) private var dismiss

    @State private var caption = ""
    @State private var attachImage = true

    private var canPublish: Bool { !caption.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                academyRow

                Text("تظهر الستوري أعلى الرئيسية للمتدربين لمدة ٢٤ ساعة.")
                    .font(MYTypography.caption)
                    .foregroundStyle(MYColor.textSecondary)

                TextField("عن ماذا تتحدث الستوري؟ مثال: خصم ٢٥٪ لفترة محدودة",
                          text: $caption, axis: .vertical)
                    .font(MYTypography.body)
                    .lineLimit(2...4)
                    .padding(MYSpacing.md)
                    .background(MYColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                        .strokeBorder(MYColor.border, lineWidth: 1))

                Toggle(isOn: $attachImage) {
                    Label("استخدام صورة الأكاديمية", systemImage: "photo")
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
            MYButton(title: "نشر الستوري", icon: "flame.fill", isEnabled: canPublish) {
                featured.publishStory(
                    providerName: store.academyName,
                    imageAsset: attachImage ? store.category.imageName : nil,
                    accent: store.category.accent,
                    caption: caption.trimmingCharacters(in: .whitespaces)
                )
                Haptics.success()
                dismiss()
            }
            .padding(MYSpacing.lg)
            .background(.regularMaterial)
            .myTabBarClearance()
        }
        .myScreenBackground()
        .navigationTitle("ستوري جديد")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
    }

    private var academyRow: some View {
        HStack(spacing: MYSpacing.sm) {
            MYRemoteImage(assetName: store.category.imageName, accent: store.category.accent)
                .frame(width: 44, height: 44).clipShape(Circle())
            Text(store.academyName)
                .font(MYTypography.cardTitle).foregroundStyle(MYColor.textPrimary)
            Spacer()
        }
    }
}

/// Academy-side: publish a featured ad shown to trainees in «أكاديميات مميزة».
struct PublishAdView: View {
    @Environment(ProviderStore.self) private var store
    @Environment(FeaturedStore.self) private var featured
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var subtitle = ""
    @State private var attachImage = true

    private var canPublish: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && !subtitle.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                academyRow

                Text("يظهر الإعلان في خانة «أكاديميات مميزة» على الرئيسية.")
                    .font(MYTypography.caption)
                    .foregroundStyle(MYColor.textSecondary)

                VStack(alignment: .leading, spacing: MYSpacing.xs) {
                    Text("عنوان الإعلان").font(MYTypography.secondary).foregroundStyle(MYColor.textPrimary)
                    TextField("مثال: خصم ٣٠٪ على الاشتراك الشهري", text: $title)
                        .font(MYTypography.body)
                        .padding(MYSpacing.md)
                        .background(MYColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                            .strokeBorder(MYColor.border, lineWidth: 1))
                }

                VStack(alignment: .leading, spacing: MYSpacing.xs) {
                    Text("الوصف").font(MYTypography.secondary).foregroundStyle(MYColor.textPrimary)
                    TextField("مثال: برامج صباحية ومسائية بإشراف مدربين معتمدين",
                              text: $subtitle, axis: .vertical)
                        .font(MYTypography.body)
                        .lineLimit(1...3)
                        .padding(MYSpacing.md)
                        .background(MYColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                            .strokeBorder(MYColor.border, lineWidth: 1))
                }

                Toggle(isOn: $attachImage) {
                    Label("استخدام صورة الأكاديمية", systemImage: "photo")
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
            MYButton(title: "نشر الإعلان", icon: "megaphone.fill", isEnabled: canPublish) {
                featured.publishAd(
                    title: title.trimmingCharacters(in: .whitespaces),
                    subtitle: subtitle.trimmingCharacters(in: .whitespaces),
                    providerName: store.academyName,
                    imageAsset: attachImage ? store.category.imageName : nil,
                    accent: store.category.accent
                )
                Haptics.success()
                dismiss()
            }
            .padding(MYSpacing.lg)
            .background(.regularMaterial)
            .myTabBarClearance()
        }
        .myScreenBackground()
        .navigationTitle("إعلان جديد")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
    }

    private var academyRow: some View {
        HStack(spacing: MYSpacing.sm) {
            MYRemoteImage(assetName: store.category.imageName, accent: store.category.accent)
                .frame(width: 44, height: 44).clipShape(Circle())
            Text(store.academyName)
                .font(MYTypography.cardTitle).foregroundStyle(MYColor.textPrimary)
            Spacer()
        }
    }
}

#Preview {
    NavigationStack { PublishStoryView() }
        .environment(ProviderStore())
        .environment(FeaturedStore())
        .environment(\.layoutDirection, .rightToLeft)
}
