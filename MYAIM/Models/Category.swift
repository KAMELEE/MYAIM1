import SwiftUI

/// The fixed top-level categories of MY AIM.
enum ServiceCategory: String, CaseIterable, Identifiable, Codable {
    case selfDevelopment   // تطوير الذات
    case sports            // أكاديميات رياضية
    case education         // أكاديميات تعليمية
    case tech              // تقنية

    var id: String { rawValue }

    var title: String {
        switch self {
        case .selfDevelopment: return "تطوير الذات"
        case .sports:          return "أكاديميات رياضية"
        case .education:       return "أكاديميات تعليمية"
        case .tech:            return "تقنية"
        }
    }

    /// SF Symbol used as a lightweight, non-decorative icon.
    var icon: String {
        switch self {
        case .selfDevelopment: return "figure.mind.and.body"
        case .sports:          return "figure.run"
        case .education:       return "book"
        case .tech:            return "laptopcomputer"
        }
    }

    /// A calm accent used behind the category (kept muted, never neon).
    var accent: Color {
        switch self {
        case .selfDevelopment: return Color(hex: "#5B3FBF")
        case .sports:          return Color(hex: "#2E9E5B")
        case .education:       return Color(hex: "#2B77E0")
        case .tech:            return Color(hex: "#E0932B")
        }
    }

    /// Bundled cover image (real photo shipped in the asset catalog).
    var imageName: String {
        switch self {
        case .selfDevelopment: return "photo_selfdev"
        case .sports:          return "photo_sports"
        case .education:       return "photo_education"
        case .tech:            return "photo_tech"
        }
    }
}

/// A selectable filter chip value on Discover (includes "الكل").
enum CategoryFilter: Hashable, Identifiable {
    case all
    case category(ServiceCategory)

    var id: String {
        switch self {
        case .all: return "all"
        case .category(let c): return c.rawValue
        }
    }

    var title: String {
        switch self {
        case .all: return "الكل"
        case .category(let c): return c.title
        }
    }

    static var allCases: [CategoryFilter] {
        [.all] + ServiceCategory.allCases.map { .category($0) }
    }
}
