import SwiftUI
import SwiftData

@main
struct SpicyFocusApp: App {
    let modelContainer: ModelContainer
    @StateObject private var timerService = TimerService()
    @StateObject private var userSettings = UserSettings()

    init() {
        do {
            modelContainer = try ModelContainer(for: FocusSession.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerService)
                .environmentObject(userSettings)
                .preferredColorScheme(userSettings.prefersDarkMode ? .dark : nil)
        }
        .modelContainer(modelContainer)
    }
}
