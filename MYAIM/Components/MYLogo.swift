import SwiftUI

/// The MY AIM logo mark (from Assets `Logo`). Falls back to a monogram tile
/// if the asset is missing so previews/build never break.
struct MYLogo: View {
    var size: CGFloat = 40
    /// When true, shows the mark inside a white rounded tile (good on colored bars).
    var boxed: Bool = true

    var body: some View {
        Group {
            if UIImage(named: "Logo") != nil {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.14)
            } else {
                Text("MA")
                    .font(.system(size: size * 0.42, weight: .heavy))
                    .foregroundStyle(MYColor.primary)
            }
        }
        .frame(width: size, height: size)
        .background(boxed ? AnyShapeStyle(Color.white) : AnyShapeStyle(Color.clear))
        .clipShape(RoundedRectangle(cornerRadius: size * 0.28, style: .continuous))
        .overlay(
            boxed ?
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .strokeBorder(MYColor.border, lineWidth: 0.5) : nil
        )
        .accessibilityLabel("شعار MY AIM")
    }
}

#Preview {
    HStack(spacing: 20) {
        MYLogo(size: 56)
        MYLogo(size: 40, boxed: false)
    }
    .padding()
    .myScreenBackground()
}
