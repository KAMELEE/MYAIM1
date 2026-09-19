import SwiftUI

enum BookingStatus: String, Codable {
    case confirmed   // مؤكد
    case pending     // بانتظار التأكيد
    case completed   // مكتمل
    case cancelled   // ملغي

    var title: String {
        switch self {
        case .confirmed: return "مؤكد"
        case .pending:   return "بانتظار التأكيد"
        case .completed: return "مكتمل"
        case .cancelled: return "ملغي"
        }
    }

    var tagStyle: MYTagStyle {
        switch self {
        case .confirmed: return .success
        case .pending:   return .warning
        case .completed: return .brand
        case .cancelled: return .error
        }
    }
}

struct Booking: Identifiable, Hashable {
    var id = UUID()
    let service: Service
    let date: Date
    let time: String
    var status: BookingStatus
}
