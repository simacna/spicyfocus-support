import Foundation
import SwiftUI

final class UserSettings: ObservableObject {
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let defaultDuration = "defaultDuration"
        static let customDurations = "customDurations"
        static let quickLabels = "quickLabels"
        static let soundEnabled = "soundEnabled"
        static let hapticEnabled = "hapticEnabled"
        static let notificationsEnabled = "notificationsEnabled"
        static let prefersDarkMode = "prefersDarkMode"
        static let timerEndTime = "timerEndTime"
        static let timerPlannedDuration = "timerPlannedDuration"
        // Goals
        static let dailyGoalMinutes = "dailyGoalMinutes"
        static let goalsEnabled = "goalsEnabled"
        // Pomodoro
        static let pomodoroEnabled = "pomodoroEnabled"
        static let pomodoroWorkMinutes = "pomodoroWorkMinutes"
        static let pomodoroShortBreakMinutes = "pomodoroShortBreakMinutes"
        static let pomodoroLongBreakMinutes = "pomodoroLongBreakMinutes"
        static let pomodoroSessionsBeforeLongBreak = "pomodoroSessionsBeforeLongBreak"
        static let pomodoroAutoStartBreaks = "pomodoroAutoStartBreaks"
        // Pro
        static let isProUser = "isProUser"
        // Onboarding & Upsell
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let completedSessionCount = "completedSessionCount"
        static let hasSeenProUpsell = "hasSeenProUpsell"
        // Trial
        static let firstLaunchDate = "firstLaunchDate"
    }

    @Published var defaultDuration: Int {
        didSet { defaults.set(defaultDuration, forKey: Keys.defaultDuration) }
    }

    @Published var customDurations: [Int] {
        didSet { defaults.set(customDurations, forKey: Keys.customDurations) }
    }

    @Published var quickLabels: [String] {
        didSet { defaults.set(quickLabels, forKey: Keys.quickLabels) }
    }

    @Published var soundEnabled: Bool {
        didSet { defaults.set(soundEnabled, forKey: Keys.soundEnabled) }
    }

    @Published var hapticEnabled: Bool {
        didSet { defaults.set(hapticEnabled, forKey: Keys.hapticEnabled) }
    }

    @Published var notificationsEnabled: Bool {
        didSet { defaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled) }
    }

    @Published var prefersDarkMode: Bool {
        didSet { defaults.set(prefersDarkMode, forKey: Keys.prefersDarkMode) }
    }

    // MARK: - Goals

    @Published var dailyGoalMinutes: Int {
        didSet { defaults.set(dailyGoalMinutes, forKey: Keys.dailyGoalMinutes) }
    }

    @Published var goalsEnabled: Bool {
        didSet { defaults.set(goalsEnabled, forKey: Keys.goalsEnabled) }
    }

    // MARK: - Pomodoro

    @Published var pomodoroEnabled: Bool {
        didSet { defaults.set(pomodoroEnabled, forKey: Keys.pomodoroEnabled) }
    }

    @Published var pomodoroWorkMinutes: Int {
        didSet { defaults.set(pomodoroWorkMinutes, forKey: Keys.pomodoroWorkMinutes) }
    }

    @Published var pomodoroShortBreakMinutes: Int {
        didSet { defaults.set(pomodoroShortBreakMinutes, forKey: Keys.pomodoroShortBreakMinutes) }
    }

    @Published var pomodoroLongBreakMinutes: Int {
        didSet { defaults.set(pomodoroLongBreakMinutes, forKey: Keys.pomodoroLongBreakMinutes) }
    }

    @Published var pomodoroSessionsBeforeLongBreak: Int {
        didSet { defaults.set(pomodoroSessionsBeforeLongBreak, forKey: Keys.pomodoroSessionsBeforeLongBreak) }
    }

    @Published var pomodoroAutoStartBreaks: Bool {
        didSet { defaults.set(pomodoroAutoStartBreaks, forKey: Keys.pomodoroAutoStartBreaks) }
    }

    // MARK: - Pro Status & Trial

    @Published var isProUser: Bool {
        didSet { defaults.set(isProUser, forKey: Keys.isProUser) }
    }

    var firstLaunchDate: Date {
        get {
            if let date = defaults.object(forKey: Keys.firstLaunchDate) as? Date {
                return date
            }
            let now = Date()
            defaults.set(now, forKey: Keys.firstLaunchDate)
            return now
        }
    }

    var isInTrial: Bool {
        guard !isProUser else { return false }
        let daysSinceLaunch = Calendar.current.dateComponents([.day], from: firstLaunchDate, to: Date()).day ?? 0
        return daysSinceLaunch < 7
    }

    var trialDaysRemaining: Int {
        let daysSinceLaunch = Calendar.current.dateComponents([.day], from: firstLaunchDate, to: Date()).day ?? 0
        return max(0, 7 - daysSinceLaunch)
    }

    /// Returns true if user has Pro access (purchased or in trial)
    var hasProAccess: Bool {
        isProUser || isInTrial
    }

    @Published var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) }
    }

    @Published var completedSessionCount: Int {
        didSet { defaults.set(completedSessionCount, forKey: Keys.completedSessionCount) }
    }

    @Published var hasSeenProUpsell: Bool {
        didSet { defaults.set(hasSeenProUpsell, forKey: Keys.hasSeenProUpsell) }
    }

    var timerEndTime: Date? {
        get { defaults.object(forKey: Keys.timerEndTime) as? Date }
        set { defaults.set(newValue, forKey: Keys.timerEndTime) }
    }

    var timerPlannedDuration: Int {
        get { defaults.integer(forKey: Keys.timerPlannedDuration) }
        set { defaults.set(newValue, forKey: Keys.timerPlannedDuration) }
    }

    init() {
        self.defaultDuration = defaults.object(forKey: Keys.defaultDuration) as? Int ?? Constants.Timer.defaultDuration
        self.customDurations = defaults.object(forKey: Keys.customDurations) as? [Int] ?? Constants.Timer.defaultDurations
        self.quickLabels = defaults.object(forKey: Keys.quickLabels) as? [String] ?? Constants.Labels.defaults
        self.soundEnabled = defaults.object(forKey: Keys.soundEnabled) as? Bool ?? true
        self.hapticEnabled = defaults.object(forKey: Keys.hapticEnabled) as? Bool ?? true
        self.notificationsEnabled = defaults.object(forKey: Keys.notificationsEnabled) as? Bool ?? true
        self.prefersDarkMode = defaults.object(forKey: Keys.prefersDarkMode) as? Bool ?? true
        // Goals
        self.dailyGoalMinutes = defaults.object(forKey: Keys.dailyGoalMinutes) as? Int ?? 120
        self.goalsEnabled = defaults.object(forKey: Keys.goalsEnabled) as? Bool ?? true
        // Pomodoro
        self.pomodoroEnabled = defaults.object(forKey: Keys.pomodoroEnabled) as? Bool ?? false
        self.pomodoroWorkMinutes = defaults.object(forKey: Keys.pomodoroWorkMinutes) as? Int ?? 25
        self.pomodoroShortBreakMinutes = defaults.object(forKey: Keys.pomodoroShortBreakMinutes) as? Int ?? 5
        self.pomodoroLongBreakMinutes = defaults.object(forKey: Keys.pomodoroLongBreakMinutes) as? Int ?? 15
        self.pomodoroSessionsBeforeLongBreak = defaults.object(forKey: Keys.pomodoroSessionsBeforeLongBreak) as? Int ?? 4
        self.pomodoroAutoStartBreaks = defaults.object(forKey: Keys.pomodoroAutoStartBreaks) as? Bool ?? true
        // Pro
        self.isProUser = defaults.object(forKey: Keys.isProUser) as? Bool ?? false
        // Onboarding & Upsell
        self.hasCompletedOnboarding = defaults.object(forKey: Keys.hasCompletedOnboarding) as? Bool ?? false
        self.completedSessionCount = defaults.object(forKey: Keys.completedSessionCount) as? Int ?? 0
        self.hasSeenProUpsell = defaults.object(forKey: Keys.hasSeenProUpsell) as? Bool ?? false
        // Initialize first launch date if not set
        if defaults.object(forKey: Keys.firstLaunchDate) == nil {
            defaults.set(Date(), forKey: Keys.firstLaunchDate)
        }
    }

    func resetToDefaults() {
        defaultDuration = Constants.Timer.defaultDuration
        customDurations = Constants.Timer.defaultDurations
        quickLabels = Constants.Labels.defaults
        soundEnabled = true
        hapticEnabled = true
        notificationsEnabled = true
        prefersDarkMode = true
        dailyGoalMinutes = 120
        goalsEnabled = true
        pomodoroEnabled = false
        pomodoroWorkMinutes = 25
        pomodoroShortBreakMinutes = 5
        pomodoroLongBreakMinutes = 15
        pomodoroSessionsBeforeLongBreak = 4
        pomodoroAutoStartBreaks = true
    }

    func clearTimerState() {
        timerEndTime = nil
        timerPlannedDuration = 0
    }
}
