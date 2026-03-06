import Foundation

struct XPLevel {
    let level: Int
    let title: String
    let minXP: Int
    let maxXP: Int

    var xpRequired: Int {
        maxXP - minXP
    }
}

struct XPResult {
    let totalXP: Int
    let level: XPLevel
    let progressInLevel: Double
    let xpInCurrentLevel: Int
}

final class XPService: @unchecked Sendable {

    // MARK: - Level Definitions

    static let levels: [XPLevel] = [
        XPLevel(level: 1, title: "Spark", minXP: 0, maxXP: 100),
        XPLevel(level: 2, title: "Ember", minXP: 100, maxXP: 300),
        XPLevel(level: 3, title: "Flame", minXP: 300, maxXP: 600),
        XPLevel(level: 4, title: "Blaze", minXP: 600, maxXP: 1000),
        XPLevel(level: 5, title: "Inferno", minXP: 1000, maxXP: 1500),
        XPLevel(level: 6, title: "Firestorm", minXP: 1500, maxXP: 2200),
        XPLevel(level: 7, title: "Supernova", minXP: 2200, maxXP: 3000),
        XPLevel(level: 8, title: "Hyperfocus", minXP: 3000, maxXP: 4000),
        XPLevel(level: 9, title: "Deep Flow", minXP: 4000, maxXP: 5500),
        XPLevel(level: 10, title: "Legendary", minXP: 5500, maxXP: 7500),
        XPLevel(level: 11, title: "Transcendent", minXP: 7500, maxXP: 10000),
        XPLevel(level: 12, title: "Neurospicy Master", minXP: 10000, maxXP: 15000)
    ]

    // MARK: - XP Calculation

    /// Calculate XP earned from a single session
    /// - Parameters:
    ///   - durationSeconds: actual focused time in seconds
    ///   - wasCompleted: whether the user completed the full planned duration
    ///   - currentStreak: current daily streak count
    /// - Returns: XP earned
    static func calculateSessionXP(
        durationSeconds: Int,
        wasCompleted: Bool,
        currentStreak: Int
    ) -> Int {
        let minutes = durationSeconds / 60

        // Base XP: 2 XP per minute focused
        var xp = minutes * 2

        // Completion bonus: +25% if session was completed as planned
        if wasCompleted {
            xp += max(minutes / 2, 5)
        }

        // Streak bonus: +10% per streak day (capped at +100%)
        let streakMultiplier = min(Double(currentStreak) * 0.1, 1.0)
        xp += Int(Double(xp) * streakMultiplier)

        return max(xp, 1)
    }

    /// Calculate total XP from all sessions
    static func calculateTotalXP(
        sessions: [FocusSession],
        currentStreak: Int
    ) -> Int {
        sessions.reduce(0) { total, session in
            total + calculateSessionXP(
                durationSeconds: session.actualDuration,
                wasCompleted: session.wasCompleted,
                currentStreak: currentStreak
            )
        }
    }

    /// Get XP result with level info for a given total XP
    static func getXPResult(totalXP: Int) -> XPResult {
        let level = levelFor(xp: totalXP)
        let xpInLevel = totalXP - level.minXP
        let progress = level.xpRequired > 0
            ? min(Double(xpInLevel) / Double(level.xpRequired), 1.0)
            : 1.0

        return XPResult(
            totalXP: totalXP,
            level: level,
            progressInLevel: progress,
            xpInCurrentLevel: xpInLevel
        )
    }

    /// Find the level for a given XP amount
    static func levelFor(xp: Int) -> XPLevel {
        for level in levels.reversed() {
            if xp >= level.minXP {
                return level
            }
        }
        return levels[0]
    }
}
