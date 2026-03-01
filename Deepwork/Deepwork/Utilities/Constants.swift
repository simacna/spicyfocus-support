import SwiftUI

enum Constants {
    enum Colors {
        static let accent = Color(hex: "FF5722")
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let primaryText = Color(UIColor.label)
        static let secondaryText = Color(UIColor.secondaryLabel)
        static let success = Color.green
        static let warning = Color.orange
    }

    enum Fonts {
        static let timerDisplay = Font.system(size: 96, weight: .bold, design: .monospaced)
        static let timerDisplaySmall = Font.system(size: 72, weight: .bold, design: .monospaced)
        static let title = Font.system(size: 28, weight: .bold)
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 17, weight: .regular)
        static let caption = Font.system(size: 13, weight: .regular)
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum Timer {
        static let defaultDurations: [Int] = [15, 25, 45, 60, 90]
        static let defaultDuration: Int = 25
        static let minDuration: Int = 1
        static let maxDuration: Int = 180
    }

    enum Labels {
        static let defaults: [String] = ["Focus", "Study", "Writing", "Coding", "Reading", "Creative"]
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
