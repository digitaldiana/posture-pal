import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    private let intervals = [10, 15, 20, 30, 45, 60]

    var body: some View {
        Form {
            Section("Reminder rhythm") {
                Picker("Remind me every", selection: $appState.intervalMinutes) {
                    ForEach(intervals, id: \.self) { minutes in
                        Text("\(minutes) minutes").tag(minutes)
                    }
                }

                Picker("Personality", selection: $appState.tone) {
                    ForEach(ReminderTone.allCases) { tone in
                        Text(tone.title).tag(tone)
                    }
                }

                Toggle("Play a gentle sound", isOn: $appState.soundEnabled)
            }

            Section("Active hours") {
                Picker("Start", selection: $appState.activeStartHour) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text(hourLabel(hour)).tag(hour)
                    }
                }

                Picker("Finish", selection: $appState.activeEndHour) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text(hourLabel(hour)).tag(hour)
                    }
                }

                Text("Choose the same start and finish time for all-day reminders.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("App") {
                Toggle(
                    "Launch Posture Pal at login",
                    isOn: Binding(
                        get: { appState.launchAtLogin },
                        set: { appState.setLaunchAtLogin($0) }
                    )
                )

                if let error = appState.launchAtLoginError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Text("Your preferences and streak stay entirely on this Mac.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 480, height: 440)
    }

    private func hourLabel(_ hour: Int) -> String {
        let date = Calendar.current.date(
            bySettingHour: hour,
            minute: 0,
            second: 0,
            of: Date()
        ) ?? Date()
        return date.formatted(date: .omitted, time: .shortened)
    }
}
