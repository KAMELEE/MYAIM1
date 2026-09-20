import SwiftUI

struct ProviderCoursesView: View {
    @Environment(Router.self) private var router
    @Environment(ProviderStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.md) {
                MYButton(title: "إضافة دورة جديدة", icon: "plus") {
                    router.push(.addCourse)
                }
                ForEach(store.courses) { course in
                    courseCard(course)
                }
            }
            .padding(MYSpacing.screen)
        }
        .myTabBarInset()
        .myScreenBackground()
        .navigationTitle("دوراتي")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func courseCard(_ course: Course) -> some View {
        VStack(spacing: MYSpacing.md) {
            Button {
                Haptics.light()
                router.push(.courseDetail(course))
            } label: {
                CourseRow(course: course)
            }
            .buttonStyle(PressableButtonStyle())
            HStack(spacing: MYSpacing.md) {
                stat("person.2", "\(MYFormat.integer(course.students)) طالب")
                stat("tag", MYFormat.price(course.price))
                Spacer()
                Toggle("", isOn: Binding(
                    get: { course.isPublished },
                    set: { _ in store.togglePublish(course) }
                ))
                .labelsHidden()
                .tint(MYColor.primary)
                Text(course.isPublished ? "منشورة" : "مسودة")
                    .font(MYTypography.caption)
                    .foregroundStyle(MYColor.textSecondary)
            }
            .padding(.horizontal, MYSpacing.xs)
        }
        .padding(.bottom, MYSpacing.sm)
    }

    private func stat(_ icon: String, _ text: String) -> some View {
        HStack(spacing: MYSpacing.xxs) {
            Image(systemName: icon).font(.system(size: 12)).foregroundStyle(MYColor.textTertiary)
            Text(text).font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
        }
    }
}

#Preview {
    NavigationStack { ProviderCoursesView() }
        .environment(Router())
        .environment(ProviderStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
