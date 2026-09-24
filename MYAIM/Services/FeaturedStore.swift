import SwiftUI
import UIKit

// MARK: - Ad model

/// A featured-academy advertisement shown to trainees in the Home feed
/// under "أكاديميات مميزة".
struct AcademyAd: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let providerName: String
    let imageAsset: String?
    var accentHex: String

    var accent: Color { Color(hex: accentHex) }
}

// MARK: - Store

/// Shared, session-scoped store for academy stories and featured ads.
/// Academies publish from their dashboard; trainees see the result on Home.
@Observable
final class FeaturedStore {

    /// Story bubbles on Home (seeded + anything the academy publishes).
    private(set) var stories: [AcademyStory] = SampleData.academyStories

    /// Featured ads shown in "أكاديميات مميزة" (seeded + published).
    private(set) var ads: [AcademyAd] = [
        AcademyAd(title: "خصم ٣٠٪ على الاشتراك الشهري",
                   subtitle: "برامج لياقة صباحية ومسائية بإشراف مدربين معتمدين",
                   providerName: "أكاديمية النخبة الرياضية",
                   imageAsset: "photo_sports", accentHex: "#E0533D"),
        AcademyAd(title: "حصة تجريبية مجانية",
                   subtitle: "دورات تأسيس الرياضيات لجميع المراحل — سجل اليوم",
                   providerName: "أكاديمية إتقان التعليمية",
                   imageAsset: "photo_education", accentHex: "#2B77E0"),
        AcademyAd(title: "ورشة القيادة والإنتاجية",
                   subtitle: "محاضرة مباشرة هذا الخميس — مقاعد محدودة",
                   providerName: "منصّة مسار لتطوير الذات",
                   imageAsset: "photo_selfdev", accentHex: "#7A5AF8")
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

    /// Publishes a featured ad from the academy dashboard.
    func publishAd(title: String, subtitle: String, providerName: String,
                   imageAsset: String?, accent: Color) {
        let hex = String(format: "#%02lX%02lX%02lX",
                         lround(accent.toRGBComponents().r * 255),
                         lround(accent.toRGBComponents().g * 255),
                         lround(accent.toRGBComponents().b * 255))
        ads.insert(AcademyAd(title: title, subtitle: subtitle,
                            providerName: providerName,
                            imageAsset: imageAsset, accentHex: hex),
                   at: 0)
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
