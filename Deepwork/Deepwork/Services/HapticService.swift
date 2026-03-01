import Foundation
import UIKit

final class HapticService {
    private var isEnabled: Bool = true

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    init() {
        prepareGenerators()
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }

    private func prepareGenerators() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        notificationGenerator.prepare()
    }

    func playStart() {
        guard isEnabled else { return }
        mediumGenerator.impactOccurred()
    }

    func playPause() {
        guard isEnabled else { return }
        lightGenerator.impactOccurred()
    }

    func playResume() {
        guard isEnabled else { return }
        lightGenerator.impactOccurred()
    }

    func playStop() {
        guard isEnabled else { return }
        mediumGenerator.impactOccurred()
    }

    func playCompletion() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }

    func playTick() {
        guard isEnabled else { return }
        lightGenerator.impactOccurred(intensity: 0.5)
    }

    func playSelection() {
        guard isEnabled else { return }
        let selectionGenerator = UISelectionFeedbackGenerator()
        selectionGenerator.selectionChanged()
    }
}
