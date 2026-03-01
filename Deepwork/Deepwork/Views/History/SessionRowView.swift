import SwiftUI

struct SessionRowView: View {
    let session: FocusSession

    var body: some View {
        HStack(spacing: Constants.Spacing.md) {
            completionIndicator

            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                HStack {
                    if !session.label.isEmpty {
                        Text(session.label)
                            .font(Constants.Fonts.headline)
                            .foregroundStyle(Constants.Colors.primaryText)
                    } else {
                        Text("Focus Session")
                            .font(Constants.Fonts.headline)
                            .foregroundStyle(Constants.Colors.secondaryText)
                    }

                    Spacer()

                    Text(TimeFormatters.formatDuration(session.actualMinutes))
                        .font(Constants.Fonts.body)
                        .foregroundStyle(Constants.Colors.primaryText)
                }

                HStack {
                    Text(TimeFormatters.formatTime(session.startTime))
                        .font(Constants.Fonts.caption)
                        .foregroundStyle(Constants.Colors.secondaryText)

                    if !session.wasCompleted {
                        Text("•")
                            .foregroundStyle(Constants.Colors.secondaryText)

                        Text("\(Int(session.completionPercentage * 100))% of \(TimeFormatters.formatDuration(session.plannedMinutes))")
                            .font(Constants.Fonts.caption)
                            .foregroundStyle(Constants.Colors.warning)
                    }
                }
            }
        }
        .padding(.vertical, Constants.Spacing.xs)
    }

    private var completionIndicator: some View {
        Circle()
            .fill(session.wasCompleted ? Constants.Colors.success : Constants.Colors.warning)
            .frame(width: 8, height: 8)
    }
}

#Preview {
    List {
        SessionRowView(session: FocusSession(
            plannedDuration: 1500,
            actualDuration: 1500,
            label: "Deep Work",
            wasCompleted: true
        ))

        SessionRowView(session: FocusSession(
            plannedDuration: 2700,
            actualDuration: 1800,
            label: "Study",
            wasCompleted: false
        ))

        SessionRowView(session: FocusSession(
            plannedDuration: 1500,
            actualDuration: 1500,
            label: "",
            wasCompleted: true
        ))
    }
}
