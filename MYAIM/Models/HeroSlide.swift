import Foundation

/// A single benefit point on the "ليش MY AIM؟" slide.
struct WhyUsPoint: Identifiable, Hashable {
    var id = UUID()
    let icon: String        // SF Symbol
    let text: String
}

/// A slide in the Home hero carousel.
enum HeroSlide: Identifiable {
    /// Branded intro hero (lavender, headline + accent line + floating icons).
    case brandHero(id: UUID = UUID(), title: String, accent: String, subtitle: String, actionTitle: String)
    /// Featured program/offer with a background photo.
    case feature(id: UUID = UUID(), title: String, subtitle: String, imageURL: String, actionTitle: String)
    /// Promo/discount code with a copy action.
    case discount(id: UUID = UUID(), code: String, title: String, subtitle: String)
    /// Why choose MY AIM — a few benefit points.
    case whyUs(id: UUID = UUID(), title: String, points: [WhyUsPoint])

    var id: UUID {
        switch self {
        case .brandHero(let id, _, _, _, _): return id
        case .feature(let id, _, _, _, _):   return id
        case .discount(let id, _, _, _):     return id
        case .whyUs(let id, _, _):           return id
        }
    }
}
