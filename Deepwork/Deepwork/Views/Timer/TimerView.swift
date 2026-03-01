import SwiftUI
import SwiftData

struct TimerView: View {
    @EnvironmentObject private var timerService: TimerService
    @EnvironmentObject private var userSettings: UserSettings
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @State private var selectedDuration: Int = 25
    @State private var showingCompletionSheet = false
    @State private var showingProUpsell = false
    @StateObject private var soundscapeService = SoundscapeService.shared

    private let notificationService = NotificationService()
    private let soundService = SoundService()
    private let hapticService = HapticService()

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: Constants.Spacing.lg) {
                    Spacer()

                    TimerRing(
                        progress: timerService.progress,
                        remainingSeconds: timerService.remainingSeconds,
                        state: timerService.state
                    )
                    .frame(width: min(geometry.size.width - 64, 320))

                    if timerService.state == .idle {
                        QuickDurationPicker(
                            selectedDuration: $selectedDuration,
                            durations: userSettings.customDurations
                        )
                        .padding(.horizontal, Constants.Spacing.md)

                        // Soundscape picker
                        Menu {
                            ForEach(Soundscape.allCases) { soundscape in
                                if !soundscape.requiresPro || userSettings.hasProAccess {
                                    Button {
                                        soundscapeService.play(soundscape)
                                    } label: {
                                        Label(soundscape.rawValue, systemImage: soundscape.icon)
                                    }
                                } else {
                                    Button {
                                        // Pro required - do nothing
                                    } label: {
                                        Label("\(soundscape.rawValue) (Pro)", systemImage: "lock")
                                    }
                                    .disabled(true)
                                }
                            }
                        } label: {
                            HStack(spacing: Constants.Spacing.sm) {
                                Image(systemName: soundscapeService.selectedSoundscape.icon)
                                Text(soundscapeService.selectedSoundscape.rawValue)
                                    .font(Constants.Fonts.caption)
                            }
                            .foregroundStyle(Constants.Colors.secondaryText)
                            .padding(.horizontal, Constants.Spacing.md)
                            .padding(.vertical, Constants.Spacing.sm)
                            .background(Constants.Colors.secondaryBackground)
                            .clipShape(Capsule())
                        }
                    }

                    Spacer()

                    TimerControls(
                        state: timerService.state,
                        onStart: startTimer,
                        onPause: pauseTimer,
                        onResume: resumeTimer,
                        onStop: stopTimer
                    )
                    .padding(.bottom, Constants.Spacing.xl)
                }
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Focus")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            setupServices()
            selectedDuration = userSettings.defaultDuration
            timerService.restoreFromBackground(settings: userSettings)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                timerService.restoreFromBackground(settings: userSettings)
            }
        }
        .onChange(of: timerService.state) { _, newState in
            if newState == .completed {
                stopSoundscape()
                showingCompletionSheet = true
            }
        }
        .sheet(isPresented: $showingCompletionSheet) {
            SessionCompleteSheet(
                plannedDuration: timerService.plannedDuration,
                actualDuration: timerService.elapsedSeconds,
                onSave: saveSession,
                onDiscard: discardSession
            )
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showingProUpsell) {
            ProUpsellSheet()
        }
    }

    private func setupServices() {
        soundService.setEnabled(userSettings.soundEnabled)
        hapticService.setEnabled(userSettings.hapticEnabled)
        timerService.configure(
            notificationService: notificationService,
            soundService: soundService,
            hapticService: hapticService
        )

        Task {
            if userSettings.notificationsEnabled {
                await notificationService.requestAuthorization()
            }
        }
    }

    private func startTimer() {
        let durationInSeconds = selectedDuration * 60
        timerService.start(duration: durationInSeconds, settings: userSettings)
        if soundscapeService.selectedSoundscape != .none {
            soundscapeService.resume()
        }
    }

    private func pauseTimer() {
        timerService.pause(settings: userSettings)
        soundscapeService.pause()
    }

    private func resumeTimer() {
        timerService.resume(settings: userSettings)
        soundscapeService.resume()
    }

    private func stopTimer() {
        let elapsed = timerService.elapsedSeconds
        if elapsed >= 60 {
            stopSoundscape()
            showingCompletionSheet = true
        } else {
            stopSoundscape()
            timerService.stop(settings: userSettings)
        }
    }

    private func stopSoundscape() {
        soundscapeService.stop()
    }

    private func saveSession(label: String, notes: String) {
        let session = FocusSession(
            startTime: timerService.startTime ?? Date().addingTimeInterval(-TimeInterval(timerService.elapsedSeconds)),
            endTime: Date(),
            plannedDuration: timerService.plannedDuration,
            actualDuration: timerService.elapsedSeconds,
            label: label,
            notes: notes,
            wasCompleted: timerService.state == .completed
        )

        modelContext.insert(session)
        timerService.acknowledgeCompletion()
        userSettings.clearTimerState()

        // Track completed sessions and show Pro upsell after 3rd session
        userSettings.completedSessionCount += 1

        if userSettings.completedSessionCount == 3 &&
           !userSettings.hasProAccess &&
           !userSettings.hasSeenProUpsell {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingProUpsell = true
                userSettings.hasSeenProUpsell = true
            }
        }
    }

    private func discardSession() {
        timerService.acknowledgeCompletion()
        userSettings.clearTimerState()
    }
}

#Preview {
    TimerView()
        .environmentObject(TimerService())
        .environmentObject(UserSettings())
}
