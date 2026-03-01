import SwiftUI

/// Preview this view and screenshot at 1024x1024 for App Store icon
struct IconPreview: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.45, blue: 0.2),  // Orange
                    Color(red: 1.0, green: 0.3, blue: 0.15)   // Deeper orange
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Brain/focus icon
            VStack(spacing: 0) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 400, weight: .medium))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            }
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 224)) // iOS icon corner radius
    }
}

/// Alternative design with timer ring
struct IconPreviewAlt: View {
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.15),
                    Color(red: 0.05, green: 0.05, blue: 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Timer ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.5, blue: 0.2),
                            Color(red: 1.0, green: 0.3, blue: 0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 80, lineCap: .round)
                )
                .frame(width: 700, height: 700)
                .rotationEffect(.degrees(-90))

            // Center content
            VStack(spacing: 20) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 280, weight: .medium))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 224))
    }
}

/// Minimal design
struct IconPreviewMinimal: View {
    var body: some View {
        ZStack {
            // Solid orange background
            Color(red: 1.0, green: 0.4, blue: 0.15)

            // Simple "D" with timer arc
            ZStack {
                // Timer arc
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(.white.opacity(0.3), style: StrokeStyle(lineWidth: 60, lineCap: .round))
                    .frame(width: 600, height: 600)
                    .rotationEffect(.degrees(-90))

                // Progress arc
                Circle()
                    .trim(from: 0, to: 0.5)
                    .stroke(.white, style: StrokeStyle(lineWidth: 60, lineCap: .round))
                    .frame(width: 600, height: 600)
                    .rotationEffect(.degrees(-90))

                // Center dot
                Circle()
                    .fill(.white)
                    .frame(width: 120, height: 120)
            }
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 224))
    }
}

#Preview("Icon - Brain") {
    IconPreview()
        .previewLayout(.fixed(width: 1024, height: 1024))
}

#Preview("Icon - Ring") {
    IconPreviewAlt()
        .previewLayout(.fixed(width: 1024, height: 1024))
}

#Preview("Icon - Minimal") {
    IconPreviewMinimal()
        .previewLayout(.fixed(width: 1024, height: 1024))
}
