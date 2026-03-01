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

@MainActor
final class TimerService: ObservableObject {
    @Published private(set) var state: TimerState = .idle
    @Published private(set) var remainingSeconds: Int = 0
    @Published private(set) var progress: Double = 0

    private(set) var plannedDuration: Int = 0
    private(set) var startTime: Date?
    private var endTime: Date?
    private var pausedTimeRemaining: Int = 0

    private var timer: Timer?
    private var notificationService: NotificationService?
    private var soundService: SoundService?
    private var hapticService: HapticService?
    private var currentActivity: Activity<FocusTimerAttributes>?

    var elapsedSeconds: Int {
        plannedDuration - remainingSeconds
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
        plannedDuration = duration
        remainingSeconds = duration
        startTime = Date()
        endTime = Date().addingTimeInterval(TimeInterval(duration))

        settings.timerEndTime = endTime
        settings.timerPlannedDuration = duration

        state = .running
        startTimer()

        if settings.notificationsEnabled {
            notificationService?.scheduleTimerCompletion(in: TimeInterval(duration))
        }

        hapticService?.playStart()
        startLiveActivity(endTime: endTime!, label: "Focus")
    }

    func pause(settings: UserSettings) {
        guard state == .running else { return }

        pausedTimeRemaining = remainingSeconds
        state = .paused
        stopTimer()

        settings.clearTimerState()
        notificationService?.cancelPendingNotifications()

        hapticService?.playPause()
        updateLiveActivity(isPaused: true)
    }

    func resume(settings: UserSettings) {
        guard state == .paused else { return }

        endTime = Date().addingTimeInterval(TimeInterval(pausedTimeRemaining))
        settings.timerEndTime = endTime
        settings.timerPlannedDuration = plannedDuration

        state = .running
        startTimer()

        if settings.notificationsEnabled {
            notificationService?.scheduleTimerCompletion(in: TimeInterval(pausedTimeRemaining))
        }

        hapticService?.playResume()
        updateLiveActivity(endTime: endTime!, isPaused: false)
    }

    func stop(settings: UserSettings) {
        state = .idle
        stopTimer()
        settings.clearTimerState()
        notificationService?.cancelPendingNotifications()

        remainingSeconds = 0
        progress = 0
        plannedDuration = 0
        startTime = nil
        endTime = nil
        pausedTimeRemaining = 0

        hapticService?.playStop()
        endLiveActivity()
    }

    func restoreFromBackground(settings: UserSettings) {
        guard let savedEndTime = settings.timerEndTime,
              settings.timerPlannedDuration > 0 else {
            return
        }

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
        guard let endTime = endTime, state == .running else { return }

        let remaining = max(0, Int(ceil(endTime.timeIntervalSinceNow)))
        remainingSeconds = remaining
        progress = 1.0 - (Double(remaining) / Double(plannedDuration))

        if remaining <= 0 {
            complete()
        }
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

    func acknowledgeCompletion() {
        state = .idle
        remainingSeconds = 0
        progress = 0
        plannedDuration = 0
        startTime = nil
        endTime = nil
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
