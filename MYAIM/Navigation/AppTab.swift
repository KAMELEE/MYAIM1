import SwiftUI

/// The five root tabs of MY AIM (trainee interface).
enum AppTab: Int, CaseIterable, Identifiable, TabBarItem {
    case home
    case discover
    case bookings
    case messages
    case profile

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home:     return "الرئيسية"
        case .discover: return "اكتشف"
        case .bookings: return "حجوزاتي"
        case .messages: return "الرسائل"
        case .profile:  return "حسابي"
        }
    }

    var icon: String {
        switch self {
        case .home:     return "house"
        case .discover: return "magnifyingglass"
        case .bookings: return "ticket"
        case .messages: return "bubble.left.and.bubble.right"
        case .profile:  return "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home:     return "house.fill"
        case .discover: return "magnifyingglass"
        case .bookings: return "ticket.fill"
        case .messages: return "bubble.left.and.bubble.right.fill"
        case .profile:  return "person.fill"
        }
    }
}
