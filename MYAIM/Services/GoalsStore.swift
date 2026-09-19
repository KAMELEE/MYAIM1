import SwiftUI
import Observation

/// App-wide, mutable goals store (interactive: toggle steps, add goals).
/// Seeded from SampleData; persistence via SwiftData can replace this later.
@Observable
final class GoalsStore {
    var goals: [Goal]

    init(goals: [Goal] = SampleData.goals) {
        self.goals = goals
    }

    var current: [Goal] { goals.filter { !$0.isCompleted } }
    var completed: [Goal] { goals.filter { $0.isCompleted } }

    func add(_ goal: Goal) {
        goals.insert(goal, at: 0)
    }

    func toggleStep(goalID: UUID, stepID: UUID) {
        guard let gIdx = goals.firstIndex(where: { $0.id == goalID }),
              let sIdx = goals[gIdx].steps.firstIndex(where: { $0.id == stepID }) else { return }
        goals[gIdx].steps[sIdx].isDone.toggle()
    }

    func goal(_ id: UUID) -> Goal? { goals.first { $0.id == id } }
}
