import SwiftUI

struct DurationPicker: View {
    @Binding var selectedDuration: Int
    @Binding var customDurations: [Int]

    @Environment(\.dismiss) private var dismiss

    @State private var editedDurations: [Int] = []
    @State private var newDuration: Int = 30
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                Section("Default Duration") {
                    Picker("Default", selection: $selectedDuration) {
                        ForEach(editedDurations, id: \.self) { duration in
                            Text(TimeFormatters.formatDuration(duration))
                                .tag(duration)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section {
                    ForEach(editedDurations, id: \.self) { duration in
                        HStack {
                            Text(TimeFormatters.formatDurationLong(duration))
                                .foregroundStyle(Constants.Colors.primaryText)

                            Spacer()

                            if duration == selectedDuration {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Constants.Colors.accent)
                            }
                        }
                    }
                    .onDelete(perform: deleteDurations)
                    .onMove(perform: moveDurations)

                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Add Duration", systemImage: "plus")
                    }
                } header: {
                    Text("Quick Duration Options")
                } footer: {
                    Text("These durations appear in the timer screen for quick selection.")
                }
            }
            .navigationTitle("Duration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        customDurations = editedDurations
                        if !editedDurations.contains(selectedDuration), let first = editedDurations.first {
                            selectedDuration = first
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }

                ToolbarItem(placement: .primaryAction) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddDurationSheet(
                    duration: $newDuration,
                    existingDurations: editedDurations,
                    onAdd: { duration in
                        editedDurations.append(duration)
                        editedDurations.sort()
                    }
                )
            }
            .onAppear {
                editedDurations = customDurations
            }
        }
    }

    private func deleteDurations(at offsets: IndexSet) {
        editedDurations.remove(atOffsets: offsets)
    }

    private func moveDurations(from source: IndexSet, to destination: Int) {
        editedDurations.move(fromOffsets: source, toOffset: destination)
    }
}

struct AddDurationSheet: View {
    @Binding var duration: Int
    let existingDurations: [Int]
    let onAdd: (Int) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var hours: Int = 0
    @State private var minutes: Int = 30

    private var totalMinutes: Int {
        hours * 60 + minutes
    }

    private var isValid: Bool {
        totalMinutes >= Constants.Timer.minDuration &&
        totalMinutes <= Constants.Timer.maxDuration &&
        !existingDurations.contains(totalMinutes)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Constants.Spacing.lg) {
                Text("Select Duration")
                    .font(Constants.Fonts.headline)
                    .foregroundStyle(Constants.Colors.primaryText)

                HStack(spacing: Constants.Spacing.md) {
                    VStack {
                        Picker("Hours", selection: $hours) {
                            ForEach(0..<4, id: \.self) { h in
                                Text("\(h)").tag(h)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)

                        Text("hours")
                            .font(Constants.Fonts.caption)
                            .foregroundStyle(Constants.Colors.secondaryText)
                    }

                    VStack {
                        Picker("Minutes", selection: $minutes) {
                            ForEach(Array(stride(from: 0, through: 55, by: 5)), id: \.self) { m in
                                Text("\(m)").tag(m)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)

                        Text("minutes")
                            .font(Constants.Fonts.caption)
                            .foregroundStyle(Constants.Colors.secondaryText)
                    }
                }

                Text(TimeFormatters.formatDurationLong(totalMinutes))
                    .font(Constants.Fonts.title)
                    .foregroundStyle(Constants.Colors.primaryText)

                if existingDurations.contains(totalMinutes) {
                    Text("This duration already exists")
                        .font(Constants.Fonts.caption)
                        .foregroundStyle(Constants.Colors.warning)
                }

                Spacer()
            }
            .padding(Constants.Spacing.lg)
            .navigationTitle("Add Duration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(totalMinutes)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    DurationPicker(
        selectedDuration: .constant(25),
        customDurations: .constant([15, 25, 45, 60, 90])
    )
}
