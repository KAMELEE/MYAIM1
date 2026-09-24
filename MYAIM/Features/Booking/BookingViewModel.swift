import SwiftUI
import Observation

@MainActor
@Observable
final class BookingViewModel {
    let service: Service
    private let repo: BookingRepository

    var step = 0                 // 0: date, 1: time, 2: confirm
    var selectedDate: Date?
    var selectedTime: String?
    var isSubmitting = false
    var didConfirm = false
    var errorMessage: String?

    let days: [Date]
    let times = ["09:00 ص", "10:30 ص", "12:00 م", "02:00 م", "04:00 م", "06:00 م", "08:00 م"]

    init(service: Service, repo: BookingRepository = AppRepositories.bookings()) {
        self.service = service
        self.repo = repo
        let cal = Calendar(identifier: .gregorian)
        self.days = (0..<14).compactMap { cal.date(byAdding: .day, value: $0, to: Date()) }
    }

    var canProceed: Bool {
        switch step {
        case 0: return selectedDate != nil
        case 1: return selectedTime != nil
        default: return true
        }
    }

    var stepTitle: String {
        switch step {
        case 0: return "اختر التاريخ"
        case 1: return "اختر الوقت"
        default: return "تأكيد الحجز"
        }
    }

    func next() {
        guard canProceed else { return }
        Haptics.selection()
        if step < 2 { withAnimation { step += 1 } }
    }

    func back() {
        if step > 0 { withAnimation { step -= 1 } }
    }

    func confirm() async {
        guard let date = selectedDate, let time = selectedTime else { return }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }
        do {
            try await repo.create(service: service, date: date, time: time)
            Haptics.success()
            withAnimation { didConfirm = true }
        } catch {
            errorMessage = "تعذر تأكيد الحجز، حاول مرة أخرى."
            Haptics.error()
        }
    }
}
