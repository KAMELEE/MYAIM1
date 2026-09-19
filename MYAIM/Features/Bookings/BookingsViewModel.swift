import SwiftUI
import Observation

@MainActor
@Observable
final class BookingsViewModel {
    enum Tab { case upcoming, past }

    private let repo: BookingRepository
    var tab: Tab = .upcoming
    var upcoming: LoadingState<[Booking]> = .idle
    var past: LoadingState<[Booking]> = .idle

    init(repo: BookingRepository = MockBookingRepository.shared) {
        self.repo = repo
    }

    var current: LoadingState<[Booking]> {
        tab == .upcoming ? upcoming : past
    }

    func load() async {
        await loadUpcoming()
        await loadPast()
    }

    func loadUpcoming() async {
        upcoming = .loading
        do {
            let items = try await repo.upcoming()
            upcoming = items.isEmpty ? .empty : .loaded(items)
        } catch {
            upcoming = .failed("تعذر تحميل الحجوزات.")
        }
    }

    func loadPast() async {
        past = .loading
        do {
            let items = try await repo.past()
            past = items.isEmpty ? .empty : .loaded(items)
        } catch {
            past = .failed("تعذر تحميل الحجوزات.")
        }
    }

    func refresh() async {
        await load()
    }
}
