import SwiftUI

/// Loads a remote image with a skeleton while loading and a calm, category-tinted
/// fallback if the URL is missing or fails. Uses AsyncImage (URLCache-backed).
struct MYRemoteImage: View {
    let urlString: String?
    var fallbackIcon: String = "photo"
    var accent: Color = MYColor.primary

    var body: some View {
        if let urlString, let url = URL(string: urlString) {
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
