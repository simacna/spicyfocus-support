import Foundation
import WidgetKit

class WidgetService {
    static let shared = WidgetService()

    private let suiteName = "group.com.hyggejournal.app"
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    private init() {}

    func updateWidgetData(
        streakCount: Int,
        todayEntries: [String],
        weekProgress: [Bool],
        hasTodayEntry: Bool
    ) {
        sharedDefaults?.set(streakCount, forKey: "widget_streakCount")
        sharedDefaults?.set(todayEntries, forKey: "widget_todayEntries")
        sharedDefaults?.set(weekProgress, forKey: "widget_weekProgress")
        sharedDefaults?.set(hasTodayEntry, forKey: "widget_hasTodayEntry")

        // Tell WidgetKit to refresh
        WidgetCenter.shared.reloadAllTimelines()
    }

    func updateFromSettings(_ settings: UserSettings, todayEntries: [String] = [], weekProgress: [Bool] = []) {
        var progress = weekProgress
        if progress.isEmpty {
            progress = Array(repeating: false, count: 7)
        }

        updateWidgetData(
            streakCount: settings.streakCount,
            todayEntries: todayEntries,
            weekProgress: progress,
            hasTodayEntry: !todayEntries.isEmpty
        )
    }
}
