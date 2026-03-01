import SwiftUI

struct PomodoroSettings: View {
    @EnvironmentObject private var userSettings: UserSettings

    var body: some View {
        List {
            Section {
                Toggle("Enable Pomodoro Mode", isOn: $userSettings.pomodoroEnabled)
            } footer: {
                Text("Pomodoro mode automatically cycles between focus sessions and breaks.")
            }

            if userSettings.pomodoroEnabled {
                Section("Work Session") {
                    Stepper(
                        "\(userSettings.pomodoroWorkMinutes) minutes",
                        value: $userSettings.pomodoroWorkMinutes,
                        in: 15...60,
                        step: 5
                    )
                }

                Section("Short Break") {
                    Stepper(
                        "\(userSettings.pomodoroShortBreakMinutes) minutes",
                        value: $userSettings.pomodoroShortBreakMinutes,
                        in: 1...15,
                        step: 1
                    )
                }

                Section("Long Break") {
                    Stepper(
                        "\(userSettings.pomodoroLongBreakMinutes) minutes",
                        value: $userSettings.pomodoroLongBreakMinutes,
                        in: 10...30,
                        step: 5
                    )

                    Stepper(
                        "After \(userSettings.pomodoroSessionsBeforeLongBreak) sessions",
                        value: $userSettings.pomodoroSessionsBeforeLongBreak,
                        in: 2...6,
                        step: 1
                    )
                }

                Section {
                    Toggle("Auto-start breaks", isOn: $userSettings.pomodoroAutoStartBreaks)
                } footer: {
                    Text("Automatically start the break timer when a work session ends.")
                }

                Section("Current Settings") {
                    HStack {
                        Text("Work")
                        Spacer()
                        Text("\(userSettings.pomodoroWorkMinutes) min")
                            .foregroundStyle(Constants.Colors.secondaryText)
                    }

                    HStack {
                        Text("Short Break")
                        Spacer()
                        Text("\(userSettings.pomodoroShortBreakMinutes) min")
                            .foregroundStyle(Constants.Colors.secondaryText)
                    }

                    HStack {
                        Text("Long Break")
                        Spacer()
                        Text("Every \(userSettings.pomodoroSessionsBeforeLongBreak) sessions, \(userSettings.pomodoroLongBreakMinutes) min")
                            .foregroundStyle(Constants.Colors.secondaryText)
                    }
                }
            }
        }
        .navigationTitle("Pomodoro")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PomodoroSettings()
            .environmentObject(UserSettings())
    }
}
