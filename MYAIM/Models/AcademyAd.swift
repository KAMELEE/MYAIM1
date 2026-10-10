import SwiftUI

/// Paid ad packages an academy can buy (prices in SAR).
enum AdPackage: String, CaseIterable, Identifiable, Codable {
    case week, twoWeeks, month

    var id: String { rawValue }
    var days: Int {
        switch self { case .week: 7; case .twoWeeks: 14; case .month: 30 }
    }
    var price: Double {
        switch self { case .week: 99; case .twoWeeks: 179; case .month: 299 }
    }
    var title: String {
        switch self { case .week: "أسبوع"; case .twoWeeks: "أسبوعان"; case .month: "شهر" }
    }
    /// Short value line shown under the package.
    var note: String {
        switch self {
        case .week: "مناسب للعروض السريعة"
        case .twoWeeks: "الأكثر طلبًا"
        case .month: "أوفر — ظهور طوال الشهر"
        }
    }
}

/// Lifecycle of a paid ad. Payment is a bank transfer / QR (like bookings),
/// so a new ad waits for the admin to confirm the transfer before going live.
enum AdStatus: String, Codable {
    case pendingReview   // بانتظار التحقق من الدفع
    case active          // ظاهر للمتدربين
    case rejected        // رُفض (لم يصل التحويل)

    var title: String {
        switch self {
        case .pendingReview: "بانتظار تأكيد الدفع"
        case .active: "نشط"
        case .rejected: "مرفوض"
        }
    }
}

/// A paid academy advertisement — shown first on the trainees' Home.
struct AcademyAd: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var subtitle: String
    var providerName: String
    var imageAsset: String?
    var accentHex: String
    /// Academy account that bought the ad (nil for seeded demo ads).
    var ownerUid: String? = nil
    var package: AdPackage = .week
    var status: AdStatus = .active
    var paymentMethod: PaymentMethod = .bankTransfer
    /// Transfer reference the academy writes on its bank transfer.
    var reference: String = ""
    var createdAt = Date()
    /// Set when the ad goes live (admin confirms the payment).
    var endsAt: Date? = nil

    var accent: Color { Color(hex: accentHex) }
    var price: Double { package.price }

    /// Expired once its paid period is over.
    var isExpired: Bool { endsAt.map { $0 < Date() } ?? false }
    /// Shown to trainees only while active and within its paid period.
    var isLive: Bool { status == .active && !isExpired }

    var daysLeft: Int? {
        guard let endsAt, !isExpired else { return nil }
        return max(1, Calendar.current.dateComponents([.day], from: Date(), to: endsAt).day ?? 0)
    }

    /// Status label for the academy's ads list.
    var statusTitle: String { isExpired ? "منتهي" : status.title }
}
