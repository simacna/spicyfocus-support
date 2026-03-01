import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var userSettings: UserSettings
    @State private var selectedTab = 0
    @State private var showingOnboarding = false

    var body: some View {
        TabView(selection: $selectedTab) {
            TimerView()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(1)

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.xyaxis.line")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(3)
        }
        .tint(Constants.Colors.accent)
        .onAppear {
            if !userSettings.hasCompletedOnboarding {
                showingOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView(isPresented: $showingOnboarding)
                .onDisappear {
                    userSettings.hasCompletedOnboarding = true
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TimerService())
        .environmentObject(UserSettings())
}
