import Foundation

/// Lightweight input validators (Arabic messages). Return nil when valid,
/// otherwise a user-facing error string.
enum Validation {

    static func name(_ value: String) -> String? {
        let v = value.trimmingCharacters(in: .whitespaces)
        if v.isEmpty { return "الاسم مطلوب" }
        if v.count < 2 { return "الاسم قصير جدًا" }
        return nil
    }

    static func email(_ value: String) -> String? {
        let v = value.trimmingCharacters(in: .whitespaces)
        if v.isEmpty { return "البريد الإلكتروني مطلوب" }
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        if v.range(of: pattern, options: .regularExpression) == nil {
            return "صيغة البريد الإلكتروني غير صحيحة"
        }
        return nil
    }

    /// Saudi mobile: 05XXXXXXXX or +9665XXXXXXXX / 9665XXXXXXXX.
    static func saudiPhone(_ value: String) -> String? {
        let v = value.trimmingCharacters(in: .whitespaces)
        if v.isEmpty { return "رقم الجوال مطلوب" }
        let pattern = "^(05\\d{8}|(\\+?966)5\\d{8})$"
        if v.range(of: pattern, options: .regularExpression) == nil {
            return "رقم جوال سعودي غير صحيح (مثال: 05XXXXXXXX)"
        }
        return nil
    }

    static func password(_ value: String) -> String? {
        if value.isEmpty { return "كلمة المرور مطلوبة" }
        if value.count < 6 { return "كلمة المرور 6 أحرف على الأقل" }
        return nil
    }

    static func otp(_ value: String, length: Int = 4) -> String? {
        if value.count != length { return "أدخل رمز التحقق كاملاً" }
        if value.range(of: "^\\d+$", options: .regularExpression) == nil { return "رمز غير صحيح" }
        return nil
    }
}
