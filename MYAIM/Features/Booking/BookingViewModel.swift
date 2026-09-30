import SwiftUI
import Observation

@MainActor
@Observable
final class BookingViewModel {
    let service: Service
    private let repo: BookingRepository

    var step = 0                 // 0: review + instructions, 1: payment
    var paymentMethod: PaymentMethod = .bankTransfer
    var isSubmitting = false
    var didConfirm = false
    var errorMessage: String?

    static let lastStep = 1

    /// Short reference shown to the trainee and embedded in the QR/transfer note.
    let reference = "MA-" + String(Int.random(in: 100000...999999))

    init(service: Service, repo: BookingRepository = AppRepositories.bookings()) {
        self.service = service
        self.repo = repo
        #if DEBUG
        if let s = DemoLaunch.bookingStep {
            step = min(max(s, 0), Self.lastStep)
        }
        #endif
    }

    var stepTitle: String {
        step == 0 ? "مراجعة الطلب" : "الدفع وتأكيد التحويل"
    }

    func next() {
        Haptics.selection()
        if step < Self.lastStep { withAnimation { step += 1 } }
    }

    func back() {
        if step > 0 { withAnimation { step -= 1 } }
    }

    /// Called after the trainee confirms the transfer → creates a PENDING request
    /// awaiting the provider/admin's approval.
    func submitRequest() async {
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }
        do {
            try await repo.create(service: service, payment: paymentMethod)
            Haptics.success()
            withAnimation { didConfirm = true }
        } catch {
            errorMessage = "تعذر إرسال الطلب، حاول مرة أخرى."
            Haptics.error()
        }
    }
}
