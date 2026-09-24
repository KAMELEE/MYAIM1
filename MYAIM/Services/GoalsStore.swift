import SwiftUI
import Observation

/// App-wide, mutable goals store (interactive: toggle steps, add goals).
///
/// - DEMO/preview builds: seeded from SampleData, purely in-memory.
/// - Production builds: loads the signed-in user's goals from Firestore and
///   writes every add/toggle through, so progress survives reinstalls.
@MainActor
@Observable
final class GoalsStore {
    var goals: [Goal]

    private let repo: GoalRepository?

    var current: [Goal] { goals.filter { !$0.isCompleted } }
    var completed: [Goal] { goals.filter { $0.isCompleted } }

    init(goals: [Goal]? = nil, repo: GoalRepository? = nil) {
        #if DEMO
        self.goals = goals ?? SampleData.goals
        self.repo = repo
        #else
        self.repo = repo ?? AppRepositories.goals()
        self.goals = goals ?? []
        if goals == nil {
            Task { await reload() }
        }
        #endif
    }

    /// Re-fetches the signed-in user's goals (call after login).
    func reload() async {
        guard let repo else { return }
        do {
            goals = try await repo.userGoals()
        } catch {
            // Keep showing what we have; Firestore errors surface on screens.
        }
    }

    func add(_ goal: Goal) {
        goals.insert(goal, at: 0)
        guard let repo else { return }
        Task { try? await repo.add(goal) }
    }

    func toggleStep(goalID: UUID, stepID: UUID) {
        guard let gIdx = goals.firstIndex(where: { $0.id == goalID }),
              let sIdx = goals[gIdx].steps.firstIndex(where: { $0.id == stepID }) else { return }
        goals[gIdx].steps[sIdx].isDone.toggle()
        if let repo {
            Task { try? await repo.updateSteps(goals[gIdx]) }
        }
    }

    func goal(_ id: UUID) -> Goal? { goals.first { $0.id == id } }
}
