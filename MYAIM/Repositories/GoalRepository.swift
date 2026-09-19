import Foundation

/// Goals data access.
protocol GoalRepository {
    func currentGoals() async throws -> [Goal]
    func allGoals() async throws -> [Goal]
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
