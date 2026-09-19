import UIKit

/// Lightweight haptic feedback helper.
/// Usage: `Haptics.light()`, `Haptics.success()`, `Haptics.selection()`.
enum Haptics {
    static func light() {
        let g = UIImpactFeedbackGenerator(style: .light)
        g.prepare(); g.impactOccurred()
    }

    static func medium() {
        let g = UIImpactFeedbackGenerator(style: .medium)
        g.prepare(); g.impactOccurred()
    }

    static func soft() {
        let g = UIImpactFeedbackGenerator(style: .soft)
        g.prepare(); g.impactOccurred()
    }

    static func selection() {
        let g = UISelectionFeedbackGenerator()
        g.prepare(); g.selectionChanged()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
