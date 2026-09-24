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
}
