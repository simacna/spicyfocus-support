import SwiftUI

struct SessionDetailSheet: View {
    @Bindable var session: FocusSession
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userSettings: UserSettings

    @State private var editedLabel: String = ""
    @State private var editedNotes: String = ""
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                Section("Session Details") {
                    LabeledContent("Date") {
                        Text(TimeFormatters.formatRelativeDate(session.startTime))
                    }

                    LabeledContent("Time") {
                        Text("\(TimeFormatters.formatTime(session.startTime)) - \(TimeFormatters.formatTime(session.endTime))")
                    }

                    LabeledContent("Duration") {
                        Text(TimeFormatters.formatDurationLong(session.actualMinutes))
                    }

                    LabeledContent("Status") {
                        HStack(spacing: Constants.Spacing.xs) {
                            Circle()
                                .fill(session.wasCompleted ? Constants.Colors.success : Constants.Colors.warning)
                                .frame(width: 8, height: 8)
                            Text(session.wasCompleted ? "Completed" : "Ended Early")
                        }
                    }

                    if !session.wasCompleted {
                        LabeledContent("Planned") {
                            Text(TimeFormatters.formatDurationLong(session.plannedMinutes))
                        }

                        LabeledContent("Completion") {
                            Text("\(Int(session.completionPercentage * 100))%")
                        }
                    }
                }

                Section("Label") {
                    TextField("Label", text: $editedLabel)
                        .onChange(of: editedLabel) { _, newValue in
                            session.label = newValue
                        }

                    if !userSettings.quickLabels.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Constants.Spacing.sm) {
                                ForEach(userSettings.quickLabels, id: \.self) { label in
                                    Button(label) {
                                        editedLabel = label
                                    }
                                    .font(Constants.Fonts.caption)
                                    .padding(.horizontal, Constants.Spacing.sm)
                                    .padding(.vertical, Constants.Spacing.xs)
                                    .background(
                                        editedLabel == label
                                            ? Constants.Colors.accent
                                            : Constants.Colors.secondaryBackground
                                    )
                                    .foregroundStyle(
                                        editedLabel == label
                                            ? .white
                                            : Constants.Colors.primaryText
                                    )
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets(
                            top: Constants.Spacing.sm,
                            leading: Constants.Spacing.md,
                            bottom: Constants.Spacing.sm,
                            trailing: Constants.Spacing.md
                        ))
                    }
                }

                Section("Notes") {
                    TextField("Add notes...", text: $editedNotes, axis: .vertical)
                        .lineLimit(3...10)
                        .onChange(of: editedNotes) { _, newValue in
                            session.notes = newValue
                        }
                }

                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Session")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Delete this session?",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    onDelete()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
            .onAppear {
                editedLabel = session.label
                editedNotes = session.notes
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    SessionDetailSheet(
        session: FocusSession.preview,
        onDelete: {}
    )
    .environmentObject(UserSettings())
}
