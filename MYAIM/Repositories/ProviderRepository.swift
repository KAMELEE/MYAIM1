import Foundation

/// Everything the academy (provider) interface persists for one account.
struct ProviderProfile {
    var academyName: String
    var academyTagline: String
    var category: ServiceCategory
    /// Stored by name: plan UUIDs are regenerated on every launch.
    var planName: String
    var courses: [Course]
    var posts: [Post]
}

/// Academy dashboard data access (profile, courses, posts, plan).
///
/// DEMO builds have no repository at all — `ProviderStore` stays in memory.
protocol ProviderRepository {
    /// The signed-in academy's saved data, or nil if nothing is saved yet.
    func load() async throws -> ProviderProfile?
    /// Writes the profile fields (name, tagline, category, plan).
    func saveProfile(_ profile: ProviderProfile) async throws
    func saveCourse(_ course: Course) async throws
    func savePost(_ post: Post) async throws
}
