import SwiftUI
import SwiftData

struct TimerView: View {
    @EnvironmentObject private var timerService: TimerService
    @EnvironmentObject private var userSettings: UserSettings
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \FocusSession.startTime, order: .reverse) private var sessions: [FocusSession]

    @State private var selectedDuration: Int = 25
    @State private var showingCompletionSheet = false
    @State private var showingMicroCommitmentSheet = false
    @State private var showingProUpsell = false
    @State private var showingEnergyCheckIn = false
    @State private var isMicroCommitment = false
    @State private var selectedEnergy: EnergyLevel = .notRated
    @State private var sessionIntention: String = ""
    @State private var selectedLabel: String = ""
    @State private var timerMode: TimerMode = .countdown
    @State private var currentQuote: String = Constants.Quotes.random()
    @State private var showConfetti = false
    @State private var showingStreakMilestone = false
    @State private var currentMilestone: Constants.StreakMilestones.Milestone?
    @State private var currentRecommendation: DurationRecommendation?
    @State private var userManuallySelectedDuration = false
    @StateObject private var soundscapeService = SoundscapeService.shared

    private let notificationService = NotificationService()
    private let soundService = SoundService()
    private let hapticService = HapticService()
    private let streakService = StreakService()
    private let recommendationService = RecommendationService()

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: Constants.Spacing.lg) {
                    Spacer()

                    if timerMode == .stopwatch && timerService.state != .idle {
                        // Stopwatch display
                        TimerRing(
                            progress: 0,
                            remainingSeconds: timerService.stopwatchSeconds,
                            state: timerService.state,
                            isStopwatch: true
                        )
                        .frame(width: min(geometry.size.width - 64, 320))
                    } else {
                        TimerRing(
                            progress: timerService.progress,
                            remainingSeconds: timerService.state == .idle
                                ? (timerMode == .stopwatch ? 0 : selectedDuration * 60)
                                : timerService.remainingSeconds,
                            state: timerService.state
                        )
                        .frame(width: min(geometry.size.width - 64, 320))
                    }

                    if timerService.state == .idle {
                        // Mode toggle
                        Picker("Mode", selection: $timerMode) {
                            Label("Timer", systemImage: "timer")
                                .tag(TimerMode.countdown)
                            Label("Stopwatch", systemImage: "stopwatch")
                                .tag(TimerMode.stopwatch)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, Constants.Spacing.xl)

                        if timerMode == .countdown {
                            QuickDurationPicker(
                                selectedDuration: $selectedDuration,
                                durations: userSettings.customDurations,
                                recommendedDuration: currentRecommendation?.minutes,
                                recommendationConfidence: currentRecommendation?.confidence,
                                sessionCount: sessions.count,
                                onManualSelect: {
                                    userManuallySelectedDuration = true
                                }
                            )
                            .padding(.horizontal, Constants.Spacing.md)
                        }

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

                        // Quick label picker
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Constants.Spacing.sm) {
                                ForEach(userSettings.quickLabels, id: \.self) { label in
                                    Button {
                                        selectedLabel = label
                                    } label: {
                                        Text(label)
                                            .font(Constants.Fonts.caption)
                                            .foregroundStyle(selectedLabel == label ? .white : Constants.Colors.primaryText)
                                            .padding(.horizontal, Constants.Spacing.md)
                                            .padding(.vertical, Constants.Spacing.sm)
                                            .background(selectedLabel == label ? Constants.Colors.accent : Constants.Colors.secondaryBackground)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal, Constants.Spacing.md)
                        }

                        // Focus quote
                        Text(currentQuote)
                            .font(Constants.Fonts.caption)
                            .foregroundStyle(Constants.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Constants.Spacing.xl)
                            .transition(.opacity)
                            .id(currentQuote)
                    }

                    Spacer()

                    TimerControls(
                        state: timerService.state,
                        onStart: startTimer,
                        onPause: pauseTimer,
                        onResume: resumeTimer,
                        onStop: stopTimer
                    )

                    if timerService.state == .idle && timerMode == .countdown {
                        Button {
                            startMicroCommitment()
                        } label: {
                            Text("or just 5 minutes...")
                                .font(Constants.Fonts.caption)
                                .foregroundStyle(Constants.Colors.accent)
                        }
                    }

                    Spacer()
                        .frame(height: Constants.Spacing.md)
                }
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Focus")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            setupServices()
            if selectedLabel.isEmpty, let first = userSettings.quickLabels.first {
                selectedLabel = first
            }
            loadRecommendation()
            timerService.restoreFromBackground(settings: userSettings)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                timerService.restoreFromBackground(settings: userSettings)
            }
        }
        .onChange(of: userSettings.hyperfocusNudgeEnabled) { _, val in
            timerService.nudgeEnabled = val
        }
        .onChange(of: userSettings.hyperfocusNudgeIntervalMinutes) { _, val in
            timerService.nudgeIntervalSeconds = val * 60
        }
        .onChange(of: selectedLabel) { _, _ in
            if timerService.state == .idle && !userManuallySelectedDuration {
                loadRecommendation()
            }
        }
        .onChange(of: sessions.count) { _, _ in
            if timerService.state == .idle && !userManuallySelectedDuration {
                loadRecommendation()
            }
        }
        .onChange(of: timerService.state) { _, newState in
            if newState == .completed {
                stopSoundscape()
                if isMicroCommitment {
                    showingMicroCommitmentSheet = true
                } else {
                    showingCompletionSheet = true
                }
            }
            if newState == .idle {
                userManuallySelectedDuration = false
                loadRecommendation()
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentQuote = Constants.Quotes.random()
                }
            }
        }
        .sheet(isPresented: $showingCompletionSheet) {
            SessionCompleteSheet(
                plannedDuration: timerService.plannedDuration,
                actualDuration: timerService.elapsedSeconds,
                onSave: saveSession,
                onDiscard: discardSession,
                isStopwatch: timerService.mode == .stopwatch,
                intention: sessionIntention,
                preselectedLabel: selectedLabel
            )
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showingMicroCommitmentSheet) {
            MicroCommitmentCompleteSheet(
                onExtend: { seconds in
                    isMicroCommitment = false
                    timerService.extendTimer(by: seconds, settings: userSettings)
                    if soundscapeService.selectedSoundscape != .none {
                        soundscapeService.resume()
                    }
                },
                onFinish: {
                    isMicroCommitment = false
                    showingCompletionSheet = true
                }
            )
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showingProUpsell) {
            ProUpsellSheet()
        }
        .sheet(isPresented: $showingEnergyCheckIn) {
            EnergyCheckInSheet { level, intention in
                selectedEnergy = level
                sessionIntention = intention
                // Recalculate recommendation with fresh energy if user hasn't manually overridden
                if !userManuallySelectedDuration && !isMicroCommitment {
                    let rec = recommendationService.recommend(
                        energy: level,
                        label: selectedLabel,
                        currentHour: Calendar.current.component(.hour, from: Date()),
                        sessions: sessions,
                        dailyGoalMinutes: userSettings.dailyGoalMinutes,
                        todayMinutesSoFar: todayMinutesSoFar()
                    )
                    currentRecommendation = rec
                    selectedDuration = rec.minutes
                }
                beginTimerAfterCheckIn()
            }
        }
        .fullScreenCover(isPresented: $showingStreakMilestone) {
            if let milestone = currentMilestone {
                ZStack {
                    StreakMilestoneSheet(milestone: milestone) {
                        showingStreakMilestone = false
                        currentMilestone = nil
                    }
                    ConfettiView(isActive: $showingStreakMilestone)
                }
            }
        }
        .overlay {
            ConfettiView(isActive: $showConfetti)
        }
        .overlay {
            if timerService.shouldShowNudge {
                HyperfocusNudgeOverlay {
                    timerService.dismissNudge()
                }
            }
        }
    }

    private func loadRecommendation() {
        let rec = recommendationService.recommend(
            energy: selectedEnergy,
            label: selectedLabel,
            currentHour: Calendar.current.component(.hour, from: Date()),
            sessions: sessions,
            dailyGoalMinutes: userSettings.dailyGoalMinutes,
            todayMinutesSoFar: todayMinutesSoFar()
        )
        currentRecommendation = rec
        selectedDuration = rec.minutes
    }

    private func todayMinutesSoFar() -> Int {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return sessions
            .filter { $0.startTime >= startOfDay }
            .reduce(0) { $0 + $1.actualMinutes }
    }

    private func setupServices() {
        soundService.setEnabled(userSettings.soundEnabled)
        hapticService.setEnabled(userSettings.hapticEnabled)
        timerService.configure(
            notificationService: notificationService,
            soundService: soundService,
            hapticService: hapticService
        )
        timerService.nudgeEnabled = userSettings.hyperfocusNudgeEnabled
        timerService.nudgeIntervalSeconds = userSettings.hyperfocusNudgeIntervalMinutes * 60

        Task {
            if userSettings.notificationsEnabled {
                await notificationService.requestAuthorization()
            }
        }
    }

    private func startTimer() {
        showingEnergyCheckIn = true
    }

    private func startMicroCommitment() {
        isMicroCommitment = true
        selectedDuration = 5
        showingEnergyCheckIn = true
    }

    private func beginTimerAfterCheckIn() {
        if timerMode == .stopwatch {
            timerService.startStopwatch(settings: userSettings)
        } else {
            let durationInSeconds = selectedDuration * 60
            timerService.start(duration: durationInSeconds, settings: userSettings)
        }
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
        if timerService.mode == .stopwatch {
            stopSoundscape()
            timerService.stop(settings: userSettings)
            if timerService.state == .completed {
                showingCompletionSheet = true
            }
        } else {
            let elapsed = timerService.elapsedSeconds
            if elapsed >= 60 {
                stopSoundscape()
                showingCompletionSheet = true
            } else {
                stopSoundscape()
                timerService.stop(settings: userSettings)
            }
        }
    }

    private func stopSoundscape() {
        soundscapeService.stop()
    }

    private func saveSession(label: String, notes: String, intentionCompleted: Bool) {
        let session = FocusSession(
            startTime: timerService.startTime ?? Date().addingTimeInterval(-TimeInterval(timerService.elapsedSeconds)),
            endTime: Date(),
            plannedDuration: timerService.plannedDuration,
            actualDuration: timerService.elapsedSeconds,
            label: label,
            notes: notes,
            wasCompleted: timerService.state == .completed || timerService.mode == .stopwatch,
            energyLevel: selectedEnergy,
            intention: sessionIntention,
            intentionCompleted: intentionCompleted
        )

        modelContext.insert(session)
        timerService.acknowledgeCompletion()
        userSettings.clearTimerState()
        showingCompletionSheet = false

        // Celebration confetti + haptic burst
        showConfetti = true
        hapticService.playCelebration()

        // Award XP (Pro feature)
        if userSettings.hasProAccess {
            let xpEarned = XPService.calculateSessionXP(
                durationSeconds: session.actualDuration,
                wasCompleted: session.wasCompleted,
                currentStreak: 0 // Streak calculated separately
            )
            let oldLevel = userSettings.currentLevel
            userSettings.totalXP += xpEarned
            let newResult = XPService.getXPResult(totalXP: userSettings.totalXP)
            userSettings.currentLevel = newResult.level.level

            // Level up celebration — extra confetti burst
            if newResult.level.level > oldLevel {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showConfetti = true
                    hapticService.playCelebration()
                }
            }
        }

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

        // Check for streak milestone celebration (Pro feature)
        if userSettings.hasProAccess {
            let goalMinutes = userSettings.dailyGoalMinutes
            let graceDays = userSettings.graceDaysPerWeek
            let streakSvc = streakService

            Task.detached {
                let descriptor = FetchDescriptor<FocusSession>()
                let allSessions: [FocusSession]
                do {
                    allSessions = try await MainActor.run {
                        try modelContext.fetch(descriptor)
                    }
                } catch {
                    return
                }

                let streakInfo = streakSvc.calculateStreakInfo(
                    sessions: allSessions,
                    goalMinutes: goalMinutes,
                    graceDaysPerWeek: graceDays
                )

                if CelebrationTrigger.shouldCelebrate(streak: streakInfo.currentStreak),
                   let milestone = Constants.StreakMilestones.milestone(for: streakInfo.currentStreak) {
                    try? await Task.sleep(for: .seconds(1))
                    await MainActor.run {
                        currentMilestone = milestone
                        showingStreakMilestone = true
                    }
                }
            }
        }

        selectedEnergy = .notRated
        sessionIntention = ""
        isMicroCommitment = false
    }

    private func discardSession() {
        timerService.acknowledgeCompletion()
        userSettings.clearTimerState()
        showingCompletionSheet = false
        selectedEnergy = .notRated
        sessionIntention = ""
        isMicroCommitment = false
    }
}

#Preview {
    TimerView()
        .environmentObject(TimerService())
        .environmentObject(UserSettings())
}
