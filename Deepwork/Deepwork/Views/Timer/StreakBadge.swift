import SwiftUI

struct StreakBadge: View {
    let streak: Int
    let isCompact: Bool

    init(streak: Int, isCompact: Bool = false) {
        self.streak = streak
        self.isCompact = isCompact
    }

    var body: some View {
        HStack(spacing: Constants.Spacing.xs) {
            Image(systemName: "flame.fill")
                .font(.system(size: isCompact ? 14 : 18, weight: .semibold))
                .foregroundStyle(streak > 0 ? Constants.Colors.accent : Constants.Colors.secondaryText)

            Text("\(streak)")
                .font(isCompact ? Constants.Fonts.body : Constants.Fonts.headline)
                .foregroundStyle(streak > 0 ? Constants.Colors.primaryText : Constants.Colors.secondaryText)

            if !isCompact {
                Text(streak == 1 ? "day" : "days")
                    .font(Constants.Fonts.caption)
                    .foregroundStyle(Constants.Colors.secondaryText)
            }
        }
        .padding(.horizontal, Constants.Spacing.md)
        .padding(.vertical, Constants.Spacing.sm)
        .background(Constants.Colors.secondaryBackground)
        .clipShape(Capsule())
    }
}

struct StreakBadgeLarge: View {
    let streak: Int
    let longestStreak: Int

    var body: some View {
        VStack(spacing: Constants.Spacing.md) {
            HStack(spacing: Constants.Spacing.sm) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(streak > 0 ? Constants.Colors.accent : Constants.Colors.secondaryText)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(streak)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(Constants.Colors.primaryText)

                    Text("day streak")
                        .font(Constants.Fonts.caption)
                        .foregroundStyle(Constants.Colors.secondaryText)
                }
            }

            if longestStreak > streak {
                Text("Best: \(longestStreak) days")
                    .font(Constants.Fonts.caption)
                    .foregroundStyle(Constants.Colors.secondaryText)
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview("Streak Badge") {
    VStack(spacing: 20) {
        StreakBadge(streak: 0)
        StreakBadge(streak: 7)
        StreakBadge(streak: 30)
        StreakBadge(streak: 7, isCompact: true)
    }
    .padding()
}

#Preview("Streak Badge Large") {
    VStack(spacing: 20) {
        StreakBadgeLarge(streak: 7, longestStreak: 14)
        StreakBadgeLarge(streak: 14, longestStreak: 14)
    }
    .padding()
}
