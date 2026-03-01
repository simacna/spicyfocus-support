import SwiftUI

struct StreakCalendarView: View {
    let dayProgress: [DayProgress]
    let weeksToShow: Int

    @State private var calendarDays: [DayProgress] = []

    init(dayProgress: [DayProgress], weeksToShow: Int = 12) {
        self.dayProgress = dayProgress
        self.weeksToShow = weeksToShow
    }

    private let columns = 7

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Focus Calendar")
                .font(Constants.Fonts.headline)
                .foregroundStyle(Constants.Colors.primaryText)

            dayLabels

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: columns), spacing: 4) {
                ForEach(calendarDays, id: \.date) { day in
                    CalendarDayCell(progress: day)
                }
            }

            legend
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .task(id: dayProgress.count) {
            calendarDays = buildCalendarDays()
        }
    }

    private var dayLabels: some View {
        HStack(spacing: 4) {
            ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                Text(day)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Constants.Colors.secondaryText)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func buildCalendarDays() -> [DayProgress] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -(weeksToShow * 7 - 1), to: today) else {
            return []
        }

        let adjustedStart: Date
        let weekday = calendar.component(.weekday, from: startDate)
        if weekday != 1 {
            adjustedStart = calendar.date(byAdding: .day, value: -(weekday - 1), to: startDate) ?? startDate
        } else {
            adjustedStart = startDate
        }

        var days: [DayProgress] = []
        var currentDate = adjustedStart

        let progressByDate = Dictionary(uniqueKeysWithValues: dayProgress.map { (calendar.startOfDay(for: $0.date), $0) })

        while currentDate <= today {
            if let progress = progressByDate[currentDate] {
                days.append(progress)
            } else {
                days.append(DayProgress(
                    date: currentDate,
                    minutesFocused: 0,
                    goalMinutes: 0,
                    sessionCount: 0
                ))
            }
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return days
    }

    private var legend: some View {
        HStack(spacing: Constants.Spacing.md) {
            Spacer()
            Text("Less")
                .font(.system(size: 10))
                .foregroundStyle(Constants.Colors.secondaryText)

            HStack(spacing: 2) {
                ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { intensity in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(cellColor(for: intensity))
                        .frame(width: 12, height: 12)
                }
            }

            Text("More")
                .font(.system(size: 10))
                .foregroundStyle(Constants.Colors.secondaryText)
        }
    }

    private func cellColor(for intensity: Double) -> Color {
        if intensity == 0 {
            return Constants.Colors.secondaryText.opacity(0.1)
        }
        return Constants.Colors.accent.opacity(0.3 + intensity * 0.7)
    }
}

struct CalendarDayCell: View {
    let progress: DayProgress

    private var intensity: Double {
        progress.progressPercentage
    }

    private var cellColor: Color {
        if progress.goalMinutes == 0 && progress.minutesFocused == 0 {
            return Constants.Colors.secondaryText.opacity(0.1)
        }
        if progress.goalMet {
            return Constants.Colors.success.opacity(0.8)
        }
        if progress.minutesFocused > 0 {
            return Constants.Colors.accent.opacity(0.3 + intensity * 0.5)
        }
        return Constants.Colors.secondaryText.opacity(0.1)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(cellColor)
            .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    let calendar = Calendar.current
    let today = Date()
    let sampleProgress: [DayProgress] = (0..<84).map { daysAgo in
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
        let minutes = [0, 30, 60, 90, 120, 150].randomElement()!
        return DayProgress(
            date: date,
            minutesFocused: minutes,
            goalMinutes: 120,
            sessionCount: minutes > 0 ? Int.random(in: 1...4) : 0
        )
    }

    return StreakCalendarView(dayProgress: sampleProgress)
        .padding()
}
