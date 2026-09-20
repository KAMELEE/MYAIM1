import SwiftUI

struct CourseDetailView: View {
    @Environment(ProviderStore.self) private var store
    let course: Course

    private var live: Course { store.courses.first { $0.id == course.id } ?? course }

    private let sampleStudents = ["أحمد العتيبي", "سارة القحطاني", "خالد الدوسري",
                                  "نورة الشهري", "فيصل الحربي", "ليان المطيري"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                header
                statsRow
                publishToggle
                about
                studentsSection
            }
            .padding(MYSpacing.screen)
        }
        .myTabBarInset()
        .myScreenBackground()
        .navigationTitle("تفاصيل الدورة")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            MYRemoteImage(assetName: live.category.imageName, accent: live.category.accent)
                .frame(height: 160).frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
            HStack {
                Text(live.title).font(MYTypography.pageTitle).foregroundStyle(MYColor.textPrimary)
                Spacer()
                MYTag(text: live.isPublished ? "منشورة" : "مسودة",
                      style: live.isPublished ? .success : .neutral)
            }
            MYTag(text: live.category.title, style: .brand)
        }
    }

    private var statsRow: some View {
        HStack(spacing: MYSpacing.md) {
            stat("person.2.fill", MYFormat.integer(live.students), "طالب")
            stat("star.fill", MYFormat.rating(live.rating), "تقييم")
            stat("banknote.fill", MYFormat.price(live.price), "السعر")
        }
    }

    private func stat(_ icon: String, _ value: String, _ label: String) -> some View {
        VStack(spacing: MYSpacing.xs) {
            Image(systemName: icon).font(.system(size: 17)).foregroundStyle(MYColor.primary)
            Text(value).font(MYTypography.cardTitle).foregroundStyle(MYColor.textPrimary)
            Text(label).font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .myCard(padding: MYSpacing.md)
    }

    private var publishToggle: some View {
        Toggle(isOn: Binding(
            get: { live.isPublished },
            set: { _ in store.togglePublish(live) }
        )) {
            Label(live.isPublished ? "الدورة منشورة" : "نشر الدورة", systemImage: "eye")
                .font(MYTypography.body).foregroundStyle(MYColor.textPrimary)
        }
        .tint(MYColor.primary)
        .padding(MYSpacing.md)
        .myCard(padding: 0)
    }

    private var about: some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            Text("وصف الدورة").font(MYTypography.section).foregroundStyle(MYColor.textPrimary)
            Text(live.summary.isEmpty ? "لا يوجد وصف بعد." : live.summary)
                .font(MYTypography.body).foregroundStyle(MYColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var studentsSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            Text("الطلاب المسجّلون").font(MYTypography.section).foregroundStyle(MYColor.textPrimary)
            ForEach(Array(sampleStudents.prefix(max(1, min(sampleStudents.count, live.students / 20 + 1)))), id: \.self) { name in
                HStack(spacing: MYSpacing.md) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 34)).foregroundStyle(MYColor.primary.opacity(0.7))
                    Text(name).font(MYTypography.body).foregroundStyle(MYColor.textPrimary)
                    Spacer()
                    Image(systemName: "message").font(.system(size: 15)).foregroundStyle(MYColor.textTertiary)
                }
                .padding(MYSpacing.md)
                .myCard(padding: 0)
            }
        }
    }
}

#Preview {
    NavigationStack { CourseDetailView(course: ProviderStore().courses[0]) }
        .environment(ProviderStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
