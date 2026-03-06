import Foundation
import SwiftData

@Model
final class FocusSession {
    var id: UUID
    var startTime: Date
    var endTime: Date
    var plannedDuration: Int // in seconds
    var actualDuration: Int // in seconds
    var label: String
    var notes: String
    var wasCompleted: Bool
    var energyLevelRaw: String = ""
    var intention: String = ""
    var intentionCompleted: Bool = false

    var energy: EnergyLevel {
        get { EnergyLevel(rawValue: energyLevelRaw) ?? .notRated }
        set { energyLevelRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date = Date(),
        plannedDuration: Int,
        actualDuration: Int,
        label: String = "",
        notes: String = "",
        wasCompleted: Bool = true,
        energyLevel: EnergyLevel = .notRated,
        intention: String = "",
        intentionCompleted: Bool = false
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.plannedDuration = plannedDuration
        self.actualDuration = actualDuration
        self.label = label
        self.notes = notes
        self.wasCompleted = wasCompleted
        self.energyLevelRaw = energyLevel.rawValue
        self.intention = intention
        self.intentionCompleted = intentionCompleted
    }

    var plannedMinutes: Int {
        plannedDuration / 60
    }

    var actualMinutes: Int {
        actualDuration / 60
    }

    var completionPercentage: Double {
        guard plannedDuration > 0 else { return 0 }
        return min(Double(actualDuration) / Double(plannedDuration), 1.0)
    }
}

extension FocusSession {
    static var preview: FocusSession {
        FocusSession(
            startTime: Date().addingTimeInterval(-1800),
            endTime: Date(),
            plannedDuration: 1500,
            actualDuration: 1500,
            label: "Deep Work",
            wasCompleted: true,
            energyLevel: .high
        )
    }

    static var previewList: [FocusSession] {
        [
            FocusSession(
                startTime: Date().addingTimeInterval(-3600),
                endTime: Date().addingTimeInterval(-1800),
                plannedDuration: 1500,
                actualDuration: 1500,
                label: "Deep Work",
                wasCompleted: true,
                energyLevel: .high
            ),
            FocusSession(
                startTime: Date().addingTimeInterval(-7200),
                endTime: Date().addingTimeInterval(-5400),
                plannedDuration: 2700,
                actualDuration: 2700,
                label: "Study",
                wasCompleted: true,
                energyLevel: .medium
            ),
            FocusSession(
                startTime: Date().addingTimeInterval(-86400 - 1800),
                endTime: Date().addingTimeInterval(-86400),
                plannedDuration: 1500,
                actualDuration: 900,
                label: "Writing",
                wasCompleted: false,
                energyLevel: .low
            )
        ]
    }
}
