import Foundation

/// A subscription plan for providers (academies) on MY AIM.
struct SubscriptionPlan: Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var price: Double        // SAR / month
    var period: String       // "شهريًا"
    var features: [String]
    var isPopular: Bool
}
