import SwiftUI

/// Goal card: title, animated progress, percent, next step, and a follow button.
/// Kept simple — not a dashboard.
struct MYGoalCard: View {
    let goal: Goal
    var showsNextStep: Bool = true
    var onContinue: (() -> Void)? = nil

    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            HStack(spacing: MYSpacing.sm) {
                Image(systemName: goal.category.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(MYColor.primary)
                    .frame(width: 34, height: 34)
                    .background(MYColor.primaryTint)
                    .clipShape(RoundedRectangle(cornerRadius: MYRadius.sm, style: .continuous))

                Text(goal.title)
                    .font(MYTypography.cardTitle)
                    .foregroundStyle(MYColor.textPrimary)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Text("\(goal.progressPercent)%")
                    .font(MYTypography.cardTitle)
                    .foregroundStyle(MYColor.primary)
            }

            progressBar

            if showsNextStep, let next = goal.nextStep {
                HStack(spacing: MYSpacing.xs) {
                    Text("الخطوة التالية:")
                        .font(MYTypography.description)
                        .foregroundStyle(MYColor.textSecondary)
                    Text(next.title)
                        .font(MYTypography.secondary)
                        .foregroundStyle(MYColor.textPrimary)
                        .lineLimit(1)
                }
            }

            if let onContinue {
                MYButton(title: "متابعة الهدف", style: .secondary, action: onContinue)
            }
        }
        .myCard()
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { animatedProgress = goal.progress }
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(MYColor.surfaceSecondary)
                Capsule()
                    .fill(MYColor.primary)
                    .frame(width: max(0, geo.size.width * animatedProgress))
            }
        }
        .frame(height: 8)
        .accessibilityElement()
        .accessibilityLabel("تقدّم الهدف \(goal.progressPercent) بالمئة")
    }
}

#Preview {
    VStack(spacing: 16) {
        MYGoalCard(goal: .preview, onContinue: {})
        MYGoalCard(goal: SampleData.goals[1], showsNextStep: false)
    }
    .padding()
    .myScreenBackground()
    .environment(\.layoutDirection, .rightToLeft)
}
