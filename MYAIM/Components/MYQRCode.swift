import SwiftUI
import CoreImage.CIFilterBuiltins

/// Renders a QR code for the given string using CoreImage.
struct MYQRCode: View {
    let value: String
    var size: CGFloat = 160

    var body: some View {
        if let image = Self.generate(value) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .padding(MYSpacing.sm)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: MYRadius.sm, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: MYRadius.sm)
                .fill(MYColor.surfaceSecondary)
                .frame(width: size, height: size)
                .overlay(Image(systemName: "qrcode").font(.system(size: 40)).foregroundStyle(MYColor.textTertiary))
        }
    }

    private static func generate(_ string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 8, y: 8)),
              let cg = context.createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cg)
    }
}
