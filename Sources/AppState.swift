import AppKit
import Combine
import ServiceManagement

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var intervalMinutes: Int {
        didSet {
            defaults.set(intervalMinutes, forKey: Keys.interval)
            reschedule()
        }
    }
    @Published var activeStartHour: Int {
        didSet { defaults.set(activeStartHour, forKey: Keys.startHour) }
    }
    @Published var activeEndHour: Int {
        didSet { defaults.set(activeEndHour, forKey: Keys.endHour) }
    }
    @Published var soundEnabled: Bool {
        didSet { defaults.set(soundEnabled, forKey: Keys.sound) }
    }
    @Published var tone: ReminderTone {
        didSet { defaults.set(tone.rawValue, forKey: Keys.tone) }
    }
    @Published var launchAtLogin = false
    @Published var launchAtLoginError: String?
    @Published private(set) var pausedUntil: Date?
    @Published private(set) var nextReminder: Date?
    @Published private(set) var streak: Int
    @Published private(set) var todayCheckIns: Int

    private let defaults = UserDefaults.standard
    private var timer: Timer?
    private var reminderWindow: ReminderWindowController?
    private var lastPrompt: String?
    private var hasStarted = false

    var isPaused: Bool {
        guard let pausedUntil else { return false }
        return pausedUntil > Date()
    }

    var pauseDescription: String? {
        guard let pausedUntil, pausedUntil > Date() else { return nil }
        return "Paused until \(pausedUntil.formatted(date: .omitted, time: .shortened))"
    }

    private init() {
        defaults.register(defaults: [
            Keys.interval: 60,
            Keys.startHour: 9,
            Keys.endHour: 18,
            Keys.sound: true,
            Keys.tone: ReminderTone.playful.rawValue
        ])

        intervalMinutes = defaults.integer(forKey: Keys.interval)
        activeStartHour = defaults.integer(forKey: Keys.startHour)
        activeEndHour = defaults.integer(forKey: Keys.endHour)
        soundEnabled = defaults.bool(forKey: Keys.sound)
        tone = ReminderTone(rawValue: defaults.string(forKey: Keys.tone) ?? "") ?? .playful
        pausedUntil = defaults.object(forKey: Keys.pausedUntil) as? Date
        streak = defaults.integer(forKey: Keys.streak)
        todayCheckIns = 0

        refreshDailyCheckIns()
        refreshLaunchAtLogin()
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        clearExpiredPause()
        scheduleNextReminder()
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func showReminderNow() {
        let prompt = ReminderPrompts.next(for: tone, excluding: lastPrompt)
        lastPrompt = prompt

        reminderWindow?.close()
        reminderWindow = ReminderWindowController(
            prompt: prompt,
            streak: streak,
            onComplete: { [weak self] in self?.completeCheckIn() },
            onSnooze: { [weak self] in self?.snooze(minutes: 5) },
            onDismiss: { [weak self] in self?.dismissReminder() }
        )
        reminderWindow?.show()

        if soundEnabled {
            NSSound(named: "Glass")?.play()
        }
    }

    func pause(minutes: Int) {
        let date = Date().addingTimeInterval(TimeInterval(minutes * 60))
        pausedUntil = date
        defaults.set(date, forKey: Keys.pausedUntil)
        nextReminder = nil
        reminderWindow?.close()
        reminderWindow = nil
        objectWillChange.send()
    }

    func resume() {
        pausedUntil = nil
        defaults.removeObject(forKey: Keys.pausedUntil)
        scheduleNextReminder()
        objectWillChange.send()
    }

    func snooze(minutes: Int) {
        reminderWindow?.close()
        reminderWindow = nil
        nextReminder = Date().addingTimeInterval(TimeInterval(minutes * 60))
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            launchAtLogin = enabled
            launchAtLoginError = nil
        } catch {
            refreshLaunchAtLogin()
            launchAtLoginError = error.localizedDescription
        }
    }

    func quit() {
        NSApplication.shared.terminate(nil)
    }

    private func tick() {
        clearExpiredPause()
        guard !isPaused, isWithinActiveHours else { return }
        guard let nextReminder else {
            scheduleNextReminder()
            return
        }
        if Date() >= nextReminder {
            showReminderNow()
            scheduleNextReminder()
        }
    }

    private func completeCheckIn() {
        updateStreak()
        reminderWindow?.close()
        reminderWindow = nil
        scheduleNextReminder()
    }

    private func dismissReminder() {
        reminderWindow?.close()
        reminderWindow = nil
        scheduleNextReminder()
    }

    private func reschedule() {
        guard hasStarted else { return }
        scheduleNextReminder()
    }

    private func scheduleNextReminder() {
        guard !isPaused else {
            nextReminder = nil
            return
        }
        nextReminder = Date().addingTimeInterval(TimeInterval(intervalMinutes * 60))
    }

    private func clearExpiredPause() {
        guard let pausedUntil, pausedUntil <= Date() else { return }
        self.pausedUntil = nil
        defaults.removeObject(forKey: Keys.pausedUntil)
        scheduleNextReminder()
    }

    private var isWithinActiveHours: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        if activeStartHour == activeEndHour {
            return true
        }
        if activeStartHour < activeEndHour {
            return hour >= activeStartHour && hour < activeEndHour
        }
        return hour >= activeStartHour || hour < activeEndHour
    }

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDate = defaults.object(forKey: Keys.lastCheckInDate) as? Date

        if let lastDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            if lastDay == today {
                todayCheckIns += 1
            } else if calendar.date(byAdding: .day, value: 1, to: lastDay) == today {
                streak += 1
                todayCheckIns = 1
            } else {
                streak = 1
                todayCheckIns = 1
            }
        } else {
            streak = 1
            todayCheckIns = 1
        }

        defaults.set(Date(), forKey: Keys.lastCheckInDate)
        defaults.set(streak, forKey: Keys.streak)
        defaults.set(todayCheckIns, forKey: Keys.todayCheckIns)
        defaults.set(today, forKey: Keys.todayCheckInsDate)
    }

    private func refreshDailyCheckIns() {
        let calendar = Calendar.current
        let savedDay = defaults.object(forKey: Keys.todayCheckInsDate) as? Date
        if let savedDay, calendar.isDateInToday(savedDay) {
            todayCheckIns = defaults.integer(forKey: Keys.todayCheckIns)
        } else {
            todayCheckIns = 0
            defaults.set(0, forKey: Keys.todayCheckIns)
            defaults.set(calendar.startOfDay(for: Date()), forKey: Keys.todayCheckInsDate)
        }
    }

    private func refreshLaunchAtLogin() {
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }

    private enum Keys {
        static let interval = "intervalMinutes"
        static let startHour = "activeStartHour"
        static let endHour = "activeEndHour"
        static let sound = "soundEnabled"
        static let tone = "reminderTone"
        static let pausedUntil = "pausedUntil"
        static let streak = "streak"
        static let lastCheckInDate = "lastCheckInDate"
        static let todayCheckIns = "todayCheckIns"
        static let todayCheckInsDate = "todayCheckInsDate"
    }
}
