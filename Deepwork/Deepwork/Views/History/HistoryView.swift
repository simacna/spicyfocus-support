import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FocusSession.startTime, order: .reverse) private var sessions: [FocusSession]

    @State private var selectedSession: FocusSession?
    @State private var showingDetailSheet = false

    private var weekStats: WeekStats {
        StatsService.calculateWeekStats(sessions: sessions)
    }

    private var groupedSessions: [(date: Date, sessions: [FocusSession])] {
        StatsService.groupSessionsByDate(sessions)
    }

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    emptyState
                } else {
                    sessionsList
                }
            }
            .navigationTitle("History")
        }
        .sheet(isPresented: $showingDetailSheet) {
            if let session = selectedSession {
                SessionDetailSheet(
                    session: session,
                    onDelete: { deleteSession(session) }
                )
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Constants.Spacing.lg) {
            Spacer()

            Image(systemName: "brain.head.profile")
                .font(.system(size: 72))
                .foregroundStyle(Constants.Colors.accent.opacity(0.8))

            VStack(spacing: Constants.Spacing.sm) {
                Text("Ready to focus?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Constants.Colors.primaryText)

                Text("Your focus sessions will appear here.\nStart your first session to begin tracking.")
                    .font(Constants.Fonts.body)
                    .foregroundStyle(Constants.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: Constants.Spacing.sm) {
                Image(systemName: "arrow.down")
                    .font(.system(size: 20))
                    .foregroundStyle(Constants.Colors.accent)

                Text("Head to the Timer tab")
                    .font(Constants.Fonts.caption)
                    .foregroundStyle(Constants.Colors.secondaryText)
            }
            .padding(.top, Constants.Spacing.lg)

            Spacer()
            Spacer()
        }
        .padding(Constants.Spacing.xl)
    }

    private var sessionsList: some View {
        List {
            Section {
                WeekSummaryCard(stats: weekStats)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            ForEach(groupedSessions, id: \.date) { group in
                Section {
                    ForEach(group.sessions, id: \.id) { session in
                        SessionRowView(session: session)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedSession = session
                                showingDetailSheet = true
                            }
                    }
                    .onDelete { indexSet in
                        deleteSessionsInGroup(group.sessions, at: indexSet)
                    }
                } header: {
                    Text(TimeFormatters.formatRelativeDate(group.date))
                        .font(Constants.Fonts.headline)
                        .foregroundStyle(Constants.Colors.secondaryText)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func deleteSession(_ session: FocusSession) {
        modelContext.delete(session)
        showingDetailSheet = false
    }

    private func deleteSessionsInGroup(_ groupSessions: [FocusSession], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(groupSessions[index])
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: FocusSession.self, inMemory: true)
}
