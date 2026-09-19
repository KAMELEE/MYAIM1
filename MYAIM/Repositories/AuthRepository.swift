import Foundation

/// Authentication data access. Views/ViewModels depend on this protocol only,
/// so a real backend (REST/Firebase/Supabase) can replace the mock later
/// without touching the UI.
protocol AuthRepository {
    func login(email: String, password: String) async throws -> User
    func register(name: String, email: String, phone: String, password: String) async throws -> User
    func verifyOTP(_ code: String) async throws
    func requestPasswordReset(email: String) async throws
}

/// In-memory mock with realistic latency. Replace with a Remote implementation.
final class MockAuthRepository: AuthRepository {

    private func delay(_ seconds: Double = 0.9) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }

    func login(email: String, password: String) async throws -> User {
        try await delay()
        // Demo: any well-formed credentials succeed.
        return User(name: "أحمد", email: email, phone: "0555555555", avatarURL: nil)
    }

    func register(name: String, email: String, phone: String, password: String) async throws -> User {
        try await delay()
        return User(name: name, email: email, phone: phone, avatarURL: nil)
    }

    func verifyOTP(_ code: String) async throws {
        try await delay(0.7)
        // Demo: accept 1234 (or any 4-digit code) as valid.
        guard code.count == 4 else { throw RepositoryError.unknown("رمز التحقق غير صحيح") }
    }

    func requestPasswordReset(email: String) async throws {
        try await delay(0.7)
    }
}
