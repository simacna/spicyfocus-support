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
        static let defaultDurations: [Int] = [5, 10, 15, 25, 45, 60, 90]
        static let defaultDuration: Int = 25
        static let minDuration: Int = 1
        static let maxDuration: Int = 180
    }

    enum Recommendation {
        static let coldStartThreshold = 5
        static let establishedThreshold = 15
        static let stretchThreshold = 0.80
        static let pullbackThreshold = 0.60
        static let recentSessionWindow = 10
        static let snapDurations: [Int] = [5, 10, 15, 20, 25, 30, 45, 60, 90]
    }

    enum Labels {
        static let defaults: [String] = ["Focus", "Study", "Writing", "Coding", "Reading", "Creative"]
    }

    enum Nudges {
        static let messages: [String] = [
            "Stretch break?",
            "Grab some water",
            "Rest your eyes for a moment",
            "Take a deep breath",
            "Roll your shoulders back",
            "Unclench your jaw",
            "How's your posture?",
            "Blink a few times",
            "Stand up and stretch",
            "Time for a quick snack?"
        ]

        static func random() -> String {
            messages.randomElement() ?? messages[0]
        }
    }

    enum Quotes {
        static let affirmations: [String] = [
            "Your brain isn't broken — it's wired for intensity.",
            "Hyperfocus is your superpower. Time to aim it.",
            "Small steps still move you forward.",
            "You don't need to be productive all day. Just right now.",
            "Progress isn't always visible, but it's always happening.",
            "Your brain craves a challenge. Give it one.",
            "Starting is the hardest part. And you're here.",
            "Focus isn't about perfection. It's about showing up.",
            "One session at a time. That's all it takes.",
            "The fact that you're here means you're already trying.",
            "Messy progress beats perfect paralysis.",
            "Your attention is valuable. You're choosing to invest it wisely.",
            "Deep work is a skill. Every session makes you better.",
            "You don't need motivation. You need a timer and 10 minutes.",
            "Rest is productive too. But right now — let's focus.",
            "Neurodivergent brains do remarkable things with the right structure.",
            "This is your time. No notifications. No distractions. Just you.",
            "Done is better than perfect. Let's get something done.",
            "Your streak doesn't define you, but it sure feels good.",
            "Even 5 minutes of focus can change the trajectory of your day."
        ]

        static func random() -> String {
            affirmations.randomElement() ?? affirmations[0]
        }
    }

    enum ScienceNuggets {
        static let facts: [String] = [
            "You just strengthened a neural pathway. Repeated focus sessions physically rewire your brain's attention circuits.",
            "The act of starting is the hardest part for ADHD brains. You cleared the biggest hurdle today.",
            "Setting a timer creates artificial urgency that compensates for ADHD's impaired sense of time. Smart strategy.",
            "External scaffolding like timers and intentions aren't crutches — they're tools that compensate for real neurological differences.",
            "Your prefrontal cortex just got a workout. Each session builds stronger executive function over time.",
            "Research shows that structured focus periods increase dopamine receptor availability — you're literally training your reward system.",
            "Time blindness is neurological, not a character flaw. Using a timer is like wearing glasses for your sense of time.",
            "Studies show that even short focus sessions create measurable changes in attention networks within weeks.",
            "Your brain just practiced sustained attention — a skill that strengthens every time you use it, like a muscle.",
            "Hyperfocus is your brain's proof that it can concentrate intensely. A timer helps you aim that power intentionally.",
            "By setting an intention, you activated your brain's goal-pursuit system — making focus up to 2-3x more likely.",
            "Completing a session triggers a natural dopamine release. Your brain is learning that focused work feels rewarding."
        ]

        static func random() -> String {
            facts.randomElement() ?? facts[0]
        }
    }

    enum StreakMilestones {
        struct Milestone {
            let days: Int
            let title: String
            let message: String
            let scienceFact: String
            let icon: String
        }

        static let milestones: [Int: Milestone] = [
            3: Milestone(
                days: 3,
                title: "3-Day Spark",
                message: "Three days in a row. You're building something real.",
                scienceFact: "Research shows it takes as few as 3 repetitions for your brain to start encoding a new behavioral pattern.",
                icon: "bolt.fill"
            ),
            7: Milestone(
                days: 7,
                title: "One-Week Flame",
                message: "A full week of showing up. That's no accident.",
                scienceFact: "After 7 days, your brain begins automating the cue-routine-reward loop.",
                icon: "flame.fill"
            ),
            14: Milestone(
                days: 14,
                title: "Two-Week Blaze",
                message: "Two weeks of consistent focus. You're in the steep part of the curve.",
                scienceFact: "The steepest gains in habit formation happen in the first 2-3 weeks. (European Journal of Social Psychology, 2009)",
                icon: "flame.circle.fill"
            ),
            30: Milestone(
                days: 30,
                title: "30-Day Inferno",
                message: "A full month. Your brain has physically changed.",
                scienceFact: "After 30 days, neuroimaging shows measurable increases in gray matter density in attention-related brain regions.",
                icon: "star.fill"
            ),
            50: Milestone(
                days: 50,
                title: "50-Day Legend",
                message: "Fifty days. This is who you are now.",
                scienceFact: "At 50 days, the habit automaticity curve begins to plateau — your focus practice is becoming second nature.",
                icon: "crown.fill"
            ),
            100: Milestone(
                days: 100,
                title: "100-Day Titan",
                message: "One hundred days. You've built something permanent.",
                scienceFact: "Long-term practice creates lasting structural changes in neural pathways. You've built infrastructure your brain will use for years.",
                icon: "trophy.fill"
            )
        ]

        static func milestone(for streak: Int) -> Milestone? {
            milestones[streak]
        }
    }
}

enum EnergyLevel: String, CaseIterable, Codable {
    case low
    case medium
    case high
    case notRated

    var icon: String {
        switch self {
        case .low: return "battery.25"
        case .medium: return "battery.50"
        case .high: return "battery.100"
        case .notRated: return "battery.0"
        }
    }

    var color: Color {
        switch self {
        case .low: return .blue
        case .medium: return .orange
        case .high: return Constants.Colors.accent
        case .notRated: return Constants.Colors.secondaryText
        }
    }

    var emoji: String {
        switch self {
        case .low: return "🪫"
        case .medium: return "⚡"
        case .high: return "🔥"
        case .notRated: return ""
        }
    }

    var label: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .notRated: return "Not Rated"
        }
    }

    var description: String {
        switch self {
        case .low: return "Tired, foggy, or drained"
        case .medium: return "Okay — not great, not bad"
        case .high: return "Alert, energized, ready to go"
        case .notRated: return ""
        }
    }

    static var ratable: [EnergyLevel] {
        [.low, .medium, .high]
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
