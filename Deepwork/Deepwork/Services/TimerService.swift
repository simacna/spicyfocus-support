import Foundation
import Combine
import SwiftUI
import ActivityKit

enum TimerState: Equatable {
    case idle
    case running
    case paused
    case completed
}

enum TimerMode: Equatable {
    case countdown
    case stopwatch
}

@MainActor
final class TimerService: ObservableObject {
    @Published private(set) var state: TimerState = .idle
    @Published private(set) var remainingSeconds: Int = 0
    @Published private(set) var progress: Double = 0
    @Published private(set) var mode: TimerMode = .countdown
    @Published private(set) var stopwatchSeconds: Int = 0
    @Published var shouldShowNudge = false

    private(set) var plannedDuration: Int = 0
    private(set) var startTime: Date?
    private var endTime: Date?
    private var pausedTimeRemaining: Int = 0
    private var pausedElapsed: Int = 0

    private var timer: Timer?
    private var lastNudgeTime: Date?
    var nudgeEnabled = false
    var nudgeIntervalSeconds: Int = 1800
    private var notificationService: NotificationService?
    private var soundService: SoundService?
    private var hapticService: HapticService?
    private var currentActivity: Activity<FocusTimerAttributes>?

    var elapsedSeconds: Int {
        if mode == .stopwatch {
            return stopwatchSeconds
        }
        return plannedDuration - remainingSeconds
    }

    func configure(
        notificationService: NotificationService,
        soundService: SoundService,
        hapticService: HapticService
    ) {
        self.notificationService = notificationService
        self.soundService = soundService
        self.hapticService = hapticService
    }

    func start(duration: Int, settings: UserSettings) {
        mode = .countdown
        plannedDuration = duration
        remainingSeconds = duration
        stopwatchSeconds = 0
        startTime = Date()
        endTime = Date().addingTimeInterval(TimeInterval(duration))
        lastNudgeTime = Date()
        shouldShowNudge = false

        settings.timerEndTime = endTime
        settings.timerPlannedDuration = duration
        settings.timerIsStopwatch = false

        state = .running
        startTimer()

        if settings.notificationsEnabled {
            notificationService?.scheduleTimerCompletion(in: TimeInterval(duration))
        }

        hapticService?.playStart()
        startLiveActivity(endTime: endTime!, label: "Focus")
    }

    func startStopwatch(settings: UserSettings) {
        mode = .stopwatch
        plannedDuration = 0
        remainingSeconds = 0
        stopwatchSeconds = 0
        startTime = Date()
        endTime = nil
        pausedElapsed = 0
        lastNudgeTime = Date()
        shouldShowNudge = false

        settings.timerStartTime = startTime
        settings.timerIsStopwatch = true

        state = .running
        startTimer()

        hapticService?.playStart()
        startStopwatchLiveActivity(startTime: startTime!, label: "Focus")
    }

    func pause(settings: UserSettings) {
        guard state == .running else { return }

        if mode == .stopwatch {
            pausedElapsed = stopwatchSeconds
        } else {
            pausedTimeRemaining = remainingSeconds
        }
        state = .paused
        stopTimer()

        settings.clearTimerState()
        notificationService?.cancelPendingNotifications()

        hapticService?.playPause()
        updateLiveActivity(isPaused: true)
    }

    func resume(settings: UserSettings) {
        guard state == .paused else { return }

        if mode == .stopwatch {
            startTime = Date().addingTimeInterval(-TimeInterval(pausedElapsed))
            settings.timerStartTime = startTime
            settings.timerIsStopwatch = true
        } else {
            endTime = Date().addingTimeInterval(TimeInterval(pausedTimeRemaining))
            settings.timerEndTime = endTime
            settings.timerPlannedDuration = plannedDuration

            if settings.notificationsEnabled {
                notificationService?.scheduleTimerCompletion(in: TimeInterval(pausedTimeRemaining))
            }

            updateLiveActivity(endTime: endTime!, isPaused: false)
        }

        state = .running
        startTimer()

        hapticService?.playResume()
        if mode == .stopwatch {
            updateLiveActivity(isPaused: false)
        }
    }

    func stop(settings: UserSettings) {
        if mode == .stopwatch && stopwatchSeconds >= 60 {
            // For stopwatch, "stop" triggers completion so user can save
            plannedDuration = stopwatchSeconds
            state = .completed
            stopTimer()
            settings.clearTimerState()
            soundService?.playCompletion()
            hapticService?.playCompletion()
            endLiveActivity()
            return
        }

        state = .idle
        stopTimer()
        settings.clearTimerState()
        notificationService?.cancelPendingNotifications()

        remainingSeconds = 0
        progress = 0
        plannedDuration = 0
        stopwatchSeconds = 0
        startTime = nil
        endTime = nil
        pausedTimeRemaining = 0
        pausedElapsed = 0

        hapticService?.playStop()
        endLiveActivity()
    }

    func restoreFromBackground(settings: UserSettings) {
        // Restore stopwatch mode
        if settings.timerIsStopwatch, let savedStartTime = settings.timerStartTime {
            mode = .stopwatch
            startTime = savedStartTime
            let elapsed = Int(Date().timeIntervalSince(savedStartTime))
            stopwatchSeconds = elapsed
            state = .running
            startTimer()
            return
        }

        // Restore countdown mode
        guard let savedEndTime = settings.timerEndTime,
              settings.timerPlannedDuration > 0 else {
            return
        }

        mode = .countdown
        plannedDuration = settings.timerPlannedDuration
        endTime = savedEndTime

        let remaining = Int(savedEndTime.timeIntervalSinceNow)

        if remaining <= 0 {
            remainingSeconds = 0
            progress = 1.0
            state = .completed
            settings.clearTimerState()
            soundService?.playCompletion()
            hapticService?.playCompletion()
        } else {
            remainingSeconds = remaining
            progress = 1.0 - (Double(remaining) / Double(plannedDuration))
            state = .running
            startTimer()
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard state == .running else { return }

        if mode == .stopwatch {
            guard let start = startTime else { return }
            stopwatchSeconds = Int(Date().timeIntervalSince(start))
            checkNudge()
            return
        }

        guard let endTime = endTime else { return }
        let remaining = max(0, Int(ceil(endTime.timeIntervalSinceNow)))
        remainingSeconds = remaining
        progress = 1.0 - (Double(remaining) / Double(plannedDuration))

        checkNudge()

        if remaining <= 0 {
            complete()
        }
    }

    private func checkNudge() {
        guard nudgeEnabled, !shouldShowNudge else { return }
        let reference = lastNudgeTime ?? startTime ?? Date()
        let elapsed = Int(Date().timeIntervalSince(reference))
        if elapsed >= nudgeIntervalSeconds {
            shouldShowNudge = true
        }
    }

    func dismissNudge() {
        shouldShowNudge = false
        lastNudgeTime = Date()
    }

    private func complete() {
        state = .completed
        stopTimer()
        remainingSeconds = 0
        progress = 1.0

        soundService?.playCompletion()
        hapticService?.playCompletion()
        endLiveActivity()
    }

    func extendTimer(by seconds: Int, settings: UserSettings) {
        plannedDuration += seconds
        remainingSeconds = seconds
        endTime = Date().addingTimeInterval(TimeInterval(seconds))
        progress = 1.0 - (Double(seconds) / Double(plannedDuration))
        state = .running

        settings.timerEndTime = endTime
        settings.timerPlannedDuration = plannedDuration

        if settings.notificationsEnabled {
            notificationService?.scheduleTimerCompletion(in: TimeInterval(seconds))
        }

        startTimer()
        startLiveActivity(endTime: endTime!, label: "Focus")
    }

    func acknowledgeCompletion() {
        state = .idle
        remainingSeconds = 0
        progress = 0
        plannedDuration = 0
        stopwatchSeconds = 0
        startTime = nil
        endTime = nil
        pausedElapsed = 0
        mode = .countdown
    }

    // MARK: - Live Activity

    private func startLiveActivity(endTime: Date, label: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = FocusTimerAttributes(
            plannedDuration: plannedDuration,
            sessionLabel: label
        )
        let contentState = FocusTimerAttributes.ContentState(
            endTime: endTime,
            label: label,
            isPaused: false
        )
        let content = ActivityContent(state: contentState, staleDate: endTime)

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            // Live Activity request failed
        }
    }

    private func updateLiveActivity(endTime: Date? = nil, isPaused: Bool) {
        guard let activity = currentActivity else { return }
        let newEndTime = endTime ?? activity.content.state.endTime
        let contentState = FocusTimerAttributes.ContentState(
            endTime: newEndTime,
            label: activity.content.state.label,
            isPaused: isPaused
        )
        let content = ActivityContent(state: contentState, staleDate: nil)
        Task {
            await activity.update(content)
        }
    }

    private func startStopwatchLiveActivity(startTime: Date, label: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = FocusTimerAttributes(
            plannedDuration: 0,
            sessionLabel: label
        )
        let contentState = FocusTimerAttributes.ContentState(
            endTime: startTime,
            label: label,
            isPaused: false,
            isStopwatch: true
        )
        let content = ActivityContent(state: contentState, staleDate: nil)

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            // Live Activity request failed
        }
    }

    private func endLiveActivity() {
        guard let activity = currentActivity else { return }
        let finalState = FocusTimerAttributes.ContentState(
            endTime: Date(),
            label: activity.content.state.label,
            isPaused: false
        )
        let content = ActivityContent(state: finalState, staleDate: nil)
        Task {
            await activity.end(content, dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }
}
