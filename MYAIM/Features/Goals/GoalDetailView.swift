import SwiftUI

struct GoalDetailView: View {
    @Environment(GoalsStore.self) private var store
    let goal: Goal

    /// Live goal from the store (reflects step toggles), falling back to the passed value.
    private var live: Goal { store.goal(goal.id) ?? goal }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                header
                stepsSection
            }
            .padding(MYSpacing.screen)
        }
        .myTabBarInset()
        .myScreenBackground()
        .navigationTitle("الهدف")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            HStack(spacing: MYSpacing.md) {
                Image(systemName: live.category.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(MYColor.primary)
                    .frame(width: 48, height: 48)
                    .background(MYColor.primaryTint)
                    .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(live.title)
                        .font(MYTypography.section)
                        .foregroundStyle(MYColor.textPrimary)
                    Text("\(live.progressPercent)% مكتمل")
                        .font(MYTypography.secondary)
                        .foregroundStyle(MYColor.textSecondary)
                }
                Spacer()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(MYColor.surfaceSecondary)
                    Capsule().fill(MYColor.primary)
                        .frame(width: max(0, geo.size.width * live.progress))
                }
            }
            .frame(height: 10)
            .animation(.easeOut(duration: 0.4), value: live.progress)
        }
        .myCard()
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            Text("الخطوات")
                .font(MYTypography.section)
                .foregroundStyle(MYColor.textPrimary)

            VStack(spacing: 0) {
                ForEach(live.steps) { step in
                    Button {
                        Haptics.selection()
                        store.toggleStep(goalID: live.id, stepID: step.id)
                        if live.isCompleted { Haptics.success() }
                    } label: {
                        HStack(spacing: MYSpacing.md) {
                            Image(systemName: step.isDone ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22))
                                .foregroundStyle(step.isDone ? MYColor.primary : MYColor.textTertiary)
                            Text(step.title)
                                .font(MYTypography.body)
                                .foregroundStyle(MYColor.textPrimary)
                                .strikethrough(step.isDone, color: MYColor.textTertiary)
                            Spacer()
                        }
                        .padding(.vertical, MYSpacing.md)
                        .contentShape(Rectangle())
                    }
                    if step.id != live.steps.last?.id {
                        Divider().background(MYColor.border)
                    }
                }
            }
            .padding(.horizontal, MYSpacing.lg)
            .background(MYColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                .strokeBorder(MYColor.border, lineWidth: 0.5))
        }
    }
}

#Preview {
    NavigationStack { GoalDetailView(goal: SampleData.goals[0]) }
        .environment(GoalsStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
