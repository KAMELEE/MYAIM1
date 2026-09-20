import Foundation

/// The five root tabs of the provider (academy) interface.
enum ProviderTab: Int, CaseIterable, Identifiable, TabBarItem {
    case dashboard
    case courses
    case posts
    case subscription
    case account

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .dashboard:    return "لوحتي"
        case .courses:      return "دوراتي"
        case .posts:        return "المنشورات"
        case .subscription: return "الاشتراك"
        case .account:      return "الأكاديمية"
        }
    }

    var icon: String {
        switch self {
        case .dashboard:    return "square.grid.2x2"
        case .courses:      return "book"
        case .posts:        return "megaphone"
        case .subscription: return "creditcard"
        case .account:      return "building.2"
        }
    }

    var selectedIcon: String {
        switch self {
        case .dashboard:    return "square.grid.2x2.fill"
        case .courses:      return "book.fill"
        case .posts:        return "megaphone.fill"
        case .subscription: return "creditcard.fill"
        case .account:      return "building.2.fill"
        }
    }
}
