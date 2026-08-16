import SwiftUI

enum BlobMood {
    case happy
    case sleepy
    case celebrating
}

struct BlobMascot: View {
    let size: CGFloat
    let mood: BlobMood
    @State private var floating = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.38, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.9), .blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size * 0.82)

            HStack(spacing: size * 0.18) {
                eye
                eye
            }
            .offset(y: -size * 0.04)

            if mood != .sleepy {
                Capsule()
                    .fill(.white.opacity(0.9))
                    .frame(width: size * 0.22, height: size * 0.08)
                    .offset(y: size * 0.2)
            }
        }
        .frame(width: size, height: size)
        .offset(y: floating ? -size * 0.04 : size * 0.04)
        .rotationEffect(mood == .celebrating ? .degrees(floating ? 4 : -4) : .zero)
        .animation(
            .easeInOut(duration: mood == .celebrating ? 0.45 : 1.4)
                .repeatForever(autoreverses: true),
            value: floating
        )
        .onAppear { floating = true }
        .accessibilityLabel(mood == .sleepy ? "Posture Pal sleeping" : "Posture Pal")
    }

    @ViewBuilder
    private var eye: some View {
        if mood == .sleepy {
            Capsule()
                .fill(.white.opacity(0.9))
                .frame(width: size * 0.18, height: size * 0.045)
        } else {
            Circle()
                .fill(.white.opacity(0.95))
                .frame(width: size * 0.11, height: size * 0.11)
        }
    }
}
