import SwiftUI

/// Edit the academy's basic identity: name, tagline, and category.
struct AcademyInfoView: View {
    @Environment(ProviderStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var tagline = ""
    @State private var category: ServiceCategory = .sports
    @State private var saved = false

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                field("اسم الأكاديمية", text: $name, placeholder: "مثال: أكاديمية النخبة الرياضية")
                field("الوصف المختصر", text: $tagline, placeholder: "مثال: أكاديمية متخصصة في اللياقة والتدريب")

                VStack(alignment: .leading, spacing: MYSpacing.sm) {
                    Text("الفئة").font(MYTypography.secondary).foregroundStyle(MYColor.textSecondary)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: MYSpacing.sm) {
                        ForEach(ServiceCategory.allCases) { c in
                            categoryChip(c)
                        }
                    }
                }
                .myCard()

                MYButton(title: saved ? "تم الحفظ" : "حفظ التغييرات",
                         icon: saved ? "checkmark" : "tray.and.arrow.down",
                         isEnabled: canSave) {
                    store.updateIdentity(name: name, tagline: tagline, category: category)
                    Haptics.success()
                    withAnimation { saved = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { dismiss() }
                }
            }
            .padding(MYSpacing.screen)
        }
        .myScreenBackground()
        .navigationTitle("معلومات الأكاديمية")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            name = store.academyName
            tagline = store.academyTagline
            category = store.category
        }
    }

    private func field(_ label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            Text(label).font(MYTypography.secondary).foregroundStyle(MYColor.textSecondary)
            TextField(placeholder, text: text)
                .font(MYTypography.body)
                .padding(.horizontal, MYSpacing.md)
                .frame(minHeight: 48)
                .background(MYColor.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
        }
    }

    private func categoryChip(_ c: ServiceCategory) -> some View {
        let on = category == c
        return Button {
            Haptics.selection(); withAnimation { category = c }
        } label: {
            HStack(spacing: MYSpacing.xs) {
                Image(systemName: c.icon).font(.system(size: 14))
                Text(c.title).font(MYTypography.secondary).lineLimit(1)
            }
            .foregroundStyle(on ? .white : MYColor.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, MYSpacing.md)
            .background(on ? MYColor.primary : MYColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                .strokeBorder(on ? .clear : MYColor.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack { AcademyInfoView() }
        .environment(ProviderStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
