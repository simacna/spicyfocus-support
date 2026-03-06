import WidgetKit
import SwiftUI
import ActivityKit

// MARK: - Widget Data

struct WidgetData {
    let currentStreak: Int
    let todayMinutes: Int
    let goalMinutes: Int
    let weeklyMinutes: [Int] // 7 days, index 0 = Sunday

    var goalProgress: Double {
        guard goalMinutes > 0 else { return 0 }
        return min(Double(todayMinutes) / Double(goalMinutes), 1.0)
    }

    var goalMet: Bool {
        todayMinutes >= goalMinutes
    }

    static let placeholder = WidgetData(
        currentStreak: 5,
        todayMinutes: 45,
        goalMinutes: 120,
        weeklyMinutes: [60, 90, 120, 45, 80, 0, 30]
    )

    static func load() -> WidgetData {
        let defaults = UserDefaults(suiteName: "group.com.deepwork.app") ?? UserDefaults.standard

        return WidgetData(
            currentStreak: defaults.integer(forKey: "widget.currentStreak"),
            todayMinutes: defaults.integer(forKey: "widget.todayMinutes"),
            goalMinutes: defaults.integer(forKey: "widget.goalMinutes"),
            weeklyMinutes: defaults.array(forKey: "widget.weeklyMinutes") as? [Int] ?? Array(repeating: 0, count: 7)
        )
    }
}

// MARK: - Timeline Provider

struct DeepworkTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> DeepworkEntry {
        DeepworkEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (DeepworkEntry) -> Void) {
        let entry = DeepworkEntry(date: Date(), data: WidgetData.load())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DeepworkEntry>) -> Void) {
        let entry = DeepworkEntry(date: Date(), data: WidgetData.load())

        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct DeepworkEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: DeepworkEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Streak
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("\(entry.data.currentStreak)")
                    .font(.system(size: 24, weight: .bold))
            }

            Spacer()

            // Today's progress
            VStack(alignment: .leading, spacing: 4) {
                Text("Today")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                ProgressView(value: entry.data.goalProgress)
                    .tint(entry.data.goalMet ? .green : .orange)

                Text("\(entry.data.todayMinutes)/\(entry.data.goalMinutes) min")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: DeepworkEntry

    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        HStack(spacing: 16) {
            // Left: Streak & Today
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(entry.data.currentStreak) day streak")
                        .font(.subheadline.weight(.semibold))
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Focus")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(formatDuration(entry.data.todayMinutes))
                        .font(.title2.weight(.bold))

                    ProgressView(value: entry.data.goalProgress)
                        .tint(entry.data.goalMet ? .green : .orange)
                }
            }

            Divider()

            // Right: Week chart
            VStack(spacing: 4) {
                Text("This Week")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(0..<7, id: \.self) { index in
                        VStack(spacing: 2) {
                            barView(for: entry.data.weeklyMinutes[index])
                            Text(dayLabels[index])
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private func barView(for minutes: Int) -> some View {
        let maxHeight: CGFloat = 40
        let height = min(CGFloat(minutes) / CGFloat(max(entry.data.goalMinutes, 1)) * maxHeight, maxHeight)

        return RoundedRectangle(cornerRadius: 2)
            .fill(minutes >= entry.data.goalMinutes ? Color.green : Color.orange)
            .frame(width: 12, height: max(height, 4))
    }

    private func formatDuration(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
        return "\(minutes)m"
    }
}

// MARK: - Large Widget View

struct LargeWidgetView: View {
    let entry: DeepworkEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Deepwork")
                        .font(.headline)
                    Text(entry.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(entry.data.currentStreak)")
                        .font(.title2.weight(.bold))
                }
            }

            Divider()

            // Today's progress
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Focus")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(formatDuration(entry.data.todayMinutes))
                        .font(.largeTitle.weight(.bold))

                    ProgressView(value: entry.data.goalProgress)
                        .tint(entry.data.goalMet ? .green : .orange)

                    Text("Goal: \(formatDuration(entry.data.goalMinutes))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Goal status
                if entry.data.goalMet {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.green)
                } else {
                    CircularProgressView(progress: entry.data.goalProgress)
                        .frame(width: 60, height: 60)
                }
            }

            Divider()

            // Week overview
            WeekOverviewView(weeklyMinutes: entry.data.weeklyMinutes, goalMinutes: entry.data.goalMinutes)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private func formatDuration(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
        return "\(minutes)m"
    }
}

struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.3), lineWidth: 6)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(Int(progress * 100))%")
                .font(.caption.weight(.semibold))
        }
    }
}

struct WeekOverviewView: View {
    let weeklyMinutes: [Int]
    let goalMinutes: Int

    private let dayLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This Week")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 4) {
                        barView(for: weeklyMinutes[index])
                        Text(dayLabels[index])
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func barView(for minutes: Int) -> some View {
        let maxHeight: CGFloat = 50
        let height = min(CGFloat(minutes) / CGFloat(max(goalMinutes, 1)) * maxHeight, maxHeight)

        return RoundedRectangle(cornerRadius: 3)
            .fill(minutes >= goalMinutes ? Color.green : Color.orange)
            .frame(height: max(height, 6))
    }
}

// MARK: - Widget Configuration

struct DeepworkWidget: Widget {
    let kind: String = "DeepworkWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DeepworkTimelineProvider()) { entry in
            DeepworkWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Focus Stats")
        .description("Track your focus streaks and daily progress.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct DeepworkWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: DeepworkEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Live Activity

struct FocusTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusTimerAttributes.self) { context in
            // Lock screen banner
            HStack(spacing: 16) {
                // Timer ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                        .frame(width: 50, height: 50)

                    if !context.state.isPaused {
                        Circle()
                            .trim(from: 0, to: timerProgress(endTime: context.state.endTime, planned: context.attributes.plannedDuration))
                            .stroke(Color.orange, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 50, height: 50)
                    }

                    Image(systemName: context.state.isPaused ? "pause.fill" : "flame.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(context.state.isPaused ? .gray : .orange)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.state.label)
                        .font(.headline)
                        .foregroundStyle(.white)

                    if context.state.isPaused {
                        Text("Paused")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    } else {
                        Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                    }
                }

                Spacer()

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 24))
                    .foregroundStyle(.orange.opacity(0.6))
            }
            .padding(16)
            .activityBackgroundTint(.black)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 4) {
                        Text(context.state.label)
                            .font(.headline)

                        if context.state.isPaused {
                            Text("Paused")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        } else {
                            Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .foregroundStyle(.orange)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if !context.state.isPaused {
                        timerRingView(endTime: context.state.endTime, planned: context.attributes.plannedDuration)
                            .frame(width: 36, height: 36)
                    }
                }
            } compactLeading: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
            } compactTrailing: {
                if context.state.isPaused {
                    Image(systemName: "pause.fill")
                        .foregroundStyle(.gray)
                } else {
                    Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.orange)
                        .frame(width: 50)
                }
            } minimal: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
            }
        }
    }

    private func timerProgress(endTime: Date, planned: Int) -> Double {
        let remaining = endTime.timeIntervalSinceNow
        guard planned > 0, remaining > 0 else { return 1.0 }
        return 1.0 - (remaining / Double(planned))
    }

    private func timerRingView(endTime: Date, planned: Int) -> some View {
        let progress = timerProgress(endTime: endTime, planned: planned)
        return ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 3)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - Widget Bundle

@main
struct DeepworkWidgetBundle: WidgetBundle {
    var body: some Widget {
        DeepworkWidget()
        FocusTimerLiveActivity()
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    DeepworkWidget()
} timeline: {
    DeepworkEntry(date: Date(), data: .placeholder)
}

#Preview("Medium", as: .systemMedium) {
    DeepworkWidget()
} timeline: {
    DeepworkEntry(date: Date(), data: .placeholder)
}

#Preview("Large", as: .systemLarge) {
    DeepworkWidget()
} timeline: {
    DeepworkEntry(date: Date(), data: .placeholder)
}
