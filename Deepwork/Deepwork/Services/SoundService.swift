import Foundation
import AVFoundation

final class SoundService {
    private var audioPlayer: AVAudioPlayer?
    private var isEnabled: Bool = true

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }

    func playCompletion() {
        guard isEnabled else { return }
        playSystemSound(.complete)
    }

    func playTick() {
        guard isEnabled else { return }
        playSystemSound(.tick)
    }

    private func playSystemSound(_ sound: SystemSound) {
        AudioServicesPlaySystemSound(sound.id)
    }

    private enum SystemSound {
        case complete
        case tick

        var id: SystemSoundID {
            switch self {
            case .complete:
                return 1007 // SMS received sound
            case .tick:
                return 1104 // Tick sound
            }
        }
    }
}
