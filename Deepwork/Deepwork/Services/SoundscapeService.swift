import AVFoundation
import Foundation

enum Soundscape: String, CaseIterable, Identifiable {
    case none = "None"
    case whiteNoise = "White Noise"
    case brownNoise = "Brown Noise"
    case rain = "Rain"
    case lofi = "Lo-fi"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .none: return "speaker.slash"
        case .whiteNoise: return "waveform"
        case .brownNoise: return "waveform.path"
        case .rain: return "cloud.rain"
        case .lofi: return "music.note"
        }
    }

    /// White noise is free, all others require Pro
    var requiresPro: Bool {
        switch self {
        case .none, .whiteNoise: return false
        case .brownNoise, .rain, .lofi: return true
        }
    }

    var fileName: String? {
        switch self {
        case .none: return nil
        case .whiteNoise: return "white_noise"
        case .brownNoise: return "brown_noise"
        case .rain: return "rain"
        case .lofi: return "lofi"
        }
    }
}

@MainActor
final class SoundscapeService: ObservableObject {
    @Published var selectedSoundscape: Soundscape = .none
    @Published var volume: Float = 0.5

    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false

    static let shared = SoundscapeService()

    private init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            // Audio session configuration failed
        }
    }

    func play(_ soundscape: Soundscape) {
        stop()
        selectedSoundscape = soundscape

        guard soundscape != .none, let fileName = soundscape.fileName else { return }

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "m4a") else {
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1 // Loop indefinitely
            player.volume = volume
            player.play()
            audioPlayer = player
            isPlaying = true
        } catch {
            // Failed to create audio player
        }
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }

    func pause() {
        audioPlayer?.pause()
    }

    func resume() {
        audioPlayer?.play()
    }

    func setVolume(_ newVolume: Float) {
        volume = newVolume
        audioPlayer?.volume = newVolume
    }
}
