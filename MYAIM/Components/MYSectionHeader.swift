import SwiftUI

/// Section header used on Home / Discover: title on one side, optional "عرض الكل".
struct MYSectionHeader: View {
    let title: String
    var actionTitle: String? = "عرض الكل"
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(MYTypography.section)
                .foregroundStyle(MYColor.textPrimary)

            Spacer(minLength: MYSpacing.sm)

            if let actionTitle, let onAction {
                Button(action: {
                    Haptics.selection()
                    onAction()
                }) {
                    Text(actionTitle)
                        .font(MYTypography.secondary)
                        .foregroundStyle(MYColor.primary)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        MYSectionHeader(title: "قريب منك", onAction: {})
        MYSectionHeader(title: "موصى لك", actionTitle: nil)
    }
    .padding()
    .environment(\.layoutDirection, .rightToLeft)
}
