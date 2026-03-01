import SwiftUI

struct GoalProgressView: View {
    let minutesFocused: Int
    let goalMinutes: Int
    let showLabel: Bool

    init(minutesFocused: Int, goalMinutes: Int, showLabel: Bool = true) {
        self.minutesFocused = minutesFocused
        self.goalMinutes = goalMinutes
        self.showLabel = showLabel
    }

    private var progress: Double {
        guard goalMinutes > 0 else { return 0 }
        return min(Double(minutesFocused) / Double(goalMinutes), 1.0)
    }

    private var isGoalMet: Bool {
        minutesFocused >= goalMinutes
    }

    var body: some View {
        VStack(spacing: Constants.Spacing.sm) {
            ZStack {
                Circle()
                    .stroke(
                        Constants.Colors.secondaryBackground,
                        lineWidth: 10
                    )

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        isGoalMet ? Constants.Colors.success : Constants.Colors.accent,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)

                VStack(spacing: 2) {
                    if isGoalMet {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Constants.Colors.success)
                    } else {
                        Text(TimeFormatters.formatDuration(minutesFocused))
                            .font(Constants.Fonts.headline)
                            .foregroundStyle(Constants.Colors.primaryText)

                        Text("of \(TimeFormatters.formatDuration(goalMinutes))")
                            .font(Constants.Fonts.caption)
                            .foregroundStyle(Constants.Colors.secondaryText)
                    }
                }
            }

            if showLabel {
                Text(isGoalMet ? "Goal reached!" : "Today's goal")
                    .font(Constants.Fonts.caption)
                    .foregroundStyle(isGoalMet ? Constants.Colors.success : Constants.Colors.secondaryText)
            }
        }
    }
}

struct GoalProgressBar: View {
    let minutesFocused: Int
    let goalMinutes: Int

    private var progress: Double {
        guard goalMinutes > 0 else { return 0 }
        return min(Double(minutesFocused) / Double(goalMinutes), 1.0)
    }

    private var isGoalMet: Bool {
        minutesFocused >= goalMinutes
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            HStack {
                Text("Today's Progress")
                    .font(Constants.Fonts.caption)
                    .foregroundStyle(Constants.Colors.secondaryText)

                Spacer()

                Text("\(TimeFormatters.formatDuration(minutesFocused)) / \(TimeFormatters.formatDuration(goalMinutes))")
                    .font(Constants.Fonts.caption)
                    .foregroundStyle(Constants.Colors.primaryText)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Constants.Colors.secondaryBackground)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(isGoalMet ? Constants.Colors.success : Constants.Colors.accent)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 8)
        }
    }
}

#Preview("Goal Progress Ring") {
    HStack(spacing: 20) {
        GoalProgressView(minutesFocused: 45, goalMinutes: 120)
            .frame(width: 100, height: 120)

        GoalProgressView(minutesFocused: 120, goalMinutes: 120)
            .frame(width: 100, height: 120)

        GoalProgressView(minutesFocused: 150, goalMinutes: 120)
            .frame(width: 100, height: 120)
    }
    .padding()
}

#Preview("Goal Progress Bar") {
    VStack(spacing: 20) {
        GoalProgressBar(minutesFocused: 45, goalMinutes: 120)
        GoalProgressBar(minutesFocused: 120, goalMinutes: 120)
    }
    .padding()
}
