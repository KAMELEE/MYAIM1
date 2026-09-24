import Foundation

/// Goals data access.
///
/// `userGoals/add/updateSteps` power GoalsStore persistence in production;
/// the mock default implementations keep DEMO/preview behavior unchanged.
protocol GoalRepository {
    func currentGoals() async throws -> [Goal]
    func allGoals() async throws -> [Goal]

    /// Goals belonging to the signed-in user (empty when signed out).
    func userGoals() async throws -> [Goal]
    /// Persists a newly created goal.
    @discardableResult
    func add(_ goal: Goal) async throws -> Goal
    /// Persists the goal's steps after a toggle.
    func updateSteps(_ goal: Goal) async throws
}

// Default implementations so mocks/previews need no extra code.
extension GoalRepository {
    func userGoals() async throws -> [Goal] { try await allGoals() }

    @discardableResult
    func add(_ goal: Goal) async throws -> Goal { goal }

    func updateSteps(_ goal: Goal) async throws {}
}

final class MockGoalRepository: GoalRepository {
    private func delay(_ seconds: Double = 0.5) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }

    func currentGoals() async throws -> [Goal] {
        try await delay()
        return SampleData.goals.filter { !$0.isCompleted }
    }

    func allGoals() async throws -> [Goal] {
        try await delay()
        return SampleData.goals
    }
}
