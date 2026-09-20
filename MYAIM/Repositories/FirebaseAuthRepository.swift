import Foundation
import FirebaseAuth

/// Real authentication via Firebase.
/// - Registration verifies the phone number (OTP via Firebase Phone Auth).
/// - Email/password login uses Firebase Email/Password (enable it in the console).
///
/// For development, add Test Phone Numbers in Firebase Console
/// (Authentication ▸ Sign-in method ▸ Phone ▸ Numbers for testing) — no real SMS.
final class FirebaseAuthRepository: AuthRepository {

    /// verificationID from the most recent phone verification (used by verifyOTP).
    private var verificationID: String?
    private var pendingName: String?
    private var pendingEmail: String?
    private var pendingPhone: String?

    // MARK: - Login (email/password)
    func login(email: String, password: String) async throws -> User {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return user(from: result.user, fallbackName: nil, fallbackEmail: email, fallbackPhone: "")
        } catch {
            throw map(error)
        }
    }

    // MARK: - Register → sends phone OTP
    func register(name: String, email: String, phone: String, password: String) async throws -> User {
        pendingName = name; pendingEmail = email; pendingPhone = phone
        let e164 = Self.normalizePhone(phone)
        do {
            let id = try await PhoneAuthProvider.provider().verifyPhoneNumber(e164, uiDelegate: nil)
            verificationID = id
            return User(name: name, email: email, phone: phone, avatarURL: nil)
        } catch {
            throw map(error)
        }
    }

    // MARK: - Verify OTP → signs in
    func verifyOTP(_ code: String) async throws {
        guard let verificationID else { throw RepositoryError.unknown("لم يتم إرسال رمز التحقق.") }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID,
                                                                 verificationCode: code)
        do {
            _ = try await Auth.auth().signIn(with: credential)
        } catch {
            throw RepositoryError.unknown("رمز التحقق غير صحيح.")
        }
    }

    // MARK: - Password reset
    func requestPasswordReset(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw map(error)
        }
    }

    // MARK: - Helpers
    private func user(from fbUser: FirebaseAuth.User, fallbackName: String?,
                      fallbackEmail: String, fallbackPhone: String) -> User {
        User(name: fbUser.displayName ?? pendingName ?? fallbackName ?? "مستخدم",
             email: fbUser.email ?? fallbackEmail,
             phone: fbUser.phoneNumber ?? pendingPhone ?? fallbackPhone,
             avatarURL: fbUser.photoURL?.absoluteString)
    }

    /// "05XXXXXXXX" → "+9665XXXXXXXX"; passes through already-normalized numbers.
    static func normalizePhone(_ raw: String) -> String {
        let digits = raw.filter { $0.isNumber || $0 == "+" }
        if digits.hasPrefix("+") { return digits }
        if digits.hasPrefix("05") { return "+966" + digits.dropFirst() }   // drop leading 0
        if digits.hasPrefix("966") { return "+" + digits }
        if digits.hasPrefix("5") { return "+966" + digits }
        return digits
    }

    private func map(_ error: Error) -> RepositoryError {
        let ns = error as NSError
        if ns.domain == NSURLErrorDomain { return .network }
        return .unknown(ns.localizedDescription)
    }
}
