import SwiftUI

struct MicroCommitmentCompleteSheet: View {
    let onExtend: (Int) -> Void
    let onFinish: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Constants.Spacing.lg) {
            VStack(spacing: Constants.Spacing.sm) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Constants.Colors.accent)

                Text("You did it!")
                    .font(Constants.Fonts.title)
                    .foregroundStyle(Constants.Colors.primaryText)

                Text("5 minutes down. You broke through the starting barrier — that's the hardest part.\nKeep going?")
                    .font(Constants.Fonts.body)
                    .foregroundStyle(Constants.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Constants.Spacing.lg)

            VStack(spacing: Constants.Spacing.md) {
                Button {
                    onExtend(5 * 60)
                    dismiss()
                } label: {
                    Text("+5 minutes")
                        .font(Constants.Fonts.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(Constants.Spacing.md)
                        .background(Constants.Colors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    onExtend(10 * 60)
                    dismiss()
                } label: {
                    Text("+10 minutes")
                        .font(Constants.Fonts.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(Constants.Spacing.md)
                        .background(Constants.Colors.accent.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    onExtend(25 * 60)
                    dismiss()
                } label: {
                    Text("+25 minutes")
                        .font(Constants.Fonts.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(Constants.Spacing.md)
                        .background(Constants.Colors.accent.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    onFinish()
                    dismiss()
                } label: {
                    Text("I'm done")
                        .font(Constants.Fonts.body)
                        .foregroundStyle(Constants.Colors.secondaryText)
                        .padding(.top, Constants.Spacing.sm)
                }
            }
            .padding(.horizontal, Constants.Spacing.md)

            Spacer()
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    MicroCommitmentCompleteSheet(
        onExtend: { _ in },
        onFinish: {}
    )
}
