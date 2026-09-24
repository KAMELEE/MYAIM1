import SwiftUI

struct ProviderDashboardView: View {
    @Environment(Router.self) private var router
    @Environment(ProviderStore.self) private var store
    @State private var demoPushed = false

    private let cols = [GridItem(.flexible(), spacing: MYSpacing.md),
                        GridItem(.flexible(), spacing: MYSpacing.md)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                header
                statsGrid
                quickActions
                latestCourses
            }
            .padding(.horizontal, MYSpacing.screen)
            .padding(.top, MYSpacing.sm)
        }
        .myTabBarInset()
        .myScreenBackground()
        .navigationTitle("لوحة الأكاديمية")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            #if DEBUG
            guard !demoPushed, let r = DemoLaunch.route else { return }
            demoPushed = true
            if r == "addCourse" { router.push(.addCourse) }
            if r == "publishPost" { router.push(.publishPost) }
            if r == "publishStory" { router.push(.publishStory) }
            if r == "publishAd" { router.push(.publishAd) }
            if r == "courseDetail", let c = store.courses.first { router.push(.courseDetail(c)) }
            #endif
        }
    }

    private var header: some View {
        HStack(spacing: MYSpacing.md) {
            MYRemoteImage(assetName: store.category.imageName, accent: store.category.accent)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(store.academyName)
                    .font(MYTypography.cardTitle)
                    .foregroundStyle(MYColor.textPrimary)
                    .lineLimit(1)
                MYTag(text: "باقة \(store.currentPlan.name)", icon: "crown.fill", style: .brand)
            }
            Spacer()
        }
        .padding(MYSpacing.md)
        .myCard(padding: MYSpacing.md)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: cols, spacing: MYSpacing.md) {
            stat("person.2.fill", MYFormat.integer(store.totalStudents), "الطلاب", MYColor.primary)
            stat("book.fill", "\(store.publishedCount)", "دورات منشورة", Color(hex: "#2B77E0"))
            stat("star.fill", MYFormat.rating(store.avgRating), "متوسط التقييم", MYColor.star)
            stat("banknote.fill", MYFormat.price(store.monthlyRevenue), "أرباح الشهر", MYColor.success)
        }
    }

    private func stat(_ icon: String, _ value: String, _ label: String, _ tint: Color) -> some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: MYRadius.sm, style: .continuous))
            Text(value)
                .font(MYTypography.section)
                .foregroundStyle(MYColor.textPrimary)
            Text(label)
                .font(MYTypography.caption)
                .foregroundStyle(MYColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .myCard(padding: MYSpacing.md)
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            MYSectionHeader(title: "إجراءات سريعة", actionTitle: nil)
            LazyVGrid(columns: cols, spacing: MYSpacing.md) {
                action("plus.circle.fill", "إضافة دورة") { router.push(.addCourse) }
                action("megaphone.fill", "نشر منشور") { router.push(.publishPost) }
                action("flame.fill", "نشر ستوري") { router.push(.publishStory) }
                action("banner.fill", "نشر إعلان") { router.push(.publishAd) }
            }
        }
    }

    private func action(_ icon: String, _ title: String, _ tap: @escaping () -> Void) -> some View {
        Button {
            Haptics.light(); tap()
        } label: {
            VStack(spacing: MYSpacing.sm) {
                Image(systemName: icon).font(.system(size: 22)).foregroundStyle(.white)
                Text(title).font(MYTypography.button).foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, MYSpacing.lg)
            .background(MYColor.primary)
            .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var latestCourses: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            MYSectionHeader(title: "أحدث الدورات", actionTitle: nil)
            ForEach(store.courses.prefix(3)) { course in
                Button {
                    Haptics.light()
                    router.push(.courseDetail(course))
                } label: {
                    CourseRow(course: course)
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }
}

/// Reusable provider course row.
struct CourseRow: View {
    let course: Course
    var body: some View {
        HStack(spacing: MYSpacing.md) {
            MYRemoteImage(assetName: course.category.imageName, accent: course.category.accent)
                .frame(width: 54, height: 54)
                .clipShape(RoundedRectangle(cornerRadius: MYRadius.sm, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(course.title)
                    .font(MYTypography.cardTitle).foregroundStyle(MYColor.textPrimary).lineLimit(1)
                HStack(spacing: MYSpacing.sm) {
                    MYRating(rating: course.rating, showCount: false)
                    Text("· \(MYFormat.integer(course.students)) طالب")
                        .font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
                }
            }
            Spacer(minLength: 0)
            MYTag(text: course.isPublished ? "منشورة" : "مسودة",
                  style: course.isPublished ? .success : .neutral)
        }
        .myCard(padding: MYSpacing.md)
    }
}

#Preview {
    NavigationStack { ProviderDashboardView() }
        .environment(Router())
        .environment(ProviderStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
