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

    // MARK: - Daily Reminders

    private static let reminderNudges = [
        "Your brain is ready for a focus sprint. Let's go!",
        "Time to channel that hyperfocus energy into something great.",
        "Even 10 minutes of deep work can shift your whole day.",
        "Your focus streak is waiting. Don't leave it hanging!",
        "Small wins add up. Start a quick session?",
        "Your brain works differently — and that's your superpower. Time to use it.",
        "A little structure goes a long way. Ready for a focus session?",
        "Dopamine from completing a focus session > dopamine from scrolling."
    ]

    func scheduleDailyReminder(at time: Date) {
        cancelDailyReminder()

        let content = UNMutableNotificationContent()
        content.title = "Time to Focus"
        content.body = Self.reminderNudges.randomElement() ?? "Ready for a focus session?"
        content.sound = .default
        content.categoryIdentifier = "DAILY_REMINDER"

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "daily-reminder",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }

    func cancelDailyReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])
    }
}
