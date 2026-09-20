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

    /// Fires shortly after a booking is confirmed (demo of a local notification).
    func scheduleBookingConfirmed(serviceTitle: String, date: Date, time: String) {
        let content = UNMutableNotificationContent()
        content.title = "تم تأكيد حجزك ✅"
        content.body = "\(serviceTitle) — \(MYFormat.longDate(date)) · \(time)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
