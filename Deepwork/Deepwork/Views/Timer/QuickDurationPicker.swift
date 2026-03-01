import SwiftUI

struct QuickDurationPicker: View {
    @Binding var selectedDuration: Int
    let durations: [Int]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Spacing.sm) {
                ForEach(durations, id: \.self) { duration in
                    DurationChip(
                        duration: duration,
                        isSelected: selectedDuration == duration,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedDuration = duration
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, Constants.Spacing.md)
        }
    }
}

struct DurationChip: View {
    let duration: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(TimeFormatters.formatDuration(duration))
                .font(Constants.Fonts.headline)
                .foregroundStyle(isSelected ? .white : Constants.Colors.primaryText)
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.sm)
                .background(
                    isSelected ? Constants.Colors.accent : Constants.Colors.secondaryBackground
                )
                .clipShape(Capsule())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    VStack {
        QuickDurationPicker(
            selectedDuration: .constant(25),
            durations: [15, 25, 45, 60, 90]
        )
    }
    .padding()
}
