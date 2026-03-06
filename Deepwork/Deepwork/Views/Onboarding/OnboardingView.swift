import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "brain.head.profile",
            title: "Your Brain Isn't Broken",
            description: "ADHD means your brain regulates focus differently — not less. Research shows you can hyperfocus for hours on the right task. Spicy Focus helps you channel that power.\n\n— Volkow et al., NIDA brain imaging studies",
            accentColor: .orange
        ),
        OnboardingPage(
            icon: "clock.arrow.circlepath",
            title: "Make Time Visible",
            description: "Time blindness is a real neurological symptom, not a character flaw. Visual timers and ambient sounds give your brain the external cues it needs to stay anchored.\n\n— Barkley, R.A.; Soderlund et al. (2024 meta-analysis)",
            accentColor: .blue
        ),
        OnboardingPage(
            icon: "flame",
            title: "Small Wins, Big Dopamine",
            description: "Your brain's reward system needs more frequent wins. Streaks, progress tracking, and session stats give you the immediate feedback your brain craves.\n\n— Volkow et al., dopamine receptor availability in ADHD",
            accentColor: .red
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "Built for Your Brain",
            description: "Set an intention before each session to activate goal-pursuit. Try the 5-minute rule to bypass the starting barrier. Let nudges keep you anchored. Use grace days to protect your streak on off days — because consistency isn't about perfection.\n\n— Gollwitzer (1999); Barkley on external scaffolding",
            accentColor: .purple
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Bottom section
            VStack(spacing: Constants.Spacing.lg) {
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Constants.Colors.accent : Constants.Colors.secondaryText.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }

                // Button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        isPresented = false
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                        .font(Constants.Fonts.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(Constants.Spacing.md)
                        .background(Constants.Colors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Skip button (only on first pages)
                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        isPresented = false
                    }
                    .font(Constants.Fonts.body)
                    .foregroundStyle(Constants.Colors.secondaryText)
                } else {
                    // Placeholder for layout consistency
                    Text(" ")
                        .font(Constants.Fonts.body)
                }
            }
            .padding(.horizontal, Constants.Spacing.lg)
            .padding(.bottom, Constants.Spacing.xl)
        }
        .background(Constants.Colors.background)
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: Constants.Spacing.xl) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(page.accentColor.opacity(0.15))
                    .frame(width: 160, height: 160)

                Image(systemName: page.icon)
                    .font(.system(size: 72))
                    .foregroundStyle(page.accentColor)
            }

            // Text
            VStack(spacing: Constants.Spacing.md) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Constants.Colors.primaryText)

                Text(page.description)
                    .font(Constants.Fonts.body)
                    .foregroundStyle(Constants.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.Spacing.lg)
            }

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
