import SwiftUI

struct TimerControls: View {
    let state: TimerState
    let onStart: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onStop: () -> Void

    @State private var isPressed = false

    var body: some View {
        HStack(spacing: Constants.Spacing.xl) {
            switch state {
            case .idle:
                primaryButton(
                    title: "Start Focus",
                    icon: "play.fill",
                    action: onStart
                )

            case .running:
                secondaryButton(
                    title: "Stop",
                    icon: "stop.fill",
                    action: onStop
                )

                primaryButton(
                    title: "Pause",
                    icon: "pause.fill",
                    action: onPause
                )

            case .paused:
                secondaryButton(
                    title: "Stop",
                    icon: "stop.fill",
                    action: onStop
                )

                primaryButton(
                    title: "Resume",
                    icon: "play.fill",
                    action: onResume
                )

            case .completed:
                EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: state)
    }

    private func primaryButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Constants.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(Constants.Fonts.headline)
            }
            .foregroundStyle(.white)
            .frame(minWidth: 140, minHeight: 56)
            .background(Constants.Colors.accent)
            .clipShape(Capsule())
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func secondaryButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Constants.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(Constants.Fonts.headline)
            }
            .foregroundStyle(Constants.Colors.primaryText)
            .frame(minWidth: 100, minHeight: 56)
            .background(Constants.Colors.secondaryBackground)
            .clipShape(Capsule())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview("Idle") {
    TimerControls(
        state: .idle,
        onStart: {},
        onPause: {},
        onResume: {},
        onStop: {}
    )
}

#Preview("Running") {
    TimerControls(
        state: .running,
        onStart: {},
        onPause: {},
        onResume: {},
        onStop: {}
    )
}

#Preview("Paused") {
    TimerControls(
        state: .paused,
        onStart: {},
        onPause: {},
        onResume: {},
        onStop: {}
    )
}
