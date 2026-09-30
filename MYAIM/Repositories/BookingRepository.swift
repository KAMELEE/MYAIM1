import Foundation

/// Bookings data access.
protocol BookingRepository {
    func upcoming() async throws -> [Booking]
    func past() async throws -> [Booking]
    /// Creates a booking request (status .pending) after the transfer.
    @discardableResult
    func create(service: Service, payment: PaymentMethod) async throws -> Booking
    /// Admin side: pending requests awaiting approval.
    func pendingRequests() async throws -> [Booking]
    /// Admin approves a request → status becomes .confirmed.
    func approve(_ booking: Booking) async throws
    /// Admin rejects a request → status becomes .cancelled.
    func reject(_ booking: Booking) async throws
}

/// Shared in-memory mock so a created request appears in the list and in the
/// provider's approval queue.
final class MockBookingRepository: BookingRepository {
    static let shared = MockBookingRepository()

    private var created: [Booking] = []

    private func delay(_ seconds: Double = 0.6) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }

    func upcoming() async throws -> [Booking] {
        try await delay()
        return (created + SampleData.upcomingBookings).sorted { $0.date < $1.date }
    }

    func past() async throws -> [Booking] {
        try await delay()
        return SampleData.pastBookings
    }

    @discardableResult
    func create(service: Service, payment: PaymentMethod) async throws -> Booking {
        try await delay(0.9)
        // New requests await admin approval.
        let booking = Booking(service: service, date: Date(),
                              status: .pending, paymentMethod: payment)
        created.insert(booking, at: 0)
        return booking
    }

    func pendingRequests() async throws -> [Booking] {
        try await delay(0.4)
        let mine = created.filter { $0.status == .pending }
        return (mine + SampleData.pendingBookings).sorted { $0.date < $1.date }
    }

    func approve(_ booking: Booking) async throws {
        try await delay(0.4)
        setStatus(.confirmed, for: booking)
    }

    func reject(_ booking: Booking) async throws {
        try await delay(0.4)
        setStatus(.cancelled, for: booking)
    }

    private func setStatus(_ status: BookingStatus, for booking: Booking) {
        if let i = created.firstIndex(where: { $0.id == booking.id }) {
            created[i].status = status
        }
    }
}
