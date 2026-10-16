import SwiftUI

struct ProviderDashboardView: View {
    @Environment(Router.self) private var router
    @Environment(ProviderStore.self) private var store
    @Environment(AcademyInboxStore.self) private var inbox
    @State private var demoPushed = false

    private static let sheetRadius: CGFloat = 28

    var body: some View {
        ZStack(alignment: .top) {
            MYColor.background.ignoresSafeArea()
            MYColor.brandSolid.frame(height: 420).ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, MYSpacing.screen)
                        .padding(.top, MYSpacing.sm)
                        .padding(.bottom, MYSpacing.lg + Self.sheetRadius)
                        .frame(maxWidth: .infinity)
                        .background(alignment: .topLeading) {
                            BrandRings(size: 420).offset(x: -170, y: -230)
                        }
                        .clipped()

                    VStack(alignment: .leading, spacing: MYSpacing.lg) {
                        attentionRow
                        quickActions
                        latestCourses
                    }
                    .padding(.horizontal, MYSpacing.screen)
                    .padding(.top, MYSpacing.lg)
                    .frame(maxWidth: .infinity)
                    .background(
                        UnevenRoundedRectangle(topLeadingRadius: Self.sheetRadius,
                                               topTrailingRadius: Self.sheetRadius,
                                               style: .continuous)
                            .fill(MYColor.background)
                    )
                    .padding(.top, -Self.sheetRadius)
                }
            }
            .myTabBarInset()
        }
        .myStatusBarScrim(MYColor.brandSolid)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            #if DEBUG
            guard !demoPushed, let r = DemoLaunch.route else { return }
            demoPushed = true
            if r == "addCourse" { router.push(.addCourse) }
            if r == "publishPost" { router.push(.publishPost) }
            if r == "publishStory" { router.push(.publishStory) }
            if r == "publishAd" { router.push(.publishAd) }
            if r == "courseDetail", let c = store.courses.first { router.push(.courseDetail(c)) }
            if r == "bookingRequests" { router.push(.bookingRequests) }
            if r == "academyInbox" { router.push(.academyInbox) }
            if r == "providerStats" { router.push(.providerStats) }
            if r == "academyInfo" { router.push(.academyInfo) }
            if r == "academyChat", let c = inbox.conversations.first { router.push(.academyChat(c)) }
            #endif
        }
    }

    // MARK: Violet header — identity + compact stats
    private var header: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            HStack(spacing: MYSpacing.md) {
                MYRemoteImage(assetName: store.category.imageName, accent: store.category.accent)
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.white.opacity(0.35), lineWidth: 1.5))
                VStack(alignment: .leading, spacing: 3) {
                    Text(store.academyName)
                        .font(.appFont(17, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill").font(.system(size: 11))
                        Text("باقة \(store.currentPlan.name)")
                            .font(.appFont(12, weight: .semibold))
                    }
                    .foregroundStyle(.white.opacity(0.9))
                }
                Spacer(minLength: 0)
                Button {
                    Haptics.light()
                    router.push(.providerStats)
                } label: {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.14), in: Circle())
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("الإحصائيات")
            }

            HStack(spacing: MYSpacing.xs) {
                stat(MYFormat.integer(store.totalStudents), "طالب")
                stat(MYFormat.rating(store.avgRating), "التقييم")
                stat(MYFormat.price(store.monthlyRevenue), "أرباح الشهر")
            }
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.appFont(18, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.appFont(12))
                .foregroundStyle(.white.opacity(0.88))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, MYSpacing.sm)
        .padding(.vertical, 10)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    // MARK: Needs attention — booking requests + trainee messages
    private var attentionRow: some View {
        HStack(spacing: MYSpacing.sm) {
            attentionCard(icon: "calendar.badge.clock", tint: MYColor.warning,
                          title: "طلبات الحجز", count: 0) {
                router.push(.bookingRequests)
            }
            attentionCard(icon: "bubble.left.and.bubble.right.fill", tint: MYColor.primary,
                          title: "رسائل المتدربين", count: inbox.totalUnread) {
                router.push(.academyInbox)
            }
        }
    }

    private func attentionCard(icon: String, tint: Color, title: String, count: Int,
                               tap: @escaping () -> Void) -> some View {
        Button {
            Haptics.light(); tap()
        } label: {
            VStack(alignment: .leading, spacing: MYSpacing.sm) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(tint)
                        .frame(width: 40, height: 40)
                        .background(tint.opacity(0.12),
                                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    Spacer(minLength: 0)
                    if count > 0 {
                        Text("\(count)")
                            .font(.appFont(13, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(minWidth: 26, minHeight: 26)
                            .background(tint, in: Capsule())
                    }
                }
                Text(title)
                    .font(MYTypography.cardTitle)
                    .foregroundStyle(MYColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .myCard(padding: MYSpacing.md)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(count > 0 ? "\(title)، \(count) جديد" : title)
    }

    // MARK: Quick actions — one compact row
    private var quickActions: some View {
        HStack(spacing: MYSpacing.xs) {
            action("plus", "دورة جديدة") { router.push(.addCourse) }
            action("megaphone", "إعلان مدفوع") { router.push(.publishAd) }
            action("flame", "ستوري") { router.push(.publishStory) }
            action("pencil", "الملف") { router.push(.academyInfo) }
        }
    }

    private func action(_ icon: String, _ title: String, _ tap: @escaping () -> Void) -> some View {
        Button {
            Haptics.light(); tap()
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(MYColor.primary)
                Text(title)
                    .font(.appFont(12, weight: .semibold))
                    .foregroundStyle(MYColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(MYColor.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
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
        .environment(ProviderStore(repo: nil))
        .environment(AcademyInboxStore(repo: nil))
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
