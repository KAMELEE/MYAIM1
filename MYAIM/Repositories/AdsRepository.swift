import Foundation

/// Paid academy ads.
///
/// DEMO builds have no repository — `FeaturedStore` stays seeded/in-memory
/// and a new ad goes live immediately (simulated payment confirmation).
protocol AdsRepository {
    /// Ads trainees should see: status active and still within their period.
    func liveAds() async throws -> [AcademyAd]
    /// Every ad the signed-in academy has bought (any status).
    func myAds() async throws -> [AcademyAd]
    /// Saves a newly bought ad (status pendingReview until payment is confirmed).
    func create(_ ad: AcademyAd) async throws
}
