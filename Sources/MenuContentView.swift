import SwiftUI

struct MenuContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                BlobMascot(size: 46, mood: appState.isPaused ? .sleepy : .happy)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Posture Pal")
                        .font(.headline)
                    Text(statusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            HStack {
                stat(value: "\(appState.todayCheckIns)", label: "Today")
                Spacer()
                stat(value: "\(appState.streak)", label: "Day streak")
            }

            Button {
                appState.showReminderNow()
            } label: {
                Label("Check my posture now", systemImage: "figure.mind.and.body")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)

            if appState.isPaused {
                Button("Resume reminders") {
                    appState.resume()
                }
            } else {
                Menu("Pause reminders") {
                    Button("For 30 minutes") { appState.pause(minutes: 30) }
                    Button("For 1 hour") { appState.pause(minutes: 60) }
                    Button("For 2 hours") { appState.pause(minutes: 120) }
                    Button("For the rest of today") {
                        let endOfDay = Calendar.current.date(
                            bySettingHour: 23,
                            minute: 59,
                            second: 59,
                            of: Date()
                        ) ?? Date().addingTimeInterval(8 * 60 * 60)
                        appState.pause(minutes: max(1, Int(endOfDay.timeIntervalSinceNow / 60)))
                    }
                }
            }

            Divider()

            Button {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                Label("Settings…", systemImage: "gearshape")
            }

            Button("Quit Posture Pal") {
                appState.quit()
            }
            .keyboardShortcut("q")
        }
        .padding(16)
        .frame(width: 280)
    }

    private var statusText: String {
        if let pauseDescription = appState.pauseDescription {
            return pauseDescription
        }
        if let nextReminder = appState.nextReminder {
            return "Next nudge \(nextReminder.formatted(date: .omitted, time: .shortened))"
        }
        return "Keeping watch, quietly"
    }

    private func stat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
