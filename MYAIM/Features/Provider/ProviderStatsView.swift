import SwiftUI
import Charts

/// Academy analytics: key metrics + per-course breakdowns (students, revenue).
struct ProviderStatsView: View {
    @Environment(ProviderStore.self) private var store

    private let cols = [GridItem(.flexible(), spacing: MYSpacing.md),
                        GridItem(.flexible(), spacing: MYSpacing.md)]

    /// Top courses by students, for the charts (keeps bars readable).
    private var topCourses: [Course] {
        store.courses.sorted { $0.students > $1.students }.prefix(6).map { $0 }
    }

    private func revenue(_ c: Course) -> Double { c.price * Double(c.students) * 0.15 }

    var body: some View {
        Group {
            if store.courses.isEmpty {
                MYEmptyState(icon: "chart.bar",
                             title: "لا توجد بيانات بعد",
                             message: "أضف دوراتك وابدأ باستقبال الطلاب لتظهر إحصائياتك هنا.")
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: MYSpacing.lg) {
                        summaryGrid
                        studentsChart
                        revenueChart
                        statusBreakdown
                    }
                    .padding(MYSpacing.screen)
                }
            }
        }
        .myTabBarInset()
        .myScreenBackground()
        .navigationTitle("الإحصائيات")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Summary
    private var summaryGrid: some View {
        LazyVGrid(columns: cols, spacing: MYSpacing.md) {
            metric("person.2.fill", MYFormat.integer(store.totalStudents), "إجمالي الطلاب", MYColor.primary)
            metric("book.fill", "\(store.publishedCount)", "دورات منشورة", Color(hex: "#2B77E0"))
            metric("star.fill", MYFormat.rating(store.avgRating), "متوسط التقييم", MYColor.star)
            metric("banknote.fill", MYFormat.price(store.monthlyRevenue), "أرباح الشهر", MYColor.success)
        }
    }

    private func metric(_ icon: String, _ value: String, _ label: String, _ tint: Color) -> some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 18)).foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: MYRadius.sm, style: .continuous))
            Text(value).font(MYTypography.section).foregroundStyle(MYColor.textPrimary)
            Text(label).font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .myCard(padding: MYSpacing.md)
    }

    // MARK: Students per course
    private var studentsChart: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            MYSectionHeader(title: "الطلاب حسب الدورة", actionTitle: nil)
            Chart(topCourses) { course in
                BarMark(
                    x: .value("الطلاب", course.students),
                    y: .value("الدورة", shortTitle(course.title))
                )
                .foregroundStyle(MYColor.primary)
                .cornerRadius(MYRadius.xs)
                .annotation(position: .trailing) {
                    Text(MYFormat.integer(course.students))
                        .font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
                }
            }
            .chartXAxis(.hidden)
            .frame(height: CGFloat(topCourses.count) * 46 + 20)
        }
        .myCard()
    }

    // MARK: Revenue per course
    private var revenueChart: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            MYSectionHeader(title: "الإيراد حسب الدورة", actionTitle: nil)
            Chart(topCourses) { course in
                BarMark(
                    x: .value("الإيراد", revenue(course)),
                    y: .value("الدورة", shortTitle(course.title))
                )
                .foregroundStyle(MYColor.success)
                .cornerRadius(MYRadius.xs)
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(MYFormat.price(v)).font(MYTypography.caption)
                        }
                    }
                }
            }
            .frame(height: CGFloat(topCourses.count) * 46 + 40)
        }
        .myCard()
    }

    // MARK: Published vs draft
    private var statusBreakdown: some View {
        let published = store.publishedCount
        let drafts = max(store.courses.count - published, 0)
        return VStack(alignment: .leading, spacing: MYSpacing.md) {
            MYSectionHeader(title: "حالة الدورات", actionTitle: nil)
            HStack(spacing: MYSpacing.md) {
                statusPill("منشورة", published, MYColor.success)
                statusPill("مسودة", drafts, MYColor.textTertiary)
            }
        }
        .myCard()
    }

    private func statusPill(_ label: String, _ count: Int, _ tint: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)").font(MYTypography.pageTitle).foregroundStyle(tint)
            Text(label).font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MYSpacing.md)
        .background(tint.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
    }

    private func shortTitle(_ t: String) -> String {
        t.count > 18 ? String(t.prefix(18)) + "…" : t
    }
}

#Preview {
    NavigationStack { ProviderStatsView() }
        .environment(ProviderStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
