import Foundation
import UserNotifications
import Observation

/// Wraps UserNotifications: requests permission and schedules local notifications
/// (e.g. a booking confirmation / reminder).
@MainActor
@Observable
final class NotificationService {
    func request() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// Fires shortly after a booking request is approved (local notification).
    func scheduleBookingConfirmed(serviceTitle: String) {
        let content = UNMutableNotificationContent()
        content.title = "تم تأكيد حجزك"
        content.body = "\(serviceTitle) — سنتواصل معك لتحديد الموعد المناسب."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
