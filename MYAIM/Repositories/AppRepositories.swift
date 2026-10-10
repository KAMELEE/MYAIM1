import Foundation

/// Composition root: the single place that decides mock vs. real backend.
/// - DEMO builds (CI → Appetize): in-memory mocks, no Firebase required.
/// - Production builds: Firestore-backed repositories (real data).
enum AppRepositories {

    static func services() -> ServiceRepository {
        #if DEMO
        MockServiceRepository()
        #else
        FirestoreServiceRepository()
        #endif
    }

    static func bookings() -> BookingRepository {
        #if DEMO
        MockBookingRepository.shared
        #else
        FirestoreBookingRepository()
        #endif
    }

    static func goals() -> GoalRepository {
        #if DEMO
        MockGoalRepository()
        #else
        FirestoreGoalRepository()
        #endif
    }

    /// Academy dashboard persistence — nil in DEMO (in-memory store).
    static func provider() -> ProviderRepository? {
        #if DEMO
        nil
        #else
        FirestoreProviderRepository()
        #endif
    }

    /// Chat persistence — nil in DEMO (seeded store + simulated replies).
    static func messages() -> MessagesRepository? {
        #if DEMO
        nil
        #else
        FirestoreMessagesRepository()
        #endif
    }

    /// Paid academy ads — nil in DEMO (seeded store, instant activation).
    static func ads() -> AdsRepository? {
        #if DEMO
        nil
        #else
        FirestoreAdsRepository()
        #endif
    }
}
