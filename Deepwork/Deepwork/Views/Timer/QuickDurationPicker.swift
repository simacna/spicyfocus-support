import SwiftUI

struct QuickDurationPicker: View {
    @Binding var selectedDuration: Int
    let durations: [Int]
    var recommendedDuration: Int? = nil
    var recommendationConfidence: RecommendationConfidence? = nil
    var sessionCount: Int = 0
    var onManualSelect: (() -> Void)? = nil

    @State private var showingCustomPicker = false

    private var isCustomSelected: Bool {
        !durations.contains(selectedDuration)
    }

    var body: some View {
        VStack(spacing: Constants.Spacing.sm) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.sm) {
                    ForEach(durations, id: \.self) { duration in
                        DurationChip(
                            duration: duration,
                            isSelected: selectedDuration == duration,
                            isRecommended: duration == recommendedDuration,
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedDuration = duration
                                }
                                if duration != recommendedDuration {
                                    onManualSelect?()
                                }
                            }
                        )
                    }

                    // Custom duration chip
                    Button {
                        showingCustomPicker = true
                    } label: {
                        Text(isCustomSelected ? TimeFormatters.formatDuration(selectedDuration) : "Custom")
                            .font(Constants.Fonts.headline)
                            .foregroundStyle(isCustomSelected ? .white : Constants.Colors.primaryText)
                            .padding(.horizontal, Constants.Spacing.md)
                            .padding(.vertical, Constants.Spacing.sm)
                            .background(
                                isCustomSelected ? Constants.Colors.accent : Constants.Colors.secondaryBackground
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.horizontal, Constants.Spacing.md)
            }
            .sheet(isPresented: $showingCustomPicker) {
                CustomDurationPicker(selectedDuration: $selectedDuration)
            }

            // Cold start calibration progress
            if recommendationConfidence == .coldStart {
                HStack(spacing: Constants.Spacing.xs) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 10))
                    Text("Learning your patterns")
                        .font(.system(size: 11, weight: .regular))
                    Text("(\(sessionCount)/\(Constants.Recommendation.coldStartThreshold))")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundStyle(Constants.Colors.secondaryText)
                .padding(.top, Constants.Spacing.xs)
            }
        }
    }
}

struct CustomDurationPicker: View {
    @Binding var selectedDuration: Int
    @Environment(\.dismiss) private var dismiss

    @State private var hours: Int = 0
    @State private var minutes: Int = 25

    var body: some View {
        NavigationStack {
            VStack(spacing: Constants.Spacing.lg) {
                Text("Set Focus Time")
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
                            ForEach(0..<60, id: \.self) { m in
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

                let total = hours * 60 + minutes
                Text(TimeFormatters.formatDurationLong(total))
                    .font(Constants.Fonts.title)
                    .foregroundStyle(Constants.Colors.primaryText)

                Spacer()
            }
            .padding(Constants.Spacing.lg)
            .navigationTitle("Custom Duration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Set") {
                        let total = hours * 60 + minutes
                        if total >= Constants.Timer.minDuration && total <= Constants.Timer.maxDuration {
                            selectedDuration = total
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(hours * 60 + minutes < Constants.Timer.minDuration)
                }
            }
            .onAppear {
                hours = selectedDuration / 60
                minutes = selectedDuration % 60
            }
        }
        .presentationDetents([.medium])
    }
}

struct DurationChip: View {
    let duration: Int
    let isSelected: Bool
    var isRecommended: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    if isRecommended {
                        Image(systemName: "sparkle")
                            .font(.system(size: 10))
                    }
                    Text(TimeFormatters.formatDuration(duration))
                        .font(Constants.Fonts.headline)
                }
                if isRecommended {
                    Text("For You")
                        .font(.system(size: 9, weight: .medium))
                }
            }
            .foregroundStyle(isSelected ? .white : (isRecommended ? Constants.Colors.accent : Constants.Colors.primaryText))
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
            durations: [15, 25, 45, 60, 90],
            recommendedDuration: 25,
            recommendationConfidence: .coldStart,
            sessionCount: 2
        )
    }
    .padding()
}
