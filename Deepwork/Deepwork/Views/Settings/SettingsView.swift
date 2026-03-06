import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var userSettings: UserSettings

    @State private var showingDurationPicker = false
    @State private var showingLabelsEditor = false

    private let notificationService = NotificationService()

    var body: some View {
        NavigationStack {
            List {
                if !userSettings.isProUser {
                    proSection
                }
                timerSection
                if userSettings.hasProAccess {
                    pomodoroSection
                    goalsSection
                }
                focusNudgeSection
                feedbackSection
                reminderSection
                appearanceSection
                aboutSection
                #if DEBUG
                debugSection
                #endif
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showingDurationPicker) {
            DurationPicker(
                selectedDuration: $userSettings.defaultDuration,
                customDurations: $userSettings.customDurations
            )
        }
        .sheet(isPresented: $showingLabelsEditor) {
            LabelsEditor(labels: $userSettings.quickLabels)
        }
    }

    private var proSection: some View {
        Section {
            NavigationLink {
                ProUpgradeView()
            } label: {
                HStack {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Constants.Colors.accent)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Upgrade to Pro")
                            .font(Constants.Fonts.headline)
                            .foregroundStyle(Constants.Colors.primaryText)

                        if userSettings.isInTrial {
                            Text("Trial active — \(userSettings.trialDaysRemaining) days left")
                                .font(Constants.Fonts.caption)
                                .foregroundStyle(Constants.Colors.accent)
                        } else {
                            Text("Streaks, insights, widgets & more")
                                .font(Constants.Fonts.caption)
                                .foregroundStyle(Constants.Colors.secondaryText)
                        }
                    }

                    Spacer()

                    Text("$4.99")
                        .font(Constants.Fonts.headline)
                        .foregroundStyle(Constants.Colors.accent)
                }
                .padding(.vertical, Constants.Spacing.xs)
            }
        }
    }

    private var pomodoroSection: some View {
        Section("Pomodoro") {
            NavigationLink {
                PomodoroSettings()
            } label: {
                HStack {
                    Label("Pomodoro Mode", systemImage: "timer")
                        .foregroundStyle(Constants.Colors.primaryText)
                    Spacer()
                    Text(userSettings.pomodoroEnabled ? "On" : "Off")
                        .foregroundStyle(Constants.Colors.secondaryText)
                }
            }
        }
    }

    private var goalsSection: some View {
        Section("Goals") {
            Stepper(value: $userSettings.dailyGoalMinutes, in: 30...480, step: 30) {
                HStack {
                    Label("Daily Goal", systemImage: "target")
                    Spacer()
                    Text(TimeFormatters.formatDuration(userSettings.dailyGoalMinutes))
                        .foregroundStyle(Constants.Colors.secondaryText)
                }
            }

            Toggle(isOn: $userSettings.goalsEnabled) {
                Label("Track Goals", systemImage: "flame")
            }

            Stepper(value: $userSettings.graceDaysPerWeek, in: 0...3) {
                HStack {
                    Label("Grace Days/Week", systemImage: "heart.fill")
                    Spacer()
                    Text("\(userSettings.graceDaysPerWeek)")
                        .foregroundStyle(Constants.Colors.secondaryText)
                }
            }

            if userSettings.graceDaysPerWeek > 0 {
                Text("Your streak won't break if you miss up to \(userSettings.graceDaysPerWeek) \(userSettings.graceDaysPerWeek == 1 ? "day" : "days") per week (days with no sessions).")
                    .font(Constants.Fonts.caption)
                    .foregroundStyle(Constants.Colors.secondaryText)
            }
        }
    }

    private var timerSection: some View {
        Section("Timer") {
            Button {
                showingDurationPicker = true
            } label: {
                HStack {
                    Label("Default Duration", systemImage: "timer")
                        .foregroundStyle(Constants.Colors.primaryText)
                    Spacer()
                    Text(TimeFormatters.formatDuration(userSettings.defaultDuration))
                        .foregroundStyle(Constants.Colors.secondaryText)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Constants.Colors.secondaryText.opacity(0.5))
                }
            }

            Button {
                showingLabelsEditor = true
            } label: {
                HStack {
                    Label("Quick Labels", systemImage: "tag")
                        .foregroundStyle(Constants.Colors.primaryText)
                    Spacer()
                    Text("\(userSettings.quickLabels.count) labels")
                        .foregroundStyle(Constants.Colors.secondaryText)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Constants.Colors.secondaryText.opacity(0.5))
                }
            }
        }
    }

    private var focusNudgeSection: some View {
        Section("Focus Nudge") {
            Toggle(isOn: $userSettings.hyperfocusNudgeEnabled) {
                Label("Hyperfocus Nudge", systemImage: "drop.fill")
            }

            if userSettings.hyperfocusNudgeEnabled {
                Picker("Interval", selection: $userSettings.hyperfocusNudgeIntervalMinutes) {
                    Text("15 min").tag(15)
                    Text("20 min").tag(20)
                    Text("30 min").tag(30)
                    Text("45 min").tag(45)
                    Text("60 min").tag(60)
                }

                Text("Gently reminds you to stretch, hydrate, or take a break during long sessions.")
                    .font(Constants.Fonts.caption)
                    .foregroundStyle(Constants.Colors.secondaryText)
            }
        }
    }

    private var feedbackSection: some View {
        Section("Feedback") {
            Toggle(isOn: $userSettings.notificationsEnabled) {
                Label("Notifications", systemImage: "bell")
            }
            .onChange(of: userSettings.notificationsEnabled) { _, isEnabled in
                if isEnabled {
                    Task {
                        await notificationService.requestAuthorization()
                    }
                }
            }

            Toggle(isOn: $userSettings.soundEnabled) {
                Label("Sound", systemImage: "speaker.wave.2")
            }

            Toggle(isOn: $userSettings.hapticEnabled) {
                Label("Haptics", systemImage: "hand.tap")
            }
        }
    }

    private var reminderSection: some View {
        Section("Reminders") {
            Toggle(isOn: $userSettings.reminderEnabled) {
                Label("Daily Reminder", systemImage: "bell.badge")
            }
            .onChange(of: userSettings.reminderEnabled) { _, isEnabled in
                if isEnabled {
                    Task {
                        await notificationService.requestAuthorization()
                    }
                    notificationService.scheduleDailyReminder(at: userSettings.reminderTime)
                } else {
                    notificationService.cancelDailyReminder()
                }
            }

            if userSettings.reminderEnabled {
                DatePicker(
                    "Reminder Time",
                    selection: $userSettings.reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .onChange(of: userSettings.reminderTime) { _, newTime in
                    notificationService.scheduleDailyReminder(at: newTime)
                }
            }
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Toggle(isOn: $userSettings.prefersDarkMode) {
                Label("Dark Mode", systemImage: "moon")
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            NavigationLink {
                ScienceView()
            } label: {
                Label("The Science", systemImage: "brain.head.profile")
            }

            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(Constants.Colors.secondaryText)
            }

            Button {
                userSettings.resetToDefaults()
            } label: {
                Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                    .foregroundStyle(Constants.Colors.warning)
            }
        }
    }

    #if DEBUG
    private var debugSection: some View {
        Section("Debug") {
            Toggle(isOn: $userSettings.isProUser) {
                Label("Pro User", systemImage: "star.fill")
            }

            HStack {
                Label("Sessions Completed", systemImage: "checkmark.circle")
                Spacer()
                Text("\(userSettings.completedSessionCount)")
                    .foregroundStyle(Constants.Colors.secondaryText)
            }

            Button {
                UserDefaults.standard.set(Date.distantPast, forKey: "firstLaunchDate")
            } label: {
                Label("Expire Trial", systemImage: "clock.badge.xmark")
            }

            Button {
                userSettings.completedSessionCount = 0
                userSettings.hasSeenProUpsell = false
                userSettings.hasCompletedOnboarding = false
            } label: {
                Label("Reset Onboarding & Upsell", systemImage: "arrow.counterclockwise")
            }
        }
    }
    #endif
}

#Preview {
    SettingsView()
        .environmentObject(UserSettings())
}
