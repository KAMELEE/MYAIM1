import SwiftUI
import Observation

/// App-wide store for the provider (academy) interface: courses, posts,
/// subscription and stats. Seeded with sample data; in-memory for now.
@Observable
final class ProviderStore {
    var academyName = "أكاديمية النخبة الرياضية"
    var academyTagline = "أكاديمية متخصصة في اللياقة والتدريب"
    var category: ServiceCategory = .sports

    var courses: [Course]
    var posts: [Post]
    let plans: [SubscriptionPlan]
    var currentPlanID: UUID

    init() {
        courses = [
            Course(title: "برنامج اللياقة الشامل", category: .sports, price: 450,
                   students: 128, rating: 4.8, isPublished: true,
                   summary: "برنامج متكامل ٨ أسابيع مع خطة تغذية ومتابعة أسبوعية."),
            Course(title: "معسكر التحضير البدني", category: .sports, price: 700,
                   students: 64, rating: 4.7, isPublished: true,
                   summary: "تحضير بدني احترافي للاعبين والرياضيين."),
            Course(title: "لياقة المبتدئين", category: .sports, price: 300,
                   students: 42, rating: 4.6, isPublished: false,
                   summary: "بداية آمنة ومتدرّجة لمن يبدأ رحلته الرياضية.")
        ]
        posts = [
            Post(text: "افتتحنا التسجيل في دفعة برنامج اللياقة الشامل الجديدة! الأماكن محدودة.",
                 date: Date().addingTimeInterval(-3600 * 5), likes: 86, comments: 12, imageName: "photo_sports"),
            Post(text: "نصيحة اليوم: الإحماء ٥ دقائق قبل التمرين يقلّل الإصابات ويحسّن الأداء 💪",
                 date: Date().addingTimeInterval(-86400 * 2), likes: 143, comments: 21, imageName: nil)
        ]
        let plansList = [
            SubscriptionPlan(name: "الأساسية", price: 0, period: "مجانًا",
                             features: ["حتى ٣ دورات", "ملف أكاديمية", "استقبال الحجوزات"], isPopular: false),
            SubscriptionPlan(name: "الاحترافية", price: 199, period: "شهريًا",
                             features: ["دورات غير محدودة", "نشر المنشورات", "شارة موثّق", "إحصائيات متقدمة", "أولوية في الظهور"], isPopular: true),
            SubscriptionPlan(name: "الأعمال", price: 499, period: "شهريًا",
                             features: ["كل مزايا الاحترافية", "فروع متعددة", "مدير حساب مخصّص", "تقارير شهرية"], isPopular: false)
        ]
        plans = plansList
        currentPlanID = plansList[0].id   // start on free plan
    }

    var currentPlan: SubscriptionPlan { plans.first { $0.id == currentPlanID } ?? plans[0] }

    // MARK: Stats
    var totalStudents: Int { courses.reduce(0) { $0 + $1.students } }
    var publishedCount: Int { courses.filter(\.isPublished).count }
    var avgRating: Double {
        let r = courses.filter { $0.rating > 0 }
        guard !r.isEmpty else { return 0 }
        return r.reduce(0) { $0 + $1.rating } / Double(r.count)
    }
    var monthlyRevenue: Double { courses.reduce(0) { $0 + $1.price * Double($1.students) } * 0.15 }

    // MARK: Mutations
    func addCourse(_ course: Course) { courses.insert(course, at: 0) }
    func togglePublish(_ course: Course) {
        guard let i = courses.firstIndex(where: { $0.id == course.id }) else { return }
        courses[i].isPublished.toggle()
    }
    func addPost(_ post: Post) { posts.insert(post, at: 0) }
    func selectPlan(_ plan: SubscriptionPlan) { currentPlanID = plan.id }
}
