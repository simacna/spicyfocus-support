import SwiftUI

struct EnergyCheckInSheet: View {
    let onSelect: (EnergyLevel, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var intention: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: Constants.Spacing.lg) {
                VStack(spacing: Constants.Spacing.sm) {
                    Text("How's your energy?")
                        .font(Constants.Fonts.title)
                        .foregroundStyle(Constants.Colors.primaryText)

                    Text("Tracking this helps you discover your best focus patterns.")
                        .font(Constants.Fonts.caption)
                        .foregroundStyle(Constants.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Constants.Spacing.md)

                VStack(spacing: Constants.Spacing.md) {
                    ForEach(EnergyLevel.ratable, id: \.self) { level in
                        Button {
                            onSelect(level, intention)
                            dismiss()
                        } label: {
                            HStack(spacing: Constants.Spacing.md) {
                                Text(level.emoji)
                                    .font(.system(size: 32))

                                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                                    Text(level.label)
                                        .font(Constants.Fonts.headline)
                                        .foregroundStyle(Constants.Colors.primaryText)

                                    Text(level.description)
                                        .font(Constants.Fonts.caption)
                                        .foregroundStyle(Constants.Colors.secondaryText)
                                }

                                Spacer()

                                Image(systemName: level.icon)
                                    .font(.system(size: 20))
                                    .foregroundStyle(level.color)
                            }
                            .padding(Constants.Spacing.md)
                            .background(Constants.Colors.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(.horizontal, Constants.Spacing.md)

                // Intention text field
                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                    Text("What's your ONE task?")
                        .font(Constants.Fonts.caption)
                        .foregroundStyle(Constants.Colors.secondaryText)

                    TextField("e.g., Write intro paragraph", text: $intention)
                        .textFieldStyle(.roundedBorder)
                        .font(Constants.Fonts.body)
                }
                .padding(.horizontal, Constants.Spacing.md)

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        onSelect(.notRated, intention)
                        dismiss()
                    }
                    .foregroundStyle(Constants.Colors.secondaryText)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    EnergyCheckInSheet { level, intention in
        print("Selected: \(level), intention: \(intention)")
    }
}
