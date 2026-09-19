import SwiftUI

/// The five root tabs of MY AIM.
enum AppTab: Int, CaseIterable, Identifiable {
    case home
    case discover
    case goals
    case bookings
    case profile

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home:     return "الرئيسية"
        case .discover: return "اكتشف"
        case .goals:    return "أهدافي"
        case .bookings: return "حجوزاتي"
        case .profile:  return "حسابي"
        }
    }

    var icon: String {
        switch self {
        case .home:     return "house"
        case .discover: return "safari"
        case .goals:    return "target"
        case .bookings: return "calendar"
        case .profile:  return "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home:     return "house.fill"
        case .discover: return "safari.fill"
        case .goals:    return "target"
        case .bookings: return "calendar"
        case .profile:  return "person.fill"
        }
    }
}
