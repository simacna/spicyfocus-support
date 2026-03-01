import SwiftUI

struct ScienceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.Spacing.xl) {
                // Intro
                VStack(alignment: .leading, spacing: Constants.Spacing.md) {
                    Text("Every feature in Spicy Focus is grounded in ADHD neuroscience research. Here's why it works.")
                        .font(Constants.Fonts.body)
                        .foregroundStyle(Constants.Colors.secondaryText)
                }

                // Sections
                ScienceSection(
                    icon: "waveform",
                    title: "Ambient Noise & Focus",
                    summary:"A 2024 meta-analysis found that ambient noise has a statistically significant benefit for ADHD focus (effect size g=0.249, p<0.0001) — but a negative effect on non-ADHD brains. The benefit is ADHD-specific.",
                    detail: "The theory: ADHD brains have lower baseline neural noise. External ambient sound compensates via stochastic resonance, helping the brain detect signals better.",
                    citations: [
                        "Soderlund, G., Sikstrom, S., & Smart, A. (2007). Listening to noise: Noise is beneficial for cognitive performance in ADHD.",
                        "2024 meta-analysis on ambient noise and ADHD attention performance."
                    ]
                )

                ScienceSection(
                    icon: "clock.arrow.circlepath",
                    title: "Time Blindness",
                    summary:"Time blindness is a documented neurological symptom of ADHD — not a character flaw. The internal clock runs on dopamine pathways that are impaired in ADHD.",
                    detail: "Visual timers provide external time cues that compensate for impaired internal time perception. This is scaffolding, not a crutch.",
                    citations: [
                        "Barkley, R. A. — describes time blindness as \"the most devastating deficit\" of ADHD.",
                        "Research on dopamine pathway involvement in time perception and ADHD."
                    ]
                )

                ScienceSection(
                    icon: "flame",
                    title: "Dopamine & Rewards",
                    summary:"ADHD brains have measurably lower dopamine receptor availability in reward and motivation regions. This means your brain needs more frequent, immediate rewards to stay engaged.",
                    detail: "Streaks, progress tracking, and session stats deliver the kind of immediate feedback that addresses the dopamine reward pathway deficit directly. Apps with game elements show 48% higher retention.",
                    citations: [
                        "Volkow, N. D. et al., NIDA — PET imaging study on dopamine receptors in 45 adults with ADHD.",
                        "Research on gamification and engagement in ADHD populations."
                    ]
                )

                ScienceSection(
                    icon: "brain.head.profile",
                    title: "Focus Regulation, Not Deficit",
                    summary:"68% of adults with ADHD report frequent hyperfocus episodes. ADHD is not an inability to focus — it's an inability to regulate focus.",
                    detail: "Spicy Focus helps you channel hyperfocus productively with structured sessions, rather than fighting against how your brain naturally works.",
                    citations: [
                        "Ashinoff, B. K., & Abu-Akel, A. (2021). Hyperfocus: The forgotten frontier of attention."
                    ]
                )

                ScienceSection(
                    icon: "puzzlepiece",
                    title: "External Scaffolding",
                    summary:"Where neurotypical brains generate internal urgency, ADHD brains need external cues — timers, visual progress, accountability structures.",
                    detail: "This is a well-documented compensatory strategy. Every feature in Spicy Focus acts as external scaffolding for your executive function.",
                    citations: [
                        "Barkley, R. A. — research on external supports and executive function deficits in ADHD."
                    ]
                )

                // Footer
                Text("366 million adults worldwide have ADHD. 1 in 16 Americans. You're not alone.")
                    .font(Constants.Fonts.caption)
                    .foregroundStyle(Constants.Colors.secondaryText)
                    .padding(.top, Constants.Spacing.md)
            }
            .padding(Constants.Spacing.lg)
        }
        .navigationTitle("The Science")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ScienceSection: View {
    let icon: String
    let title: String
    let summary: String
    let detail: String
    let citations: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            HStack(spacing: Constants.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Constants.Colors.accent)

                Text(title)
                    .font(Constants.Fonts.headline)
                    .foregroundStyle(Constants.Colors.primaryText)
            }

            Text(summary)
                .font(Constants.Fonts.body)
                .foregroundStyle(Constants.Colors.primaryText)

            Text(detail)
                .font(Constants.Fonts.caption)
                .foregroundStyle(Constants.Colors.secondaryText)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(citations, id: \.self) { citation in
                    Text("· \(citation)")
                        .font(.system(size: 11))
                        .foregroundStyle(Constants.Colors.secondaryText.opacity(0.7))
                }
            }
            .padding(.top, 4)
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        ScienceView()
    }
}
