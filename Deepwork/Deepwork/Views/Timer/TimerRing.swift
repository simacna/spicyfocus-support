import SwiftUI

struct TimerRing: View {
    let progress: Double
    let remainingSeconds: Int
    let state: TimerState

    @State private var animatedProgress: Double = 0

    private let lineWidth: CGFloat = 12

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                // Background ring
                Circle()
                    .stroke(
                        Constants.Colors.secondaryBackground,
                        lineWidth: lineWidth
                    )

                // Progress ring
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        progressColor,
                        style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: animatedProgress)

                // Timer display
                VStack(spacing: Constants.Spacing.xs) {
                    Text(TimeFormatters.formatTimer(remainingSeconds))
                        .font(size > 280 ? Constants.Fonts.timerDisplay : Constants.Fonts.timerDisplaySmall)
                        .foregroundStyle(Constants.Colors.primaryText)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.default, value: remainingSeconds)

                    if state != .idle {
                        Text(stateLabel)
                            .font(Constants.Fonts.caption)
                            .foregroundStyle(Constants.Colors.secondaryText)
                            .textCase(.uppercase)
                    }
                }
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .aspectRatio(1, contentMode: .fit)
        .onChange(of: progress) { _, newValue in
            animatedProgress = newValue
        }
        .onAppear {
            animatedProgress = progress
        }
    }

    private var progressColor: Color {
        switch state {
        case .idle:
            return Constants.Colors.accent.opacity(0.3)
        case .running:
            return Constants.Colors.accent
        case .paused:
            return Constants.Colors.warning
        case .completed:
            return Constants.Colors.success
        }
    }

    private var stateLabel: String {
        switch state {
        case .idle:
            return ""
        case .running:
            return "Focusing"
        case .paused:
            return "Paused"
        case .completed:
            return "Complete"
        }
    }
}

#Preview("Idle") {
    TimerRing(progress: 0, remainingSeconds: 1500, state: .idle)
        .frame(width: 300, height: 300)
        .padding()
}

#Preview("Running") {
    TimerRing(progress: 0.4, remainingSeconds: 900, state: .running)
        .frame(width: 300, height: 300)
        .padding()
}

#Preview("Completed") {
    TimerRing(progress: 1.0, remainingSeconds: 0, state: .completed)
        .frame(width: 300, height: 300)
        .padding()
}
