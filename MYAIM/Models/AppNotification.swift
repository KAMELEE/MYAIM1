import SwiftUI

enum NotificationKind {
    case booking, goal, suggestion, message

    var icon: String {
        switch self {
        case .booking:    return "calendar.badge.checkmark"
        case .goal:       return "target"
        case .suggestion: return "sparkles"
        case .message:    return "bubble.left"
        }
    }

    var tint: Color {
        switch self {
        case .booking:    return MYColor.success
        case .goal:       return MYColor.primary
        case .suggestion: return MYColor.warning
        case .message:    return Color(hex: "#2B77E0")
        }
    }
}

/// Named `AppNotification` to avoid clashing with Foundation.Notification.
struct AppNotification: Identifiable, Hashable {
    var id = UUID()
    let kind: NotificationKind
    let title: String
    let body: String
    let date: Date
    var isUnread: Bool

    static func == (lhs: AppNotification, rhs: AppNotification) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
