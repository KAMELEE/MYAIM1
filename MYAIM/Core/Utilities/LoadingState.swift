import Foundation

/// Generic screen/data state used by every ViewModel so each data-driven screen
/// can render Skeleton / Loading / Loaded / Empty / Error consistently.
enum LoadingState<Value>: Equatable where Value: Equatable {
    case idle
    case loading
    case loaded(Value)
    case empty
    case failed(String)   // user-facing message

    var value: Value? {
        if case let .loaded(v) = self { return v }
        return nil
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

/// Errors surfaced by the repository layer.
enum RepositoryError: LocalizedError, Equatable {
    case network
    case notFound
    case decoding
    case unauthorized
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .network:      return "تعذر الاتصال بالخادم، تحقق من الإنترنت وحاول مجددًا."
        case .notFound:     return "العنصر المطلوب غير موجود."
        case .decoding:     return "تعذر قراءة البيانات."
        case .unauthorized: return "انتهت الجلسة، يرجى تسجيل الدخول من جديد."
        case .unknown(let m): return m.isEmpty ? "حدث خطأ غير متوقع." : m
        }
    }
}
