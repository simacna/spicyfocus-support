import Foundation
import SwiftData

struct DayStats {
    let date: Date
    let totalMinutes: Int
    let sessionCount: Int
    let completedCount: Int
}

struct WeekStats {
    let weekStart: Date
    let weekEnd: Date
    let totalMinutes: Int
    let sessionCount: Int
    let completedCount: Int
    let averageMinutesPerDay: Int
    let dailyStats: [DayStats]

    var completionRate: Double {
        guard sessionCount > 0 else { return 0 }
        return Double(completedCount) / Double(sessionCount)
    }
}

enum StatsService {
    static func calculateWeekStats(sessions: [FocusSession], for date: Date = Date()) -> WeekStats {
        let calendar = Calendar.current

        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return WeekStats(
                weekStart: date,
                weekEnd: date,
                totalMinutes: 0,
                sessionCount: 0,
                completedCount: 0,
                averageMinutesPerDay: 0,
                dailyStats: []
            )
        }

        let weekSessions = sessions.filter { session in
            session.startTime >= weekInterval.start && session.startTime < weekInterval.end
        }

        let totalSeconds = weekSessions.reduce(0) { $0 + $1.actualDuration }
        let totalMinutes = totalSeconds / 60
        let completedCount = weekSessions.filter { $0.wasCompleted }.count

        var dailyStats: [DayStats] = []
        var currentDay = weekInterval.start

        while currentDay < weekInterval.end {
            let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDay) ?? currentDay
            let daySessions = weekSessions.filter { session in
                session.startTime >= currentDay && session.startTime < nextDay
            }

            let dayTotalSeconds = daySessions.reduce(0) { $0 + $1.actualDuration }
            let dayStats = DayStats(
                date: currentDay,
                totalMinutes: dayTotalSeconds / 60,
                sessionCount: daySessions.count,
                completedCount: daySessions.filter { $0.wasCompleted }.count
            )
            dailyStats.append(dayStats)

            currentDay = nextDay
        }

        let daysWithSessions = dailyStats.filter { $0.sessionCount > 0 }.count
        let averageMinutesPerDay = daysWithSessions > 0 ? totalMinutes / daysWithSessions : 0

        return WeekStats(
            weekStart: weekInterval.start,
            weekEnd: weekInterval.end.addingTimeInterval(-1),
            totalMinutes: totalMinutes,
            sessionCount: weekSessions.count,
            completedCount: completedCount,
            averageMinutesPerDay: averageMinutesPerDay,
            dailyStats: dailyStats
        )
    }

    static func calculateDayStats(sessions: [FocusSession], for date: Date = Date()) -> DayStats {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

        let daySessions = sessions.filter { session in
            session.startTime >= startOfDay && session.startTime < endOfDay
        }

        let totalSeconds = daySessions.reduce(0) { $0 + $1.actualDuration }

        return DayStats(
            date: date,
            totalMinutes: totalSeconds / 60,
            sessionCount: daySessions.count,
            completedCount: daySessions.filter { $0.wasCompleted }.count
        )
    }

    static func groupSessionsByDate(_ sessions: [FocusSession]) -> [(date: Date, sessions: [FocusSession])] {
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.startTime)
        }

        return grouped
            .map { (date: $0.key, sessions: $0.value.sorted { $0.startTime > $1.startTime }) }
            .sorted { $0.date > $1.date }
    }
}
