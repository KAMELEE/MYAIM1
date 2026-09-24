import SwiftUI
import Observation

@MainActor
@Observable
final class AuthViewModel {
    private let repo: AuthRepository

    /// Called on successful authentication (login or OTP). Wired by AuthFlowView.
    var onAuthenticated: ((User) -> Void)?

    // Shared UI state
    var isLoading = false
    var errorMessage: String?
    var fieldErrors: [String: String] = [:]

    // Login
    var loginEmail = ""
    var loginPassword = ""

    // Register
    var regName = ""
    var regEmail = ""
    var regPhone = ""
    var regPassword = ""

    // Forgot
    var forgotEmail = ""
    var resetSent = false

    /// User created during register, pending OTP verification.
    private(set) var pendingUser: User?

    init(repo: AuthRepository? = nil) {
        self.repo = repo ?? Self.defaultRepository()
    }

    /// Demo/preview builds (CI → Appetize) use the in-memory mock so the whole
    /// app is explorable without a configured backend; production uses Firebase.
    private static func defaultRepository() -> AuthRepository {
        #if DEMO
        MockAuthRepository()
        #else
        FirebaseAuthRepository()
        #endif
    }

    // MARK: - Login
    func login() async {
        fieldErrors = [:]
        fieldErrors["loginEmail"] = Validation.email(loginEmail)
        fieldErrors["loginPassword"] = Validation.password(loginPassword)
        if hasErrors { return }

        await run {
            let user = try await self.repo.login(email: self.loginEmail, password: self.loginPassword)
            Haptics.success()
            self.onAuthenticated?(user)
        }
    }

    // MARK: - Register (returns true to proceed to OTP)
    func register() async -> Bool {
        fieldErrors = [:]
        fieldErrors["regName"] = Validation.name(regName)
        fieldErrors["regEmail"] = Validation.email(regEmail)
        fieldErrors["regPhone"] = Validation.saudiPhone(regPhone)
        fieldErrors["regPassword"] = Validation.password(regPassword)
        if hasErrors { return false }

        return await run {
            let user = try await self.repo.register(
                name: self.regName, email: self.regEmail,
                phone: self.regPhone, password: self.regPassword
            )
            self.pendingUser = user
            Haptics.success()
        }
    }

    // MARK: - OTP
    func verifyOTP(_ code: String) async -> Bool {
        errorMessage = nil
        if let e = Validation.otp(code) { errorMessage = e; return false }

        return await run {
            try await self.repo.verifyOTP(code)
            if let user = self.pendingUser {
                Haptics.success()
                self.onAuthenticated?(user)
            }
        }
    }

    // MARK: - Forgot password
    func requestReset() async {
        fieldErrors = [:]
        fieldErrors["forgotEmail"] = Validation.email(forgotEmail)
        if hasErrors { return }

        _ = await run {
            try await self.repo.requestPasswordReset(email: self.forgotEmail)
            self.resetSent = true
            Haptics.success()
        }
    }

    // MARK: - Helpers
    private var hasErrors: Bool {
        // Assigning a nil validator result removes the key, so any remaining
        // entries are real errors.
        !fieldErrors.isEmpty
    }

    /// Runs an async operation with loading + error handling. Returns success.
    @discardableResult
    private func run(_ op: @escaping () async throws -> Void) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await op()
            return true
        } catch {
            errorMessage = (error as? RepositoryError)?.errorDescription ?? "حدث خطأ، حاول مرة أخرى."
            Haptics.error()
            return false
        }
    }
}
