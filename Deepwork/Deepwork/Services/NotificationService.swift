import Foundation
import UserNotifications

final class NotificationService {
    private let notificationCenter = UNUserNotificationCenter.current()

    func requestAuthorization() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    func scheduleTimerCompletion(in timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete"
        content.body = "Great work! Your focus session has ended."
        content.sound = .default
        content.categoryIdentifier = "TIMER_COMPLETE"

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(timeInterval, 1),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "timer-completion",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }

    func cancelPendingNotifications() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["timer-completion"])
    }

    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
}
