import SwiftUI

struct WeekSummaryCard: View {
    let stats: WeekStats

    var body: some View {
        VStack(spacing: Constants.Spacing.md) {
            HStack {
                Text("This Week")
                    .font(Constants.Fonts.headline)
                    .foregroundStyle(Constants.Colors.primaryText)

                Spacer()

                Text(TimeFormatters.formatWeekRange(containing: Date()))
                    .font(Constants.Fonts.caption)
                    .foregroundStyle(Constants.Colors.secondaryText)
            }

            HStack(spacing: Constants.Spacing.lg) {
                StatItem(
                    value: TimeFormatters.formatDuration(stats.totalMinutes),
                    label: "Total"
                )

                StatItem(
                    value: "\(stats.sessionCount)",
                    label: "Sessions"
                )

                StatItem(
                    value: "\(Int(stats.completionRate * 100))%",
                    label: "Completed"
                )
            }

            WeekBarChart(dailyStats: stats.dailyStats)
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, Constants.Spacing.md)
        .padding(.vertical, Constants.Spacing.sm)
    }
}

struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: Constants.Spacing.xs) {
            Text(value)
                .font(Constants.Fonts.title)
                .foregroundStyle(Constants.Colors.primaryText)

            Text(label)
                .font(Constants.Fonts.caption)
                .foregroundStyle(Constants.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

struct WeekBarChart: View {
    let dailyStats: [DayStats]

    private var maxMinutes: Int {
        max(dailyStats.map(\.totalMinutes).max() ?? 0, 1)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: Constants.Spacing.sm) {
            ForEach(Array(dailyStats.enumerated()), id: \.offset) { index, dayStats in
                VStack(spacing: Constants.Spacing.xs) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor(for: dayStats))
                        .frame(height: barHeight(for: dayStats))

                    Text(dayLabel(for: index))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Constants.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 80)
    }

    private func barHeight(for dayStats: DayStats) -> CGFloat {
        guard dayStats.totalMinutes > 0 else { return 4 }
        let ratio = CGFloat(dayStats.totalMinutes) / CGFloat(maxMinutes)
        return max(ratio * 50, 4)
    }

    private func barColor(for dayStats: DayStats) -> Color {
        if dayStats.totalMinutes == 0 {
            return Constants.Colors.secondaryText.opacity(0.2)
        }
        return Constants.Colors.accent
    }

    private func dayLabel(for index: Int) -> String {
        let days = ["S", "M", "T", "W", "T", "F", "S"]
        return days[index % 7]
    }
}

#Preview {
    WeekSummaryCard(stats: WeekStats(
        weekStart: Date(),
        weekEnd: Date(),
        totalMinutes: 320,
        sessionCount: 12,
        completedCount: 10,
        averageMinutesPerDay: 45,
        dailyStats: [
            DayStats(date: Date(), totalMinutes: 45, sessionCount: 2, completedCount: 2),
            DayStats(date: Date(), totalMinutes: 60, sessionCount: 3, completedCount: 2),
            DayStats(date: Date(), totalMinutes: 30, sessionCount: 1, completedCount: 1),
            DayStats(date: Date(), totalMinutes: 90, sessionCount: 4, completedCount: 4),
            DayStats(date: Date(), totalMinutes: 0, sessionCount: 0, completedCount: 0),
            DayStats(date: Date(), totalMinutes: 75, sessionCount: 2, completedCount: 1),
            DayStats(date: Date(), totalMinutes: 20, sessionCount: 1, completedCount: 0)
        ]
    ))
    .padding()
}
