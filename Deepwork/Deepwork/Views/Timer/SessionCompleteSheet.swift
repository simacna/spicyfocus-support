import SwiftUI

struct SessionCompleteSheet: View {
    let plannedDuration: Int
    let actualDuration: Int
    let onSave: (String, String, Bool) -> Void
    let onDiscard: () -> Void
    var isStopwatch: Bool = false
    var intention: String = ""
    var preselectedLabel: String = ""

    @EnvironmentObject private var userSettings: UserSettings

    @State private var selectedLabel: String = ""
    @State private var customLabel: String = ""
    @State private var notes: String = ""
    @State private var showingCustomLabel = false
    @State private var intentionCompleted = false
    @State private var scienceNugget = Constants.ScienceNuggets.random()

    private var wasCompleted: Bool {
        isStopwatch || actualDuration >= plannedDuration
    }

    private var finalLabel: String {
        showingCustomLabel ? customLabel : selectedLabel
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.Spacing.lg) {
                    completionHeader

                    durationSummary

                    if !intention.isEmpty {
                        intentionSection
                    }

                    labelSection

                    notesSection
                }
                .padding(Constants.Spacing.md)
            }
            .navigationTitle("Session Complete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Discard") {
                        onDiscard()
                    }
                    .foregroundStyle(Constants.Colors.secondaryText)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(finalLabel, notes, intentionCompleted)
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            if !preselectedLabel.isEmpty {
                selectedLabel = preselectedLabel
            } else if let firstLabel = userSettings.quickLabels.first {
                selectedLabel = firstLabel
            }
        }
    }

    private var completionHeader: some View {
        VStack(spacing: Constants.Spacing.sm) {
            Image(systemName: wasCompleted ? "checkmark.circle.fill" : "clock.badge.checkmark.fill")
                .font(.system(size: 56))
                .foregroundStyle(wasCompleted ? Constants.Colors.success : Constants.Colors.warning)

            Text(wasCompleted ? "Great work!" : "Every minute counts")
                .font(Constants.Fonts.title)
                .foregroundStyle(Constants.Colors.primaryText)

            Text(scienceNugget)
                .font(Constants.Fonts.caption)
                .foregroundStyle(Constants.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.Spacing.md)
        }
        .padding(.top, Constants.Spacing.md)
    }

    private var durationSummary: some View {
        HStack(spacing: Constants.Spacing.xl) {
            VStack(spacing: Constants.Spacing.xs) {
                Text(TimeFormatters.formatDuration(actualDuration / 60))
                    .font(Constants.Fonts.title)
                    .foregroundStyle(Constants.Colors.primaryText)
                Text(isStopwatch ? "Total Time" : "Focused")
                    .font(Constants.Fonts.caption)
                    .foregroundStyle(Constants.Colors.secondaryText)
            }

            if !wasCompleted && !isStopwatch {
                VStack(spacing: Constants.Spacing.xs) {
                    Text(TimeFormatters.formatDuration(plannedDuration / 60))
                        .font(Constants.Fonts.title)
                        .foregroundStyle(Constants.Colors.secondaryText)
                    Text("Planned")
                        .font(Constants.Fonts.caption)
                        .foregroundStyle(Constants.Colors.secondaryText)
                }
            }
        }
        .padding(.vertical, Constants.Spacing.md)
    }

    private var labelSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Label")
                .font(Constants.Fonts.headline)
                .foregroundStyle(Constants.Colors.primaryText)

            if showingCustomLabel {
                HStack {
                    TextField("Enter label", text: $customLabel)
                        .textFieldStyle(.roundedBorder)

                    Button("Cancel") {
                        showingCustomLabel = false
                        customLabel = ""
                    }
                    .foregroundStyle(Constants.Colors.secondaryText)
                }
            } else {
                FlowLayout(spacing: Constants.Spacing.sm) {
                    ForEach(userSettings.quickLabels, id: \.self) { label in
                        LabelChip(
                            label: label,
                            isSelected: selectedLabel == label,
                            action: { selectedLabel = label }
                        )
                    }

                    Button {
                        showingCustomLabel = true
                    } label: {
                        HStack(spacing: Constants.Spacing.xs) {
                            Image(systemName: "plus")
                            Text("Custom")
                        }
                        .font(Constants.Fonts.body)
                        .foregroundStyle(Constants.Colors.secondaryText)
                        .padding(.horizontal, Constants.Spacing.md)
                        .padding(.vertical, Constants.Spacing.sm)
                        .background(Constants.Colors.secondaryBackground)
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var intentionSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Your Intention")
                .font(Constants.Fonts.headline)
                .foregroundStyle(Constants.Colors.primaryText)

            Button {
                intentionCompleted.toggle()
            } label: {
                HStack(spacing: Constants.Spacing.md) {
                    Image(systemName: intentionCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundStyle(intentionCompleted ? Constants.Colors.success : Constants.Colors.secondaryText)

                    Text(intention)
                        .font(Constants.Fonts.body)
                        .foregroundStyle(Constants.Colors.primaryText)
                        .strikethrough(intentionCompleted)
                        .multilineTextAlignment(.leading)

                    Spacer()
                }
                .padding(Constants.Spacing.md)
                .background(Constants.Colors.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Notes (optional)")
                .font(Constants.Fonts.headline)
                .foregroundStyle(Constants.Colors.primaryText)

            TextField("What did you work on?", text: $notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
        }
    }
}

struct LabelChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(Constants.Fonts.body)
                .foregroundStyle(isSelected ? .white : Constants.Colors.primaryText)
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.sm)
                .background(isSelected ? Constants.Colors.accent : Constants.Colors.secondaryBackground)
                .clipShape(Capsule())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )

        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            ), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

#Preview {
    SessionCompleteSheet(
        plannedDuration: 1500,
        actualDuration: 1500,
        onSave: { _, _, _ in },
        onDiscard: {},
        intention: "Write intro paragraph"
    )
    .environmentObject(UserSettings())
}
