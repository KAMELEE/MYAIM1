import SwiftUI

struct AddCourseView: View {
    @Environment(Router.self) private var router
    @Environment(ProviderStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var category: ServiceCategory = .sports
    @State private var price = ""
    @State private var summary = ""
    @State private var errors: [String: String] = [:]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                Text("أضف دورة جديدة لأكاديميتك واستقبل الطلاب.")
                    .font(MYTypography.secondary).foregroundStyle(MYColor.textSecondary)

                MYTextField(title: "عنوان الدورة", icon: "book",
                            placeholder: "مثال: برنامج اللياقة الشامل",
                            text: $title, error: errors["title"])

                categoryPicker

                MYTextField(title: "السعر (ر.س)", icon: "tag",
                            placeholder: "450", text: $price,
                            keyboard: .numberPad, error: errors["price"])

                VStack(alignment: .leading, spacing: MYSpacing.xs) {
                    Text("وصف الدورة").font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
                    TextField("اكتب وصفًا مختصرًا لما ستقدّمه الدورة", text: $summary, axis: .vertical)
                        .font(MYTypography.body)
                        .lineLimit(3...6)
                        .padding(MYSpacing.md)
                        .background(MYColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                            .strokeBorder(MYColor.border, lineWidth: 1))
                }
            }
            .padding(MYSpacing.screen)
        }
        .safeAreaInset(edge: .bottom) {
            MYButton(title: "نشر الدورة", icon: "checkmark") { save() }
                .padding(MYSpacing.lg)
                .background(.regularMaterial)
                .myTabBarClearance()
        }
        .myScreenBackground()
        .navigationTitle("دورة جديدة")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: MYSpacing.xs) {
            Text("المجال").font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MYSpacing.sm) {
                    ForEach(ServiceCategory.allCases) { c in
                        let on = category == c
                        Button { Haptics.selection(); category = c } label: {
                            HStack(spacing: MYSpacing.xs) {
                                Image(systemName: c.icon).font(.system(size: 13, weight: .semibold))
                                Text(c.title).font(MYTypography.secondary)
                            }
                            .foregroundStyle(on ? .white : MYColor.textPrimary)
                            .padding(.horizontal, MYSpacing.md).padding(.vertical, MYSpacing.sm)
                            .background(on ? MYColor.primary : MYColor.surface)
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(on ? .clear : MYColor.border, lineWidth: 1))
                        }
                    }
                }
            }
        }
    }

    private func save() {
        errors = [:]
        if title.trimmingCharacters(in: .whitespaces).isEmpty { errors["title"] = "عنوان الدورة مطلوب" }
        let priceValue = Double(price)
        if priceValue == nil { errors["price"] = "أدخل سعرًا صحيحًا" }
        guard errors.isEmpty, let priceValue else { Haptics.error(); return }

        let course = Course(title: title.trimmingCharacters(in: .whitespaces),
                            category: category, price: priceValue, students: 0,
                            rating: 0, isPublished: true,
                            summary: summary.trimmingCharacters(in: .whitespaces))
        store.addCourse(course)
        Haptics.success()
        dismiss()
    }
}

#Preview {
    NavigationStack { AddCourseView() }
        .environment(Router())
        .environment(ProviderStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
