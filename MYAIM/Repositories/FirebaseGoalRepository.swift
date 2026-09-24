import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Firestore-backed goals, scoped to the signed-in user.
final class FirestoreGoalRepository: GoalRepository {

    private let db = Firestore.firestore()
    private static let collection = "goals"

    private var userId: String? { Auth.auth().currentUser?.uid }

    // MARK: - Reads

    func userGoals() async throws -> [Goal] {
        guard let uid = userId else { return [] }
        let snap = try await db.collection(Self.collection)
            .whereField("userId", isEqualTo: uid)
            .getDocuments()
        // Sorted client-side: avoids a composite-index requirement in Firestore.
        return snap.documents
            .compactMap { FirestoreMappers.goal(from: $0.data(), id: $0.documentID) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func currentGoals() async throws -> [Goal] {
        try await userGoals().filter { !$0.isCompleted }
    }

    func allGoals() async throws -> [Goal] {
        try await userGoals()
    }

    // MARK: - Writes (GoalsStore persistence)

    @discardableResult
    func add(_ goal: Goal) async throws -> Goal {
        guard let uid = userId else { return goal }
        try await db.collection(Self.collection)
            .document(goal.id.uuidString)
            .setData(FirestoreMappers.goalData(userId: uid, goal: goal))
        return goal
    }

    func updateSteps(_ goal: Goal) async throws {
        guard let uid = userId else { return }
        try await db.collection(Self.collection)
            .document(goal.id.uuidString)
            .updateData(["steps": goal.steps.map { ["title": $0.title, "isDone": $0.isDone] }])
    }
}
