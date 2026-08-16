import AppKit
import SwiftUI

@MainActor
final class ReminderWindowController: NSWindowController {
    init(
        prompt: String,
        streak: Int,
        onComplete: @escaping () -> Void,
        onSnooze: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        let view = ReminderView(
            prompt: prompt,
            streak: streak,
            onComplete: onComplete,
            onSnooze: onSnooze,
            onDismiss: onDismiss
        )
        let hostingView = NSHostingView(rootView: view)
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 430, height: 285),
            styleMask: [.titled, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.contentView = hostingView
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true

        super.init(window: panel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        guard let window else { return }
        position(window)
        window.orderFrontRegardless()
    }

    private func position(_ window: NSWindow) {
        let screen = NSScreen.main ?? NSScreen.screens.first
        guard let visibleFrame = screen?.visibleFrame else {
            window.center()
            return
        }

        let margin: CGFloat = 24
        let origin = NSPoint(
            x: visibleFrame.maxX - window.frame.width - margin,
            y: visibleFrame.maxY - window.frame.height - margin
        )
        window.setFrameOrigin(origin)
    }
}

private struct ReminderView: View {
    let prompt: String
    let streak: Int
    let onComplete: () -> Void
    let onSnooze: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 18) {
                BlobMascot(size: 82, mood: .celebrating)

                VStack(alignment: .leading, spacing: 8) {
                    Text("A tiny posture moment")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text(prompt)
                        .font(.title2.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Feet flat • shoulders relaxed • screen at eye level")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if streak > 0 {
                Label("\(streak)-day posture streak", systemImage: "sparkles")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.purple)
            }

            HStack {
                Button("Not now", action: onDismiss)
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Snooze 5 min", action: onSnooze)
                    .keyboardShortcut("s", modifiers: [])

                Button("I’m majestic", action: onComplete)
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 430, height: 285)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
