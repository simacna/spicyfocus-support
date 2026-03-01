import ActivityKit
import SwiftUI

struct FocusTimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var endTime: Date
        var label: String
        var isPaused: Bool
    }

    var plannedDuration: Int
    var sessionLabel: String
}
