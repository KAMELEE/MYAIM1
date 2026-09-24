import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Firestore-backed bookings, scoped to the signed-in user.
/// A booking document embeds a snapshot of the service at booking time, so
/// the list renders without joins and survives later catalog edits.
final class FirestoreBookingRepository: BookingRepository {

    private let db = Firestore.firestore()
    private static let collection = "bookings"

    private var userId: String? { Auth.auth().currentUser?.uid }

    private func requireUser() throws -> String {
        guard let userId else { throw RepositoryError.unknown("يجب تسجيل الدخول أولاً.") }
        return userId
    }

    private func fetchAll() async throws -> [Booking] {
        guard let uid = try? requireUser() else { return [] }
        let snap = try await db.collection(Self.collection)
            .whereField("userId", isEqualTo: uid)
            .getDocuments()
        // Sorted client-side: avoids a composite-index requirement in Firestore.
        return snap.documents
            .compactMap { FirestoreMappers.booking(from: $0.data(), id: $0.documentID) }
            .sorted { $0.date < $1.date }
    }

    func upcoming() async throws -> [Booking] {
        let all = try await fetchAll()
        return all.filter { $0.date >= Date() && $0.status != .cancelled }
    }

    func past() async throws -> [Booking] {
        let all = try await fetchAll()
        return all.filter { $0.date < Date() || $0.status == .cancelled }
    }

    @discardableResult
    func create(service: Service, date: Date, time: String) async throws -> Booking {
        let uid = try requireUser()
        let booking = Booking(service: service, date: date, time: time, status: .confirmed)
        try await db.collection(Self.collection)
            .document(booking.id.uuidString)
            .setData(FirestoreMappers.bookingData(userId: uid, service: service,
                                                  date: date, time: time, status: .confirmed))
        return booking
    }
}
