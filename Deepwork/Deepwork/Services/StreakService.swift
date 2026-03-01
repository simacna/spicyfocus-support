import Foundation
import SwiftData

struct DayProgress: Identifiable {
    let id = UUID()
    let date: Date
    let minutesFocused: Int
    let goalMinutes: Int
    let sessionCount: Int

    var goalMet: Bool {
        minutesFocused >= goalMinutes
    }

    var progressPercentage: Double {
        guard goalMinutes > 0 else { return 0 }
        return min(Double(minutesFocused) / Double(goalMinutes), 1.0)
    }
}

struct StreakInfo {
    let currentStreak: Int
    let longestStreak: Int
    let todayProgress: DayProgress
    let streakFreezeAvailable: Bool
    let streakFreezeUsedToday: Bool
}

struct PersonalRecords {
    let longestSession: Int // minutes
    let mostProductiveDay: Int // minutes
    let longestStreak: Int // days
    let totalFocusTime: Int // minutes
    let totalSessions: Int
}

// Non-MainActor service for background calculations
final class StreakService: @unchecked Sendable {
    private let calendar = Calendar.current

    init() {}

    // Static helper for calculating day progress (thread-safe, no state mutation)
    func calculateDayProgress(for date: Date, sessions: [FocusSession], goalMinutes: Int) -> DayProgress {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

        let daySessions = sessions.filter { session in
            session.startTime >= startOfDay && session.startTime < endOfDay
        }

        let totalSeconds = daySessions.reduce(0) { $0 + $1.actualDuration }

        return DayProgress(
            date: date,
            minutesFocused: totalSeconds / 60,
            goalMinutes: goalMinutes,
            sessionCount: daySessions.count
        )
    }

    func calculateStreakInfo(sessions: [FocusSession], goalMinutes: Int) -> StreakInfo {
        let today = calendar.startOfDay(for: Date())
        let todayProgress = calculateDayProgress(for: today, sessions: sessions, goalMinutes: goalMinutes)

        // Calculate streaks from session data
        let (currentStreak, longestStreak) = calculateStreaks(sessions: sessions, goalMinutes: goalMinutes)

        return StreakInfo(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            todayProgress: todayProgress,
            streakFreezeAvailable: false,
            streakFreezeUsedToday: false
        )
    }

    private func calculateStreaks(sessions: [FocusSession], goalMinutes: Int) -> (current: Int, longest: Int) {
        guard !sessions.isEmpty else { return (0, 0) }

        // Group sessions by day and calculate minutes per day
        let sessionsByDay = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.startTime)
        }

        let minutesByDay = sessionsByDay.mapValues { daySessions in
            daySessions.reduce(0) { $0 + $1.actualDuration } / 60
        }

        // Sort days
        let sortedDays = minutesByDay.keys.sorted(by: >)
        guard !sortedDays.isEmpty else { return (0, 0) }

        // Calculate current streak (consecutive days from today)
        var currentStreak = 0
        let today = calendar.startOfDay(for: Date())
        var checkDate = today

        while true {
            if let minutes = minutesByDay[checkDate], minutes >= goalMinutes {
                currentStreak += 1
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

        // Calculate longest streak
        var longestStreak = 0
        var tempStreak = 0
        var lastGoalMetDate: Date?

        for day in sortedDays.reversed() {
            if let minutes = minutesByDay[day], minutes >= goalMinutes {
                if let lastDate = lastGoalMetDate {
                    let daysBetween = calendar.dateComponents([.day], from: lastDate, to: day).day ?? 0
                    if daysBetween == 1 {
                        tempStreak += 1
                    } else {
                        tempStreak = 1
                    }
                } else {
                    tempStreak = 1
                }
                lastGoalMetDate = day
                longestStreak = max(longestStreak, tempStreak)
            }
        }

        return (currentStreak, longestStreak)
    }

    func getWeekProgress(sessions: [FocusSession], goalMinutes: Int, weeksBack: Int = 0) -> [DayProgress] {
        let today = calendar.startOfDay(for: Date())
        guard let weekStart = calendar.date(byAdding: .day, value: -weeksBack * 7, to: today),
              let adjustedWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekStart)) else {
            return []
        }

        var progress: [DayProgress] = []
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: adjustedWeekStart) else { continue }
            progress.append(calculateDayProgress(for: date, sessions: sessions, goalMinutes: goalMinutes))
        }

        return progress
    }

    func getMonthProgress(sessions: [FocusSession], goalMinutes: Int, for date: Date = Date()) -> [DayProgress] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return [] }

        var progress: [DayProgress] = []
        var currentDate = monthInterval.start

        while currentDate < monthInterval.end {
            progress.append(calculateDayProgress(for: currentDate, sessions: sessions, goalMinutes: goalMinutes))
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return progress
    }

    func calculatePersonalRecords(sessions: [FocusSession]) -> PersonalRecords {
        guard !sessions.isEmpty else {
            return PersonalRecords(
                longestSession: 0,
                mostProductiveDay: 0,
                longestStreak: 0,
                totalFocusTime: 0,
                totalSessions: 0
            )
        }

        let longestSession = sessions.max(by: { $0.actualDuration < $1.actualDuration })?.actualDuration ?? 0

        let sessionsByDay = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.startTime)
        }
        let mostProductiveDay = sessionsByDay.values.map { daySessions in
            daySessions.reduce(0) { $0 + $1.actualDuration }
        }.max() ?? 0

        let totalFocusTime = sessions.reduce(0) { $0 + $1.actualDuration }

        // Calculate longest streak for records
        let (_, longestStreak) = calculateStreaks(sessions: sessions, goalMinutes: 60) // Use 60 min as default for records

        return PersonalRecords(
            longestSession: longestSession / 60,
            mostProductiveDay: mostProductiveDay / 60,
            longestStreak: longestStreak,
            totalFocusTime: totalFocusTime / 60,
            totalSessions: sessions.count
        )
    }
}
