import Foundation

/// Shared, locale-aware formatters for the Arabic-first experience.
enum MYFormat {

    /// Arabic (Saudi) locale used across the app.
    static let arLocale = Locale(identifier: "ar_SA")

    // MARK: - Currency (ر.س)

    /// Formats a price like `450 ر.س` (no fractional zeros for whole numbers).
    /// Voice-note duration: "0:07" / "1:02".
    static func duration(_ seconds: Double) -> String {
        let total = Int(seconds.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    static func price(_ amount: Double) -> String {
        let number: String
        if amount.truncatingRemainder(dividingBy: 1) == 0 {
            number = integer(Int(amount))
        } else {
            let f = NumberFormatter()
            f.locale = arLocale
            f.numberStyle = .decimal
            f.maximumFractionDigits = 2
            number = f.string(from: NSNumber(value: amount)) ?? "\(amount)"
        }
        return "\(number) ر.س"
    }

    /// "يبدأ من 450 ر.س"
    static func startingPrice(_ amount: Double) -> String {
        "يبدأ من \(price(amount))"
    }

    // MARK: - Numbers

    static func integer(_ value: Int) -> String {
        let f = NumberFormatter()
        f.locale = arLocale
        f.numberStyle = .decimal
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    // MARK: - Rating & distance

    /// "4.8"
    static func rating(_ value: Double) -> String {
        String(format: "%.1f", value)
    }

    /// "١٢٨ تقييم" style count.
    static func reviewsCount(_ count: Int) -> String {
        "\(integer(count)) تقييم"
    }

    /// Distance: "1.2 كم" or "850 م".
    static func distance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(integer(Int(meters))) م"
        }
        let km = meters / 1000
        return String(format: "%.1f كم", km)
    }

    // MARK: - Dates

    /// "الأحد، 21 سبتمبر"
    static func longDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = arLocale
        f.dateFormat = "EEEE، d MMMM"
        return f.string(from: date)
    }

    /// "10:30 ص"
    static func time(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = arLocale
        f.timeStyle = .short
        return f.string(from: date)
    }
}
