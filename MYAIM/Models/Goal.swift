import Foundation

/// A single step within a goal.
struct GoalStep: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var title: String
    var isDone: Bool
}

/// A user goal with ordered steps and computed progress.
struct Goal: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var title: String                // "إطلاق مشروعي الإلكتروني"
    var category: ServiceCategory
    var steps: [GoalStep]
    var createdAt: Date = Date()

    /// 0.0 ... 1.0
    var progress: Double {
        guard !steps.isEmpty else { return 0 }
        let done = steps.filter(\.isDone).count
        return Double(done) / Double(steps.count)
    }

    var progressPercent: Int { Int((progress * 100).rounded()) }

    var isCompleted: Bool { progress >= 1.0 && !steps.isEmpty }

    /// The next incomplete step, if any.
    var nextStep: GoalStep? { steps.first { !$0.isDone } }
}
