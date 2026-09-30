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

enum PaymentMethod: String, Codable, CaseIterable, Identifiable {
    case bankTransfer   // تحويل بنكي (الراجحي)
    case qr             // دفع عبر QR

    var id: String { rawValue }
    var title: String { self == .bankTransfer ? "تحويل بنكي" : "دفع عبر QR" }
    var icon: String { self == .bankTransfer ? "building.columns" : "qrcode" }
}

/// Bank account the trainee transfers to (edit these to your real account).
enum PaymentInfo {
    static let bankName = "مصرف الراجحي"
    static let accountName = "شركة ماي إيم"
    static let accountNumber = "588608010000000"
    static let iban = "SA00 8000 0000 5886 0801 0000"
    /// Payload encoded in the QR (any string your PSP expects; here a simple ref).
    static func qrPayload(amount: Double, ref: String) -> String {
        "MYAIM|IBAN:\(iban.replacingOccurrences(of: " ", with: ""))|AMOUNT:\(Int(amount))|REF:\(ref)"
    }
}

struct Booking: Identifiable, Hashable {
    var id = UUID()
    let service: Service
    /// Date the request was submitted (scheduling is arranged after approval).
    let date: Date
    var status: BookingStatus
    var paymentMethod: PaymentMethod = .bankTransfer
}

/// Steps the trainee follows to complete a booking request. Shown as guidance.
enum BookingInstructions {
    static let steps: [(icon: String, title: String, detail: String)] = [
        ("creditcard", "اختر طريقة الدفع",
         "تحويل بنكي إلى حساب مصرف الراجحي أو الدفع عبر رمز QR."),
        ("arrow.up.circle", "حوّل المبلغ",
         "حوّل قيمة الخدمة كاملة، وأضف الرقم المرجعي في ملاحظة التحويل."),
        ("paperplane", "أرسل الطلب",
         "بعد إتمام التحويل اضغط «أرسل الطلب» ليصل إلى الأكاديمية."),
        ("checkmark.seal", "تأكيد الحجز",
         "تتحقق الإدارة من التحويل ثم تؤكد الحجز وتتواصل معك لتحديد الموعد.")
    ]
}
