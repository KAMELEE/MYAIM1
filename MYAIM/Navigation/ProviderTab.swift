import Foundation

/// The five root tabs of the provider (academy) interface.
enum ProviderTab: Int, CaseIterable, Identifiable, TabBarItem {
    case dashboard
    case courses
    case ads
    case subscription
    case account

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .dashboard:    return "لوحتي"
        case .courses:      return "دوراتي"
        case .ads:          return "الإعلانات"
        case .subscription: return "الاشتراك"
        case .account:      return "الأكاديمية"
        }
    }

    var icon: String {
        switch self {
        case .dashboard:    return "chart.bar"
        case .courses:      return "rectangle.stack"
        case .ads:          return "megaphone"
        case .subscription: return "crown"
        case .account:      return "building.2"
        }
    }

    var selectedIcon: String {
        switch self {
        case .dashboard:    return "chart.bar.fill"
        case .courses:      return "rectangle.stack.fill"
        case .ads:          return "megaphone.fill"
        case .subscription: return "crown.fill"
        case .account:      return "building.2.fill"
        }
    }
}
