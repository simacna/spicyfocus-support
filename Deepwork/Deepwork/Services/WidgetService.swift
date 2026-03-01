import Foundation
import WidgetKit

final class WidgetService {
    static let shared = WidgetService()

    private let appGroupID = "group.com.spicyfocus.app"
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    private init() {}

    /// Updates widget data based on current sessions and settings
    func updateWidgetData(sessions: [FocusSession], goalMinutes: Int) {
        guard let defaults = sharedDefaults else {
            // Fallback to standard defaults if App Group not configured
            updateStandardDefaults(sessions: sessions, goalMinutes: goalMinutes)
            return
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Calculate current streak
        let currentStreak = calculateCurrentStreak(sessions: sessions, goalMinutes: goalMinutes)

        // Calculate today's minutes
        let todaySessions = sessions.filter {
            calendar.isDate($0.startTime, inSameDayAs: today)
        }
        let todayMinutes = todaySessions.reduce(0) { $0 + $1.actualDuration } / 60

        // Calculate weekly minutes (Sun-Sat)
        var weeklyMinutes = [Int](repeating: 0, count: 7)
        for i in 0..<7 {
            if let dayDate = calendar.date(byAdding: .day, value: -((calendar.component(.weekday, from: today) - 1) + (6 - i)), to: today) {
                let daySessions = sessions.filter {
                    calendar.isDate($0.startTime, inSameDayAs: dayDate)
                }
                weeklyMinutes[i] = daySessions.reduce(0) { $0 + $1.actualDuration } / 60
            }
        }

        // Save to shared defaults
        defaults.set(currentStreak, forKey: "widget.currentStreak")
        defaults.set(todayMinutes, forKey: "widget.todayMinutes")
        defaults.set(goalMinutes, forKey: "widget.goalMinutes")
        defaults.set(weeklyMinutes, forKey: "widget.weeklyMinutes")

        // Reload widgets
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func updateStandardDefaults(sessions: [FocusSession], goalMinutes: Int) {
        let defaults = UserDefaults.standard
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let currentStreak = calculateCurrentStreak(sessions: sessions, goalMinutes: goalMinutes)
        let todaySessions = sessions.filter {
            calendar.isDate($0.startTime, inSameDayAs: today)
        }
        let todayMinutes = todaySessions.reduce(0) { $0 + $1.actualDuration } / 60

        var weeklyMinutes = [Int](repeating: 0, count: 7)
        for i in 0..<7 {
            if let dayDate = calendar.date(byAdding: .day, value: -((calendar.component(.weekday, from: today) - 1) + (6 - i)), to: today) {
                let daySessions = sessions.filter {
                    calendar.isDate($0.startTime, inSameDayAs: dayDate)
                }
                weeklyMinutes[i] = daySessions.reduce(0) { $0 + $1.actualDuration } / 60
            }
        }

        defaults.set(currentStreak, forKey: "widget.currentStreak")
        defaults.set(todayMinutes, forKey: "widget.todayMinutes")
        defaults.set(goalMinutes, forKey: "widget.goalMinutes")
        defaults.set(weeklyMinutes, forKey: "widget.weeklyMinutes")
    }

    private func calculateCurrentStreak(sessions: [FocusSession], goalMinutes: Int) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Group sessions by day
        let sessionsByDay = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.startTime)
        }

        // Calculate minutes per day
        let minutesByDay = sessionsByDay.mapValues { daySessions in
            daySessions.reduce(0) { $0 + $1.actualDuration } / 60
        }

        // Count streak from today backwards
        var streak = 0
        var checkDate = today

        while true {
            if let minutes = minutesByDay[checkDate], minutes >= goalMinutes {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = previousDay
            } else if calendar.isDate(checkDate, inSameDayAs: today) {
                // Today not yet complete, check yesterday
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = previousDay
            } else {
                break
            }
        }

        return streak
    }
}
