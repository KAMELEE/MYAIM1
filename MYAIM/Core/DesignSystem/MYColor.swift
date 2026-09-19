import SwiftUI

/// MY AIM — Central color system.
///
/// ┌─────────────────────────────────────────────────────────────────────┐
/// │  THIS IS THE SINGLE SOURCE OF TRUTH FOR BRAND IDENTITY COLORS.        │
/// │  To match the official MY AIM logo, change ONLY the values inside     │
/// │  `Brand` below. Every screen, component and control reads from here,  │
/// │  so the whole app re-themes with no other edits.                      │
/// │                                                                       │
/// │  Identity = the MY AIM logo purple, used with restraint:              │
/// │  SOLID colors only — no gradients, no glow (no "AI" look).            │
/// │  Purple appears in controls/accents; surfaces stay neutral.           │
/// └─────────────────────────────────────────────────────────────────────┘
enum MYColor {

    // MARK: - Raw brand palette (extracted from the MY AIM logo)
    private enum Brand {
        // Primary identity color — logo purple
        static let primary       = "#5B3FBF"   // MY AIM logo violet
        static let primaryDark   = "#46309A"   // pressed / emphasis
        static let primaryLight  = "#9B85F0"   // lighter tint for accents on dark bg

        // Subtle brand tint used behind selected states / chips (light mode)
        static let primaryTintLight = "#EEEAFB"
        // Same idea for dark mode (a dark, desaturated brand surface)
        static let primaryTintDark  = "#251E44"
    }

    // MARK: - Brand
    static let primary = Color(uiColor: UIColor(
        light: UIColor(hex: Brand.primary),
        dark:  UIColor(hex: Brand.primaryLight)
    ))
    static let primaryDark  = Color(hex: Brand.primaryDark)
    static let primaryLight = Color(hex: Brand.primaryLight)

    /// Soft brand-tinted surface (selected chips, highlights).
    static let primaryTint = Color(uiColor: UIColor(
        light: UIColor(hex: Brand.primaryTintLight),
        dark:  UIColor(hex: Brand.primaryTintDark)
    ))

    /// Foreground color to use ON TOP of `primary` (buttons, badges).
    static let onPrimary = Color.white

    // MARK: - Backgrounds & surfaces
    static let background = Color(uiColor: UIColor(
        light: UIColor(hex: "#F6F7F9"),
        dark:  UIColor(hex: "#0E1013")
    ))

    /// Card / sheet / grouped content surface.
    static let surface = Color(uiColor: UIColor(
        light: UIColor(hex: "#FFFFFF"),
        dark:  UIColor(hex: "#191C21")
    ))

    /// A slightly raised surface (search bars, secondary fills).
    static let surfaceSecondary = Color(uiColor: UIColor(
        light: UIColor(hex: "#EFF1F4"),
        dark:  UIColor(hex: "#22262C")
    ))

    // MARK: - Text
    static let textPrimary = Color(uiColor: UIColor(
        light: UIColor(hex: "#14181F"),
        dark:  UIColor(hex: "#F4F5F7")
    ))
    static let textSecondary = Color(uiColor: UIColor(
        light: UIColor(hex: "#6B7280"),
        dark:  UIColor(hex: "#9AA1AC")
    ))
    static let textTertiary = Color(uiColor: UIColor(
        light: UIColor(hex: "#9CA3AF"),
        dark:  UIColor(hex: "#6B727D")
    ))

    // MARK: - Border / separators
    static let border = Color(uiColor: UIColor(
        light: UIColor(hex: "#E5E7EB"),
        dark:  UIColor(hex: "#2A2E36")
    ))

    // MARK: - Semantic
    static let success = Color(uiColor: UIColor(
        light: UIColor(hex: "#2E9E5B"),
        dark:  UIColor(hex: "#41B673")
    ))
    static let warning = Color(uiColor: UIColor(
        light: UIColor(hex: "#E0932B"),
        dark:  UIColor(hex: "#F0AE4E")
    ))
    static let error = Color(uiColor: UIColor(
        light: UIColor(hex: "#D64545"),
        dark:  UIColor(hex: "#E86A6A")
    ))

    /// Rating star fill.
    static let star = Color(hex: "#F5A623")
}
