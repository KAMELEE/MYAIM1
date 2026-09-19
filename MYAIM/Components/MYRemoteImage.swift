import SwiftUI

/// Displays an image with graceful fallbacks:
/// 1) a bundled asset (`assetName`) — real photo shipped with the app,
/// 2) a remote URL via AsyncImage (skeleton while loading),
/// 3) a calm, category-tinted icon placeholder.
struct MYRemoteImage: View {
    var assetName: String? = nil
    var urlString: String? = nil
    var fallbackIcon: String = "photo"
    var accent: Color = MYColor.primary

    var body: some View {
        if let assetName, UIImage(named: assetName) != nil {
            Image(assetName)
                .resizable()
                .scaledToFill()
        } else if let urlString, let url = URL(string: urlString) {
            AsyncImage(url: url, transaction: Transaction(animation: .easeOut(duration: 0.2))) { phase in
                switch phase {
                case .empty:
                    MYSkeleton(cornerRadius: 0)
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    fallback
                @unknown default:
                    fallback
                }
            }
        } else {
            fallback
        }
    }

    private var fallback: some View {
        ZStack {
            accent.opacity(0.12)
            Image(systemName: fallbackIcon)
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(accent.opacity(0.55))
        }
    }
}
