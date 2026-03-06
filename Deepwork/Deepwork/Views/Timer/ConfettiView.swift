import SwiftUI

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var rotation: Double
    var scale: CGFloat
    var color: Color
    var speed: CGFloat
    var wobble: CGFloat
    var opacity: Double
}

struct ConfettiView: View {
    @Binding var isActive: Bool

    @State private var particles: [ConfettiParticle] = []
    @State private var timer: Timer?

    private let colors: [Color] = [
        Constants.Colors.accent,
        .orange,
        .yellow,
        .green,
        .blue,
        .purple,
        .pink
    ]

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                for particle in particles {
                    let rect = CGRect(
                        x: particle.x - 4 * particle.scale,
                        y: particle.y - 4 * particle.scale,
                        width: 8 * particle.scale,
                        height: 8 * particle.scale
                    )

                    context.opacity = particle.opacity

                    var transform = CGAffineTransform.identity
                    transform = transform.translatedBy(x: rect.midX, y: rect.midY)
                    transform = transform.rotated(by: particle.rotation)
                    transform = transform.translatedBy(x: -rect.midX, y: -rect.midY)

                    context.transform = transform
                    context.fill(
                        Path(roundedRect: rect, cornerRadius: 2),
                        with: .color(particle.color)
                    )
                    context.transform = .identity
                }
            }
            .allowsHitTesting(false)
            .onChange(of: isActive) { _, active in
                if active {
                    spawnParticles(in: geometry.size)
                }
            }
        }
        .ignoresSafeArea()
    }

    private func spawnParticles(in size: CGSize) {
        particles = (0..<80).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: -size.height * 0.3...0),
                rotation: Double.random(in: 0...(.pi * 2)),
                scale: CGFloat.random(in: 0.5...1.5),
                color: colors.randomElement() ?? .orange,
                speed: CGFloat.random(in: 2...6),
                wobble: CGFloat.random(in: -2...2),
                opacity: 1.0
            )
        }

        // Animate particles falling
        timer?.invalidate()
        var elapsed: CGFloat = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { t in
            elapsed += 1.0 / 60.0

            DispatchQueue.main.async {
                for i in particles.indices {
                    particles[i].y += particles[i].speed
                    particles[i].x += sin(elapsed * 3 + CGFloat(i)) * particles[i].wobble
                    particles[i].rotation += Double.random(in: -0.1...0.1)

                    // Fade out after 2 seconds
                    if elapsed > 2.0 {
                        particles[i].opacity = max(0, particles[i].opacity - 0.02)
                    }
                }

                if elapsed > 3.5 {
                    t.invalidate()
                    particles = []
                    isActive = false
                }
            }
        }
    }
}

// MARK: - Streak Milestone Check

enum CelebrationTrigger {
    static let streakMilestones: Set<Int> = [3, 7, 14, 30, 50, 100]

    static func shouldCelebrate(streak: Int) -> Bool {
        streakMilestones.contains(streak)
    }
}
