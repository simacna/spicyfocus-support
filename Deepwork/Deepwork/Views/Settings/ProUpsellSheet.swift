import SwiftUI

struct ProUpsellSheet: View {
    @EnvironmentObject private var userSettings: UserSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: Constants.Spacing.xl) {
                Spacer()

                // Celebration
                VStack(spacing: Constants.Spacing.md) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 80))
                        .foregroundStyle(Constants.Colors.accent)

                    Text("Built for Your Brain")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Constants.Colors.primaryText)

                    Text("You've completed \(userSettings.completedSessionCount) sessions — your brain is finding its rhythm. Unlock Pro for the tools research shows work best for ADHD focus.")
                        .font(Constants.Fonts.body)
                        .foregroundStyle(Constants.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Constants.Spacing.lg)
                }

                // Features preview
                VStack(alignment: .leading, spacing: Constants.Spacing.md) {
                    ProUpsellFeature(icon: "waveform", title: "Brown Noise & Ambient Sounds", subtitle: "Research shows ambient noise specifically helps ADHD brains focus", color: .orange)
                    ProUpsellFeature(icon: "chart.xyaxis.line", title: "Focus Insights", subtitle: "Track your peak focus hours — your brain has patterns", color: .blue)
                    ProUpsellFeature(icon: "flame.fill", title: "Streaks & Rewards", subtitle: "Immediate dopamine hits that match how your brain works", color: .red)
                    ProUpsellFeature(icon: "timer", title: "Pomodoro Mode", subtitle: "Structured work/break cycles for sustained focus", color: .purple)
                }
                .padding(Constants.Spacing.lg)
                .background(Constants.Colors.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Spacer()

                // Buttons
                VStack(spacing: Constants.Spacing.md) {
                    NavigationLink {
                        ProUpgradeView()
                    } label: {
                        Text("Unlock Pro - $4.99")
                            .font(Constants.Fonts.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(Constants.Spacing.md)
                            .background(Constants.Colors.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button("Maybe Later") {
                        dismiss()
                    }
                    .font(Constants.Fonts.body)
                    .foregroundStyle(Constants.Colors.secondaryText)
                }
            }
            .padding(Constants.Spacing.lg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Constants.Colors.secondaryText)
                    }
                }
            }
        }
    }
}

struct ProUpsellFeature: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let color: Color

    var body: some View {
        HStack(spacing: Constants.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Constants.Fonts.body)
                    .foregroundStyle(Constants.Colors.primaryText)

                if let subtitle {
                    Text(subtitle)
                        .font(Constants.Fonts.caption)
                        .foregroundStyle(Constants.Colors.secondaryText)
                }
            }

            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 14))
                .foregroundStyle(Constants.Colors.secondaryText.opacity(0.5))
        }
    }
}

#Preview {
    ProUpsellSheet()
        .environmentObject(UserSettings())
}
