import SwiftUI

struct CategoryData: Identifiable {
    let id = UUID()
    let label: String
    let minutes: Int
    let percentage: Double
    let color: Color
}

struct CategoryBreakdown: View {
    let sessions: [FocusSession]

    @State private var categoryData: [CategoryData] = []

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Categories")
                .font(Constants.Fonts.headline)
                .foregroundStyle(Constants.Colors.primaryText)

            if categoryData.isEmpty {
                Text("No sessions yet")
                    .font(Constants.Fonts.body)
                    .foregroundStyle(Constants.Colors.secondaryText)
            } else {
                // Pie Chart
                PieChartView(data: categoryData)
                    .frame(height: 180)

                // Legend
                VStack(spacing: Constants.Spacing.sm) {
                    ForEach(categoryData.prefix(6)) { category in
                        HStack {
                            Circle()
                                .fill(category.color)
                                .frame(width: 12, height: 12)

                            Text(category.label)
                                .font(Constants.Fonts.body)
                                .foregroundStyle(Constants.Colors.primaryText)

                            Spacer()

                            Text(TimeFormatters.formatDuration(category.minutes))
                                .font(Constants.Fonts.body)
                                .foregroundStyle(Constants.Colors.secondaryText)

                            Text("\(Int(category.percentage * 100))%")
                                .font(Constants.Fonts.caption)
                                .foregroundStyle(Constants.Colors.secondaryText)
                                .frame(width: 40, alignment: .trailing)
                        }
                    }
                }
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .task(id: sessions.count) {
            categoryData = buildCategoryData()
        }
    }

    private func buildCategoryData() -> [CategoryData] {
        let grouped = Dictionary(grouping: sessions) { $0.label.isEmpty ? "Unlabeled" : $0.label }

        let totalMinutes = sessions.reduce(0) { $0 + $1.actualDuration } / 60
        guard totalMinutes > 0 else { return [] }

        let colors: [Color] = [
            Constants.Colors.accent,
            .blue,
            .green,
            .purple,
            .orange,
            .pink,
            .cyan,
            .yellow
        ]

        return grouped.enumerated().map { index, element in
            let categoryMinutes = element.value.reduce(0) { $0 + $1.actualDuration } / 60
            let percentage = Double(categoryMinutes) / Double(totalMinutes)
            return CategoryData(
                label: element.key,
                minutes: categoryMinutes,
                percentage: percentage,
                color: colors[index % colors.count]
            )
        }
        .sorted { $0.minutes > $1.minutes }
    }
}

struct PieChartView: View {
    let data: [CategoryData]

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 - 10

            ZStack {
                ForEach(Array(slices.enumerated()), id: \.offset) { index, slice in
                    PieSlice(
                        startAngle: slice.startAngle,
                        endAngle: slice.endAngle,
                        color: slice.color
                    )
                }
            }
            .frame(width: radius * 2, height: radius * 2)
            .position(center)
        }
    }

    private var slices: [(startAngle: Angle, endAngle: Angle, color: Color)] {
        var currentAngle: Double = -90
        return data.map { item in
            let startAngle = Angle(degrees: currentAngle)
            let degrees = item.percentage * 360
            currentAngle += degrees
            let endAngle = Angle(degrees: currentAngle)
            return (startAngle, endAngle, item.color)
        }
    }
}

struct PieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2

            Path { path in
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}

#Preview {
    CategoryBreakdown(sessions: [])
        .padding()
}
