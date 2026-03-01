import SwiftUI

struct LabelsEditor: View {
    @Binding var labels: [String]

    @Environment(\.dismiss) private var dismiss

    @State private var editedLabels: [String] = []
    @State private var newLabel: String = ""
    @State private var showingAddField = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(editedLabels, id: \.self) { label in
                        Text(label)
                            .foregroundStyle(Constants.Colors.primaryText)
                    }
                    .onDelete(perform: deleteLabels)
                    .onMove(perform: moveLabels)

                    if showingAddField {
                        HStack {
                            TextField("Label name", text: $newLabel)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit {
                                    addLabel()
                                }

                            Button("Add") {
                                addLabel()
                            }
                            .disabled(newLabel.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    } else {
                        Button {
                            showingAddField = true
                        } label: {
                            Label("Add Label", systemImage: "plus")
                        }
                    }
                } header: {
                    Text("Quick Labels")
                } footer: {
                    Text("These labels appear when completing a session for quick categorization.")
                }

                Section {
                    Button {
                        editedLabels = Constants.Labels.defaults
                    } label: {
                        Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                            .foregroundStyle(Constants.Colors.warning)
                    }
                }
            }
            .navigationTitle("Labels")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        labels = editedLabels
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }

                ToolbarItem(placement: .primaryAction) {
                    EditButton()
                }
            }
            .onAppear {
                editedLabels = labels
            }
        }
    }

    private func deleteLabels(at offsets: IndexSet) {
        editedLabels.remove(atOffsets: offsets)
    }

    private func moveLabels(from source: IndexSet, to destination: Int) {
        editedLabels.move(fromOffsets: source, toOffset: destination)
    }

    private func addLabel() {
        let trimmed = newLabel.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !editedLabels.contains(trimmed) else { return }

        editedLabels.append(trimmed)
        newLabel = ""
        showingAddField = false
    }
}

#Preview {
    LabelsEditor(labels: .constant(["Deep Work", "Study", "Writing", "Coding"]))
}
