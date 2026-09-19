import Foundation

/// Realistic Arabic (Saudi) sample content used by SwiftUI previews now, and by
/// the Mock repositories in later phases. No Lorem Ipsum, no placeholder text.
enum SampleData {

    // MARK: - Locations
    static let riyadh  = MYLocation(city: "الرياض", district: "حي النخيل", latitude: 24.7136, longitude: 46.6753)
    static let jeddah  = MYLocation(city: "جدة", district: "حي الشاطئ", latitude: 21.5433, longitude: 39.1728)
    static let dammam  = MYLocation(city: "الدمام", district: "حي الشاطئ الغربي", latitude: 26.4207, longitude: 50.0888)
    static let khobar  = MYLocation(city: "الخبر", district: "حي العليا", latitude: 26.2794, longitude: 50.2083)

    // MARK: - Providers
    static let providers: [Provider] = [
        Provider(
            name: "أكاديمية النخبة الرياضية",
            tagline: "أكاديمية متخصصة في اللياقة والتدريب",
            about: "أكاديمية رياضية رائدة في الرياض تقدّم برامج لياقة واحترافية بإشراف مدربين معتمدين، لجميع الأعمار والمستويات.",
            category: .sports, isVerified: true, rating: 4.8, reviewsCount: 128,
            location: riyadh, logoURL: nil, coverURL: nil
        ),
        Provider(
            name: "أكاديمية إتقان التعليمية",
            tagline: "دورات تأسيسية ومهارات دراسية",
            about: "نساعد الطلاب على التفوق عبر برامج تعليمية منظّمة ومناهج حديثة ومعلّمين متميزين.",
            category: .education, isVerified: true, rating: 4.7, reviewsCount: 94,
            location: jeddah, logoURL: nil, coverURL: nil
        ),
        Provider(
            name: "منصّة مسار لتطوير الذات",
            tagline: "برامج تدريبية وتطوير مهارات",
            about: "برامج واستشارات في القيادة والإنتاجية وتطوير الذات يقدّمها مدربون معتمدون.",
            category: .selfDevelopment, isVerified: false, rating: 4.9, reviewsCount: 212,
            location: dammam, logoURL: nil, coverURL: nil
        ),
        Provider(
            name: "تِك سوليوشنز",
            tagline: "خدمات وبرامج تقنية للأفراد والشركات",
            about: "نصمّم ونطوّر حلولًا تقنية ونقدّم دورات في البرمجة والتصميم وريادة الأعمال الرقمية.",
            category: .tech, isVerified: true, rating: 4.6, reviewsCount: 76,
            location: khobar, logoURL: nil, coverURL: nil
        )
    ]

    // MARK: - Services
    static let services: [Service] = [
        Service(
            title: "برنامج اللياقة الشامل",
            summary: "برنامج لياقة متكامل لمدة 8 أسابيع مع خطة تغذية ومتابعة أسبوعية.",
            category: .sports, providerName: providers[0].name, providerId: providers[0].id,
            isVerified: true, rating: 4.8, reviewsCount: 128, location: riyadh,
            startingPrice: 450, imageURL: "https://loremflickr.com/600/400/gym,training?lock=21", distanceMeters: 1200
        ),
        Service(
            title: "دورة التأسيس في الرياضيات",
            summary: "دورة مكثّفة لبناء أساس قوي في الرياضيات لطلاب المرحلة الثانوية.",
            category: .education, providerName: providers[1].name, providerId: providers[1].id,
            isVerified: true, rating: 4.7, reviewsCount: 94, location: jeddah,
            startingPrice: 300, imageURL: "https://loremflickr.com/600/400/mathematics,study?lock=22", distanceMeters: 2500
        ),
        Service(
            title: "برنامج القيادة والإنتاجية",
            summary: "ورشة تدريبية لتطوير مهارات القيادة وإدارة الوقت وتحقيق الأهداف.",
            category: .selfDevelopment, providerName: providers[2].name, providerId: providers[2].id,
            isVerified: false, rating: 4.9, reviewsCount: 212, location: dammam,
            startingPrice: 600, imageURL: "https://loremflickr.com/600/400/leadership,seminar?lock=23", distanceMeters: 850
        ),
        Service(
            title: "معسكر تطوير تطبيقات iOS",
            summary: "تعلّم بناء تطبيقات iOS من الصفر باستخدام Swift وSwiftUI خلال 6 أسابيع.",
            category: .tech, providerName: providers[3].name, providerId: providers[3].id,
            isVerified: true, rating: 4.6, reviewsCount: 76, location: khobar,
            startingPrice: 1200, imageURL: "https://loremflickr.com/600/400/coding,developer?lock=24", distanceMeters: 3400
        )
    ]

    // MARK: - Goals
    static let goals: [Goal] = [
        Goal(
            title: "إطلاق مشروعي الإلكتروني",
            category: .tech,
            steps: [
                GoalStep(title: "تحديد الفكرة", isDone: true),
                GoalStep(title: "دراسة السوق", isDone: true),
                GoalStep(title: "إنشاء المتجر", isDone: false),
                GoalStep(title: "إطلاق الحملة", isDone: false)
            ]
        ),
        Goal(
            title: "تحسين لياقتي البدنية",
            category: .sports,
            steps: [
                GoalStep(title: "الاشتراك في أكاديمية", isDone: true),
                GoalStep(title: "وضع خطة تدريب", isDone: true),
                GoalStep(title: "الالتزام 3 أشهر", isDone: true)
            ]
        )
    ]

    // MARK: - Hero carousel slides
    static let heroSlides: [HeroSlide] = [
        .feature(
            title: "ابدأ رحلتك نحو هدفك",
            subtitle: "أفضل الأكاديميات والمدربين في مكان واحد",
            imageURL: "https://loremflickr.com/800/400/training,success?lock=31",
            actionTitle: "اكتشف الآن"
        ),
        .discount(
            code: "AIM20",
            title: "خصم ٢٠٪ على أول حجز",
            subtitle: "استخدم الكود عند تأكيد حجزك الأول"
        ),
        .whyUs(
            title: "ليش MY AIM؟",
            points: [
                WhyUsPoint(icon: "checkmark.seal.fill", text: "أكاديميات ومدربون موثّقون"),
                WhyUsPoint(icon: "bolt.fill", text: "حجز فوري وسهل بخطوات بسيطة"),
                WhyUsPoint(icon: "tag.fill", text: "أسعار واضحة بدون مفاجآت"),
                WhyUsPoint(icon: "target", text: "برامج مصمّمة حسب هدفك")
            ]
        )
    ]

    // MARK: - Notifications
    static let notifications: [AppNotification] = [
        AppNotification(kind: .booking, title: "تم تأكيد حجزك",
                        body: "حجزك في «برنامج اللياقة الشامل» تم تأكيده ليوم الأحد ١٠:٣٠ ص.",
                        date: Date().addingTimeInterval(-3600), isUnread: true),
        AppNotification(kind: .suggestion, title: "اقتراح يناسب هدفك",
                        body: "وجدنا «معسكر تطوير تطبيقات iOS» قد يساعدك في تحقيق هدفك.",
                        date: Date().addingTimeInterval(-3600 * 6), isUnread: true),
        AppNotification(kind: .goal, title: "تقدّم جديد في هدفك",
                        body: "أنجزت خطوة جديدة في «إطلاق مشروعي الإلكتروني». استمر!",
                        date: Date().addingTimeInterval(-86400), isUnread: false),
        AppNotification(kind: .message, title: "رسالة من مقدّم الخدمة",
                        body: "أكاديمية النخبة الرياضية: نتطلع لرؤيتك في أول حصة!",
                        date: Date().addingTimeInterval(-86400 * 2), isUnread: false)
    ]

    // MARK: - Bookings
    static let upcomingBookings: [Booking] = [
        Booking(service: services[0],
                date: Date().addingTimeInterval(86400 * 2),
                time: "10:30 ص", status: .confirmed),
        Booking(service: services[2],
                date: Date().addingTimeInterval(86400 * 5),
                time: "05:00 م", status: .pending)
    ]
    static let pastBookings: [Booking] = [
        Booking(service: services[1],
                date: Date().addingTimeInterval(-86400 * 10),
                time: "12:00 م", status: .completed),
        Booking(service: services[3],
                date: Date().addingTimeInterval(-86400 * 20),
                time: "07:00 م", status: .cancelled)
    ]

    // MARK: - Reviews
    static let reviews: [Review] = [
        Review(authorName: "أحمد العتيبي", rating: 5, comment: "تجربة ممتازة والمدربون محترفون جدًا، أنصح بها.", date: Date().addingTimeInterval(-86400 * 3)),
        Review(authorName: "سارة القحطاني", rating: 4, comment: "برنامج مفيد ومنظّم، النتائج واضحة خلال أسابيع.", date: Date().addingTimeInterval(-86400 * 10)),
        Review(authorName: "خالد الدوسري", rating: 5, comment: "أفضل استثمار لوقتي، شكرًا لكم.", date: Date().addingTimeInterval(-86400 * 21))
    ]
}

// MARK: - Convenience preview singletons

extension Service {
    static let preview = SampleData.services[0]
}
extension Provider {
    static let preview = SampleData.providers[0]
}
extension Goal {
    static let preview = SampleData.goals[0]
}
