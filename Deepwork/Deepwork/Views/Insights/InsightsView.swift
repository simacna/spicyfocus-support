import SwiftUI
import SwiftData

struct InsightsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FocusSession.startTime, order: .reverse) private var sessions: [FocusSession]
    @EnvironmentObject private var userSettings: UserSettings

    @State private var selectedTimeRange: TimeRange = .week
    @State private var isLoading = true
    @State private var streakInfo: StreakInfo?
    @State private var personalRecords: PersonalRecords?
    @State private var monthProgress: [DayProgress] = []
    @State private var heatmapData: [[Int]] = []
    @State private var lastSessionCount = 0

    private let streakService = StreakService()

    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.Spacing.lg) {
                    if userSettings.hasProAccess {
                        if isLoading {
                            loadingView
                        } else {
                            proContent
                        }
                    } else {
                        proUpsell
                    }
                }
                .padding(Constants.Spacing.md)
            }
            .navigationTitle("Insights")
            .background(Constants.Colors.background)
            .task(id: sessions.count) {
                await loadInsightsData()
            }
            .onChange(of: userSettings.dailyGoalMinutes) { _, _ in
                Task { await loadInsightsData() }
            }
        }
    }

    private func loadInsightsData() async {
        guard userSettings.hasProAccess else {
            isLoading = false
            return
        }

        // Only recalculate if session count changed
        guard sessions.count != lastSessionCount || streakInfo == nil else {
            isLoading = false
            return
        }

        isLoading = true
        lastSessionCount = sessions.count

        // Calculate on background thread
        let goalMinutes = userSettings.dailyGoalMinutes
        let sessionsCopy = Array(sessions)

        let calculatedStreak = await Task.detached {
            StreakService().calculateStreakInfo(sessions: sessionsCopy, goalMinutes: goalMinutes)
        }.value

        let calculatedRecords = await Task.detached {
            StreakService().calculatePersonalRecords(sessions: sessionsCopy)
        }.value

        let calculatedProgress = await Task.detached {
            StreakService().getMonthProgress(sessions: sessionsCopy, goalMinutes: goalMinutes)
        }.value

        let calculatedHeatmap = await Task.detached {
            calculateHeatmapData(sessions: sessionsCopy)
        }.value

        await MainActor.run {
            self.streakInfo = calculatedStreak
            self.personalRecords = calculatedRecords
            self.monthProgress = calculatedProgress
            self.heatmapData = calculatedHeatmap
            self.isLoading = false
        }
    }

    private var loadingView: some View {
        VStack(spacing: Constants.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading insights...")
                .font(Constants.Fonts.body)
                .foregroundStyle(Constants.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
    }

    @ViewBuilder
    private var proContent: some View {
        if sessions.isEmpty {
            proEmptyState
        } else if let streak = streakInfo, let records = personalRecords {
            VStack(spacing: Constants.Spacing.lg) {
                // Streak and Goal Summary
                HStack(spacing: Constants.Spacing.md) {
                    StreakBadgeLarge(
                        streak: streak.currentStreak,
                        longestStreak: streak.longestStreak
                    )

                    GoalProgressView(
                        minutesFocused: streak.todayProgress.minutesFocused,
                        goalMinutes: userSettings.dailyGoalMinutes
                    )
                    .frame(width: 100, height: 120)
                }

                // Time Range Picker
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)

                // Stats for selected range
                timeRangeStats

                // Heatmap (using pre-calculated data)
                HeatmapViewCached(heatmapData: heatmapData)

                // Category Breakdown
                CategoryBreakdown(sessions: filteredSessions)

                // Personal Records
                PersonalRecordsCard(records: records)

                // Calendar (using pre-calculated data)
                StreakCalendarView(dayProgress: monthProgress)
            }
        }
    }

    private var proEmptyState: some View {
        VStack(spacing: Constants.Spacing.lg) {
            Spacer()

            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 72))
                .foregroundStyle(Constants.Colors.accent.opacity(0.8))

            VStack(spacing: Constants.Spacing.sm) {
                Text("Your insights await")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Constants.Colors.primaryText)

                Text("Complete focus sessions to unlock\nyour productivity patterns and streaks.")
                    .font(Constants.Fonts.body)
                    .foregroundStyle(Constants.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }

            // Goal setting prompt
            VStack(spacing: Constants.Spacing.sm) {
                Text("Daily Goal: \(TimeFormatters.formatDuration(userSettings.dailyGoalMinutes))")
                    .font(Constants.Fonts.headline)
                    .foregroundStyle(Constants.Colors.primaryText)

                Text("Reach your goal to start a streak")
                    .font(Constants.Fonts.caption)
                    .foregroundStyle(Constants.Colors.secondaryText)
            }
            .padding(Constants.Spacing.md)
            .background(Constants.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()
            Spacer()
        }
        .frame(minHeight: 400)
    }

    private var timeRangeStats: some View {
        let stats = calculateStats(for: selectedTimeRange)

        return HStack(spacing: Constants.Spacing.md) {
            StatCard(title: "Total Time", value: TimeFormatters.formatDuration(stats.totalMinutes), icon: "clock.fill")
            StatCard(title: "Sessions", value: "\(stats.sessionCount)", icon: "target")
            StatCard(title: "Avg/Day", value: TimeFormatters.formatDuration(stats.averagePerDay), icon: "chart.line.uptrend.xyaxis")
        }
    }

    private var filteredSessions: [FocusSession] {
        let calendar = Calendar.current
        let now = Date()

        switch selectedTimeRange {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            return sessions.filter { $0.startTime >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            return sessions.filter { $0.startTime >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
            return sessions.filter { $0.startTime >= yearAgo }
        }
    }

    private func calculateStats(for range: TimeRange) -> (totalMinutes: Int, sessionCount: Int, averagePerDay: Int) {
        let filtered = filteredSessions
        let totalSeconds = filtered.reduce(0) { $0 + $1.actualDuration }
        let totalMinutes = totalSeconds / 60

        let days: Int
        switch range {
        case .week: days = 7
        case .month: days = 30
        case .year: days = 365
        }

        let averagePerDay = days > 0 ? totalMinutes / days : 0

        return (totalMinutes, filtered.count, averagePerDay)
    }

    private var proUpsell: some View {
        VStack(spacing: Constants.Spacing.lg) {
            Image(systemName: "chart.bar.xaxis.ascending")
                .font(.system(size: 64))
                .foregroundStyle(Constants.Colors.accent)

            Text("Unlock Insights")
                .font(Constants.Fonts.title)
                .foregroundStyle(Constants.Colors.primaryText)

            Text("Track your streaks, view productivity trends, and discover your best focus hours with Spicy Focus Pro.")
                .font(Constants.Fonts.body)
                .foregroundStyle(Constants.Colors.secondaryText)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                FeatureRow(icon: "flame.fill", text: "Focus streaks & daily goals")
                FeatureRow(icon: "chart.xyaxis.line", text: "Productivity trends & patterns")
                FeatureRow(icon: "calendar", text: "GitHub-style focus calendar")
                FeatureRow(icon: "trophy.fill", text: "Personal records & achievements")
            }
            .padding(Constants.Spacing.md)

            NavigationLink {
                ProUpgradeView()
            } label: {
                Text("Upgrade to Pro - $4.99")
                    .font(Constants.Fonts.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(Constants.Spacing.md)
                    .background(Constants.Colors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(Constants.Spacing.xl)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: Constants.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Constants.Colors.accent)

            Text(value)
                .font(Constants.Fonts.headline)
                .foregroundStyle(Constants.Colors.primaryText)

            Text(title)
                .font(Constants.Fonts.caption)
                .foregroundStyle(Constants.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Constants.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Constants.Colors.accent)
                .frame(width: 24)

            Text(text)
                .font(Constants.Fonts.body)
                .foregroundStyle(Constants.Colors.primaryText)
        }
    }
}

struct PersonalRecordsCard: View {
    let records: PersonalRecords

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Personal Records")
                .font(Constants.Fonts.headline)
                .foregroundStyle(Constants.Colors.primaryText)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Constants.Spacing.md) {
                RecordItem(label: "Longest Session", value: TimeFormatters.formatDuration(records.longestSession), icon: "timer")
                RecordItem(label: "Best Day", value: TimeFormatters.formatDuration(records.mostProductiveDay), icon: "star.fill")
                RecordItem(label: "Longest Streak", value: "\(records.longestStreak) days", icon: "flame.fill")
                RecordItem(label: "Total Focus", value: TimeFormatters.formatDuration(records.totalFocusTime), icon: "clock.fill")
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct RecordItem: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: Constants.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Constants.Colors.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(Constants.Fonts.headline)
                    .foregroundStyle(Constants.Colors.primaryText)

                Text(label)
                    .font(Constants.Fonts.caption)
                    .foregroundStyle(Constants.Colors.secondaryText)
            }
        }
    }
}

// Helper function to calculate heatmap data
private func calculateHeatmapData(sessions: [FocusSession]) -> [[Int]] {
    let calendar = Calendar.current
    var data = Array(repeating: Array(repeating: 0, count: 24), count: 7)

    for session in sessions {
        let weekday = calendar.component(.weekday, from: session.startTime) - 1
        let hour = calendar.component(.hour, from: session.startTime)
        data[weekday][hour] += session.actualDuration / 60
    }

    return data
}

// Cached version of HeatmapView that uses pre-calculated data
struct HeatmapViewCached: View {
    let heatmapData: [[Int]]

    private let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

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
                                .fill(cellColor(for: heatmapData.indices.contains(dayIndex) && heatmapData[dayIndex].indices.contains(hourIndex) ? heatmapData[dayIndex][hourIndex] : 0))
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
    InsightsView()
        .environmentObject(UserSettings())
        .modelContainer(for: FocusSession.self, inMemory: true)
}
