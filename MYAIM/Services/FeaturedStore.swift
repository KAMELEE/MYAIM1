import SwiftUI
import UIKit

// MARK: - Store

/// Shared, session-scoped store for academy stories and featured ads.
/// Academies publish from their dashboard; trainees see the result on Home.
@MainActor
@Observable
final class FeaturedStore {

    /// Story bubbles on Home (seeded + anything the academy publishes).
    private(set) var stories: [AcademyStory] = SampleData.academyStories

    /// Paid ads. Trainees see `liveAds` first on Home; the academy sees
    /// its own purchases (any status) in `myAds`.
    private(set) var ads: [AcademyAd] = FeaturedStore.seedAds
    private(set) var myAds: [AcademyAd] = []

    private let repo: AdsRepository?

    init(repo: AdsRepository? = AppRepositories.ads()) {
        self.repo = repo
        if repo != nil {
            ads = []
            Task { await reload() }
        } else {
            // DEMO academy (أكاديمية النخبة الرياضية): one live ad + one awaiting payment.
            myAds = Self.seedAds.filter { $0.providerName == "أكاديمية النخبة الرياضية" } + [
                AcademyAd(title: "تسجيل دفعة رمضان", subtitle: "برنامج لياقة مسائي ٤ أسابيع",
                          providerName: "أكاديمية النخبة الرياضية",
                          imageAsset: "photo_sports", accentHex: "#E0533D",
                          package: .twoWeeks, status: .pendingReview, reference: "AD-4821",
                          createdAt: Date().addingTimeInterval(-3600 * 5))
            ]
        }
    }

    /// DEMO: ads go live immediately (payment confirmation is simulated).
    var activatesInstantly: Bool { repo == nil }

    /// Ads currently shown to trainees (active, not expired), newest first.
    var liveAds: [AcademyAd] { ads.filter(\.isLive) }

    /// Re-fetches live ads and the signed-in academy's own ads.
    func reload() async {
        guard let repo else { return }
        if let live = try? await repo.liveAds() { ads = live }
        if let mine = try? await repo.myAds() { myAds = mine }
    }

    private static let seedAds: [AcademyAd] = [
        AcademyAd(title: "خصم ٣٠٪ على الاشتراك الشهري",
                  subtitle: "برامج لياقة صباحية ومسائية بإشراف مدربين معتمدين",
                  providerName: "أكاديمية النخبة الرياضية",
                  imageAsset: "photo_sports", accentHex: "#E0533D",
                  package: .month, endsAt: Date().addingTimeInterval(86400 * 21)),
        AcademyAd(title: "حصة تجريبية مجانية",
                  subtitle: "دورات تأسيس الرياضيات لجميع المراحل — سجل اليوم",
                  providerName: "أكاديمية إتقان التعليمية",
                  imageAsset: "photo_education", accentHex: "#2B77E0",
                  package: .twoWeeks, endsAt: Date().addingTimeInterval(86400 * 9)),
        AcademyAd(title: "ورشة القيادة والإنتاجية",
                  subtitle: "محاضرة مباشرة هذا الخميس — مقاعد محدودة",
                  providerName: "منصّة مسار لتطوير الذات",
                  imageAsset: "photo_selfdev", accentHex: "#7A5AF8",
                  package: .week, endsAt: Date().addingTimeInterval(86400 * 4))
    ]

    // MARK: Publishing (provider side)

    /// Publishes a new story from the academy dashboard. It appears on top
    /// of the trainees' stories row.
    func publishStory(providerName: String, imageAsset: String?, accent: Color,
                       caption: String) {
        let page = AcademyStory.StoryPage(imageAsset: imageAsset, caption: caption)
        if let i = stories.firstIndex(where: { $0.providerName == providerName }) {
            stories[i].pages.append(page)
            stories.swapAt(i, 0)
        } else {
            stories.insert(
                AcademyStory(providerName: providerName, avatarAsset: imageAsset,
                             accent: accent, pages: [page]),
                at: 0
            )
        }
    }

    /// Buys a paid ad from the academy dashboard.
    /// - DEMO: payment confirmation is simulated, so it goes live at once and
    ///   appears first on the trainees' Home.
    /// - Production: saved as «بانتظار تأكيد الدفع» until the admin confirms
    ///   the bank transfer and activates it.
    func publishAd(title: String, subtitle: String, providerName: String,
                   imageAsset: String?, accent: Color, package: AdPackage,
                   paymentMethod: PaymentMethod, reference: String) {
        let hex = String(format: "#%02lX%02lX%02lX",
                         lround(accent.toRGBComponents().r * 255),
                         lround(accent.toRGBComponents().g * 255),
                         lround(accent.toRGBComponents().b * 255))
        var ad = AcademyAd(title: title, subtitle: subtitle,
                           providerName: providerName,
                           imageAsset: imageAsset, accentHex: hex,
                           package: package,
                           status: repo == nil ? .active : .pendingReview,
                           paymentMethod: paymentMethod, reference: reference)
        if repo == nil {
            ad.endsAt = Calendar.current.date(byAdding: .day, value: package.days, to: Date())
            ads.insert(ad, at: 0)
        }
        myAds.insert(ad, at: 0)
        guard let repo else { return }
        Task { try? await repo.create(ad) }
    }
}

private extension Color {
    struct RGB { var r, g, b: Double }
    func toRGBComponents() -> RGB {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        return RGB(r: Double(r), g: Double(g), b: Double(b))
    }
}
