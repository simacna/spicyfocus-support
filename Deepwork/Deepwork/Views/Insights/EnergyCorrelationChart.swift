import SwiftUI

struct EnergyCorrelationChart: View {
    let sessions: [FocusSession]

    private var energyData: [EnergyBucket] {
        let rated = sessions.filter { $0.energy != .notRated }
        guard !rated.isEmpty else { return [] }

        return EnergyLevel.ratable.compactMap { level in
            let matching = rated.filter { $0.energy == level }
            guard !matching.isEmpty else { return nil }

            let avgMinutes = matching.reduce(0) { $0 + $1.actualDuration } / matching.count / 60
            let completed = matching.filter { $0.wasCompleted }.count
            let completionRate = Double(completed) / Double(matching.count)

            return EnergyBucket(
                level: level,
                avgMinutes: avgMinutes,
                completionRate: completionRate,
                sessionCount: matching.count
            )
        }
    }

    private var bestLevel: EnergyLevel? {
        energyData.max(by: { $0.avgMinutes < $1.avgMinutes })?.level
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Energy & Focus")
                .font(Constants.Fonts.headline)
                .foregroundStyle(Constants.Colors.primaryText)

            if energyData.isEmpty {
                Text("Rate your energy before sessions to see patterns here.")
                    .font(Constants.Fonts.body)
                    .foregroundStyle(Constants.Colors.secondaryText)
            } else {
                let maxMinutes = energyData.map(\.avgMinutes).max() ?? 1

                VStack(spacing: Constants.Spacing.md) {
                    ForEach(energyData) { bucket in
                        HStack(spacing: Constants.Spacing.sm) {
                            Text(bucket.level.emoji)
                                .font(.system(size: 20))
                                .frame(width: 28)

                            Text(bucket.level.label)
                                .font(Constants.Fonts.body)
                                .foregroundStyle(Constants.Colors.primaryText)
                                .frame(width: 64, alignment: .leading)

                            GeometryReader { geo in
                                let barWidth = maxMinutes > 0
                                    ? geo.size.width * CGFloat(bucket.avgMinutes) / CGFloat(maxMinutes)
                                    : 0

                                RoundedRectangle(cornerRadius: 6)
                                    .fill(bucket.level.color)
                                    .frame(width: max(barWidth, 4), height: 24)
                            }
                            .frame(height: 24)

                            Text("\(bucket.avgMinutes)m")
                                .font(Constants.Fonts.caption)
                                .foregroundStyle(Constants.Colors.secondaryText)
                                .frame(width: 36, alignment: .trailing)
                        }

                        HStack {
                            Spacer()
                            Text("\(Int(bucket.completionRate * 100))% completed")
                                .font(.system(size: 11))
                                .foregroundStyle(Constants.Colors.secondaryText)
                            Text("·")
                                .foregroundStyle(Constants.Colors.secondaryText)
                            Text("\(bucket.sessionCount) sessions")
                                .font(.system(size: 11))
                                .foregroundStyle(Constants.Colors.secondaryText)
                        }
                    }
                }

                if let best = bestLevel {
                    Text("You focus best when your energy is \(best.label.lowercased()).")
                        .font(Constants.Fonts.caption)
                        .foregroundStyle(Constants.Colors.accent)
                        .padding(.top, Constants.Spacing.xs)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct EnergyBucket: Identifiable {
    let id = UUID()
    let level: EnergyLevel
    let avgMinutes: Int
    let completionRate: Double
    let sessionCount: Int
}

#Preview {
    EnergyCorrelationChart(sessions: FocusSession.previewList)
        .padding()
}
