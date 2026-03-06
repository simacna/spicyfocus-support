import SwiftUI

struct StreakMilestoneSheet: View {
    let milestone: Constants.StreakMilestones.Milestone
    let onDismiss: () -> Void

    @State private var showIcon = false
    @State private var showTitle = false
    @State private var showMessage = false
    @State private var showScienceFact = false
    @State private var showButton = false

    var body: some View {
        VStack(spacing: Constants.Spacing.xl) {
            Spacer()

            // Milestone icon
            Image(systemName: milestone.icon)
                .font(.system(size: 80))
                .foregroundStyle(Constants.Colors.accent)
                .scaleEffect(showIcon ? 1.0 : 0.3)
                .opacity(showIcon ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showIcon)

            // Title
            Text(milestone.title)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Constants.Colors.primaryText)
                .opacity(showTitle ? 1.0 : 0.0)
                .offset(y: showTitle ? 0 : 10)
                .animation(.easeOut(duration: 0.4), value: showTitle)

            // Message
            Text(milestone.message)
                .font(Constants.Fonts.body)
                .foregroundStyle(Constants.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.Spacing.lg)
                .opacity(showMessage ? 1.0 : 0.0)
                .offset(y: showMessage ? 0 : 10)
                .animation(.easeOut(duration: 0.4), value: showMessage)

            // Science fact card
            VStack(spacing: Constants.Spacing.sm) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 20))
                    .foregroundStyle(Constants.Colors.accent)

                Text(milestone.scienceFact)
                    .font(Constants.Fonts.caption)
                    .foregroundStyle(Constants.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(Constants.Spacing.md)
            .background(Constants.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, Constants.Spacing.lg)
            .opacity(showScienceFact ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.5), value: showScienceFact)

            Spacer()

            // Dismiss button
            Button {
                onDismiss()
            } label: {
                Text("Keep Going")
                    .font(Constants.Fonts.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(Constants.Spacing.md)
                    .background(Constants.Colors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, Constants.Spacing.lg)
            .padding(.bottom, Constants.Spacing.xl)
            .opacity(showButton ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.4), value: showButton)
        }
        .background(Constants.Colors.background)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { showIcon = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { showTitle = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { showMessage = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { showScienceFact = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { showButton = true }
        }
    }
}

#Preview {
    StreakMilestoneSheet(
        milestone: Constants.StreakMilestones.Milestone(
            days: 7,
            title: "One-Week Flame",
            message: "A full week of showing up. That's no accident.",
            scienceFact: "After 7 days, your brain begins automating the cue-routine-reward loop.",
            icon: "flame.fill"
        ),
        onDismiss: {}
    )
}
