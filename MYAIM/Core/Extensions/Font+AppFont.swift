import SwiftUI

/// App font family: IBM Plex Sans Arabic.
///
/// Drop the .ttf files into `Resources/Fonts` and list them in Info.plist under
/// `UIAppFonts` (already configured). If the fonts are missing at runtime,
/// `Font.custom` gracefully falls back to the system font, so the app still runs.
///
/// To swap the whole app to a different font later, change only `fontName` here.
enum MYFontWeight {
    case regular, medium, semibold, bold

    var fontName: String {
        switch self {
        case .regular:  return "IBMPlexSansArabic-Regular"
        case .medium:   return "IBMPlexSansArabic-Medium"
        case .semibold: return "IBMPlexSansArabic-SemiBold"
        case .bold:     return "IBMPlexSansArabic-Bold"
        }
    }
}

extension Font {
    /// App font scaled with Dynamic Type via a relative text style.
    static func appFont(_ size: CGFloat,
                        weight: MYFontWeight = .regular,
                        relativeTo textStyle: Font.TextStyle = .body) -> Font {
        .custom(weight.fontName, size: size, relativeTo: textStyle)
    }
}
