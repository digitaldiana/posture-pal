import Foundation

enum ReminderTone: String, CaseIterable, Identifiable {
    case warm
    case playful
    case dramatic

    var id: String { rawValue }

    var title: String {
        switch self {
        case .warm: "Warm"
        case .playful: "Playful"
        case .dramatic: "Delightfully dramatic"
        }
    }
}

enum ReminderPrompts {
    private static let warm = [
        "Quick reset: feet grounded, shoulders soft, head tall.",
        "Take one calm breath and give your spine a little space.",
        "A gentle posture check. Unclench, settle, and sit tall.",
        "Roll your shoulders back, then let them relax.",
        "Your future self appreciates this tiny reset."
    ]

    private static let playful = [
        "Posture check: return to your legendary form.",
        "Your spine has requested a tiny software update.",
        "Shoulders down. Confidence up.",
        "Plot twist: the next task is sitting gloriously.",
        "Achievement available: magnificent alignment.",
        "Your chair is supporting you. Meet it halfway."
    ]

    private static let dramatic = [
        "A posture reset! The council has spoken.",
        "Rise, noble vertebrae. Your moment has arrived.",
        "The shoulders have wandered north. Kindly send them home.",
        "Restore balance to the realm: feet flat, head tall.",
        "An epic alignment sequence begins... now."
    ]

    static func next(for tone: ReminderTone, excluding previous: String?) -> String {
        let prompts: [String]
        switch tone {
        case .warm: prompts = warm
        case .playful: prompts = playful
        case .dramatic: prompts = dramatic
        }

        let choices = prompts.filter { $0 != previous }
        return choices.randomElement() ?? prompts[0]
    }
}
