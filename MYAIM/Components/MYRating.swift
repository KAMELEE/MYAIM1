import SwiftUI

/// Compact rating display: ★ 4.8 · 128 تقييم
struct MYRating: View {
    let rating: Double
    var reviewsCount: Int? = nil
    var showCount: Bool = true

    var body: some View {
        HStack(spacing: MYSpacing.xs) {
            Image(systemName: "star.fill")
                .font(.system(size: 12))
                .foregroundStyle(MYColor.star)

            Text(MYFormat.rating(rating))
                .font(MYTypography.caption)
                .foregroundStyle(MYColor.textPrimary)

            if showCount, let reviewsCount {
                Text("· \(MYFormat.reviewsCount(reviewsCount))")
                    .font(MYTypography.caption)
                    .foregroundStyle(MYColor.textSecondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("التقييم \(MYFormat.rating(rating)) من 5" +
                            (reviewsCount.map { "، \($0) تقييم" } ?? ""))
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        MYRating(rating: 4.8, reviewsCount: 128)
        MYRating(rating: 5.0, showCount: false)
    }
    .padding()
    .environment(\.layoutDirection, .rightToLeft)
}
