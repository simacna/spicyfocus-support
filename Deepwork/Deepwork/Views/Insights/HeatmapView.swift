import SwiftUI

struct HeatmapView: View {
    let sessions: [FocusSession]

    private let hours = Array(0..<24)
    private let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let calendar = Calendar.current

    private var heatmapData: [[Int]] {
        var data = Array(repeating: Array(repeating: 0, count: 24), count: 7)

        for session in sessions {
            let weekday = calendar.component(.weekday, from: session.startTime) - 1
            let hour = calendar.component(.hour, from: session.startTime)
            data[weekday][hour] += session.actualDuration / 60
        }

        return data
    }

    private var maxMinutes: Int {
        heatmapData.flatMap { $0 }.max() ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Best Focus Hours")
                .font(Constants.Fonts.headline)
                .foregroundStyle(Constants.Colors.primaryText)

            VStack(spacing: 2) {
                // Hour labels
                HStack(spacing: 2) {
                    Text("")
                        .frame(width: 32)

                    ForEach([0, 6, 12, 18], id: \.self) { hour in
                        Text(formatHour(hour))
                            .font(.system(size: 9))
                            .foregroundStyle(Constants.Colors.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                // Heatmap grid
                ForEach(0..<7, id: \.self) { dayIndex in
                    HStack(spacing: 2) {
                        Text(days[dayIndex])
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Constants.Colors.secondaryText)
                            .frame(width: 32, alignment: .trailing)

                        ForEach(0..<24, id: \.self) { hourIndex in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(cellColor(for: heatmapData[dayIndex][hourIndex]))
                                .frame(height: 16)
                        }
                    }
                }
            }

            // Legend
            HStack(spacing: Constants.Spacing.md) {
                Spacer()
                Text("Less")
                    .font(.system(size: 10))
                    .foregroundStyle(Constants.Colors.secondaryText)

                HStack(spacing: 2) {
                    ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { intensity in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(intensityColor(intensity))
                            .frame(width: 12, height: 12)
                    }
                }

                Text("More")
                    .font(.system(size: 10))
                    .foregroundStyle(Constants.Colors.secondaryText)
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func formatHour(_ hour: Int) -> String {
        if hour == 0 { return "12a" }
        if hour == 12 { return "12p" }
        if hour < 12 { return "\(hour)a" }
        return "\(hour - 12)p"
    }

    private func cellColor(for minutes: Int) -> Color {
        guard minutes > 0, maxMinutes > 0 else {
            return Constants.Colors.secondaryText.opacity(0.1)
        }
        let intensity = Double(minutes) / Double(maxMinutes)
        return intensityColor(intensity)
    }

    private func intensityColor(_ intensity: Double) -> Color {
        if intensity == 0 {
            return Constants.Colors.secondaryText.opacity(0.1)
        }
        return Constants.Colors.accent.opacity(0.2 + intensity * 0.8)
    }
}

#Preview {
    let calendar = Calendar.current
    let now = Date()

    let sampleSessions: [FocusSession] = (0..<50).map { i in
        let daysAgo = Int.random(in: 0...30)
        let hour = [9, 10, 14, 15, 16, 21, 22].randomElement()!
        var components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: -daysAgo, to: now)!)
        components.hour = hour
        components.minute = 0
        let startTime = calendar.date(from: components)!
        let duration = [25, 45, 60].randomElement()! * 60

        return FocusSession(
            startTime: startTime,
            endTime: startTime.addingTimeInterval(TimeInterval(duration)),
            plannedDuration: duration,
            actualDuration: duration,
            label: "Work",
            wasCompleted: true
        )
    }

    return HeatmapView(sessions: sampleSessions)
        .padding()
}
