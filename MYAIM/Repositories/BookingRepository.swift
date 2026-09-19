import Foundation

/// Bookings data access.
protocol BookingRepository {
    func upcoming() async throws -> [Booking]
    func past() async throws -> [Booking]
    @discardableResult
    func create(service: Service, date: Date, time: String) async throws -> Booking
}

/// Shared in-memory mock so a booking created in the flow appears in the list.
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
    func create(service: Service, date: Date, time: String) async throws -> Booking {
        try await delay(0.9)
        let booking = Booking(service: service, date: date, time: time, status: .confirmed)
        created.insert(booking, at: 0)
        return booking
    }
}
