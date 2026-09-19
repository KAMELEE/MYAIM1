import SwiftUI

/// MY AIM — Unified typography scale (IBM Plex Sans Arabic).
///
/// Use these roles instead of ad-hoc `.font(...)` calls so every screen shares
/// one hierarchy. Weights are intentionally varied (not everything is Bold).
enum MYTypography {
    /// شاشة العنوان الرئيسي الكبير (Hero / large title)
    static let largeTitle  = Font.appFont(30, weight: .bold,     relativeTo: .largeTitle)
    /// عنوان صفحة
    static let pageTitle   = Font.appFont(24, weight: .bold,     relativeTo: .title)
    /// عنوان قسم
    static let section     = Font.appFont(19, weight: .semibold, relativeTo: .title2)
    /// عنوان بطاقة
    static let cardTitle   = Font.appFont(16, weight: .semibold, relativeTo: .headline)
    /// نص رئيسي
    static let body        = Font.appFont(15, weight: .regular,  relativeTo: .body)
    /// نص ثانوي
    static let secondary   = Font.appFont(14, weight: .regular,  relativeTo: .subheadline)
    /// وصف / تفاصيل صغيرة
    static let description  = Font.appFont(13, weight: .regular,  relativeTo: .footnote)
    /// Caption
    static let caption     = Font.appFont(12, weight: .medium,   relativeTo: .caption)
    /// نص الأزرار
    static let button      = Font.appFont(16, weight: .semibold, relativeTo: .headline)
    /// شريط التنقل السفلي
    static let navigation  = Font.appFont(11, weight: .medium,   relativeTo: .caption2)
}

// MARK: - Convenience view modifiers

extension View {
    /// Apply a MY AIM typography role plus a foreground color in one call.
    func myFont(_ font: Font, color: Color = MYColor.textPrimary) -> some View {
        self.font(font).foregroundStyle(color)
    }
}
