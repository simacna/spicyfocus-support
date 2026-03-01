import SwiftUI

enum PomodoroPhase: String {
    case work = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"

    var color: Color {
        switch self {
        case .work:
            return Constants.Colors.accent
        case .shortBreak:
            return Constants.Colors.success
        case .longBreak:
            return .blue
        }
    }

    var icon: String {
        switch self {
        case .work:
            return "brain.head.profile"
        case .shortBreak:
            return "cup.and.saucer.fill"
        case .longBreak:
            return "leaf.fill"
        }
    }
}

struct PomodoroControls: View {
    let currentPhase: PomodoroPhase
    let completedSessions: Int
    let totalSessions: Int
    let isActive: Bool

    var body: some View {
        VStack(spacing: Constants.Spacing.sm) {
            // Phase indicator
            HStack(spacing: Constants.Spacing.xs) {
                Image(systemName: currentPhase.icon)
                    .foregroundStyle(currentPhase.color)

                Text(currentPhase.rawValue)
                    .font(Constants.Fonts.headline)
                    .foregroundStyle(Constants.Colors.primaryText)
            }

            // Session dots
            HStack(spacing: Constants.Spacing.xs) {
                ForEach(0..<totalSessions, id: \.self) { index in
                    Circle()
                        .fill(index < completedSessions ? Constants.Colors.accent : Constants.Colors.secondaryText.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            if completedSessions > 0 {
                Text("\(completedSessions) of \(totalSessions) sessions")
                    .font(Constants.Fonts.caption)
                    .foregroundStyle(Constants.Colors.secondaryText)
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct PomodoroModeToggle: View {
    @Binding var isEnabled: Bool

    var body: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundStyle(isEnabled ? Constants.Colors.accent : Constants.Colors.secondaryText)

            VStack(alignment: .leading, spacing: 2) {
                Text("Pomodoro Mode")
                    .font(Constants.Fonts.body)
                    .foregroundStyle(Constants.Colors.primaryText)

                Text("Work/break cycles")
                    .font(Constants.Fonts.caption)
                    .foregroundStyle(Constants.Colors.secondaryText)
            }

            Spacer()

            Toggle("", isOn: $isEnabled)
                .labelsHidden()
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview("Pomodoro Controls") {
    VStack(spacing: 20) {
        PomodoroControls(
            currentPhase: .work,
            completedSessions: 2,
            totalSessions: 4,
            isActive: true
        )

        PomodoroControls(
            currentPhase: .shortBreak,
            completedSessions: 2,
            totalSessions: 4,
            isActive: true
        )

        PomodoroControls(
            currentPhase: .longBreak,
            completedSessions: 4,
            totalSessions: 4,
            isActive: true
        )
    }
    .padding()
}

#Preview("Toggle") {
    PomodoroModeToggle(isEnabled: .constant(true))
        .padding()
}
