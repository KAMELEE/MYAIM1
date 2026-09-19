import SwiftUI

/// Temporary destination for screens built in a later phase.
/// Keeps navigation fully functional end-to-end today.
struct ComingSoonView: View {
    let title: String
    var systemImage: String = "hammer"
    var note: String = "تُبنى هذه الشاشة في مرحلة قادمة."

    var body: some View {
        MYEmptyState(icon: systemImage, title: title, message: note)
            .frame(maxHeight: .infinity)
            .myTabBarInset()
            .myScreenBackground()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { ComingSoonView(title: "الحجز") }
        .environment(\.layoutDirection, .rightToLeft)
}
