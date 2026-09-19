import CoreGraphics

/// MY AIM — Spacing scale (4pt base grid). Use these instead of magic numbers.
enum MYSpacing {
    static let xxs: CGFloat = 2
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 16   // default screen horizontal padding
    static let xl:  CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32

    /// Standard screen edge padding.
    static let screen: CGFloat = 16
    /// Vertical gap between page sections.
    static let section: CGFloat = 24
}

/// MY AIM — Corner radius scale.
enum MYRadius {
    static let xs:  CGFloat = 6
    static let sm:  CGFloat = 10
    static let md:  CGFloat = 14   // default card radius
    static let lg:  CGFloat = 18
    static let xl:  CGFloat = 24
    static let pill: CGFloat = 999
}
