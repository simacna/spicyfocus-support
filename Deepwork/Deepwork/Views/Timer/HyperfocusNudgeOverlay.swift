import SwiftUI

struct HyperfocusNudgeOverlay: View {
    let onDismiss: () -> Void
    @State private var isVisible = false
    @State private var autoDismissTask: Task<Void, Never>?

    private let message = Constants.Nudges.random()

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: Constants.Spacing.md) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Constants.Colors.accent)

                Text(message)
                    .font(Constants.Fonts.headline)
                    .foregroundStyle(Constants.Colors.primaryText)
                    .multilineTextAlignment(.center)

                Button {
                    dismiss()
                } label: {
                    Text("Got it")
                        .font(Constants.Fonts.caption)
                        .foregroundStyle(Constants.Colors.secondaryText)
                }
            }
            .padding(Constants.Spacing.lg)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, Constants.Spacing.xl)
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)

            Spacer()
                .frame(height: Constants.Spacing.xxl)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                isVisible = true
            }
            autoDismissTask = Task {
                try? await Task.sleep(for: .seconds(8))
                guard !Task.isCancelled else { return }
                await MainActor.run { dismiss() }
            }
        }
        .onDisappear {
            autoDismissTask?.cancel()
        }
    }

    private func dismiss() {
        withAnimation(.easeIn(duration: 0.3)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HyperfocusNudgeOverlay(onDismiss: {})
    }
}
