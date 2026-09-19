import SwiftUI

/// Price display in SAR. Two styles: inline value or "يبدأ من …".
struct MYPrice: View {
    let amount: Double
    var showsStartingPrefix: Bool = true
    var emphasized: Bool = true

    var body: some View {
        HStack(spacing: MYSpacing.xxs) {
            if showsStartingPrefix {
                Text("يبدأ من")
                    .font(MYTypography.caption)
                    .foregroundStyle(MYColor.textSecondary)
            }
            Text(MYFormat.price(amount))
                .font(emphasized ? MYTypography.cardTitle : MYTypography.secondary)
                .foregroundStyle(emphasized ? MYColor.primary : MYColor.textPrimary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel((showsStartingPrefix ? "يبدأ من " : "") + MYFormat.price(amount))
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        MYPrice(amount: 450)
        MYPrice(amount: 1200, showsStartingPrefix: false, emphasized: false)
    }
    .padding()
    .environment(\.layoutDirection, .rightToLeft)
}
