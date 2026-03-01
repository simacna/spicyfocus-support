import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var userSettings: UserSettings

    @State private var showingDurationPicker = false
    @State private var showingLabelsEditor = false

    private let notificationService = NotificationService()

    var body: some View {
        NavigationStack {
            List {
                if !userSettings.hasProAccess {
                    proSection
                }
                timerSection
                if userSettings.hasProAccess {
                    pomodoroSection
                    goalsSection
                }
                feedbackSection
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

                        Text("Streaks, insights, widgets & more")
                            .font(Constants.Fonts.caption)
                            .foregroundStyle(Constants.Colors.secondaryText)
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
