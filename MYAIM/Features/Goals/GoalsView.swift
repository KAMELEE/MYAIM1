import SwiftUI

struct GoalsView: View {
    @Environment(Router.self) private var router
    @Environment(GoalsStore.self) private var store
    @State private var showCompleted = false

    private var goals: [Goal] { showCompleted ? store.completed : store.current }

    var body: some View {
        VStack(spacing: 0) {
            segmented.padding(MYSpacing.screen)
            Divider().background(MYColor.border)

            if goals.isEmpty {
                MYEmptyState(icon: "target",
                             title: showCompleted ? "لا أهداف مكتملة بعد" : "ابدأ بتحديد هدفك",
                             message: "حدّد هدفًا وتابع تقدمك خطوة بخطوة نحو تحقيقه.",
                             actionTitle: showCompleted ? nil : "إنشاء هدف",
                             onAction: showCompleted ? nil : { router.push(.createGoal) })
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: MYSpacing.md) {
                        ForEach(goals) { goal in
                            MYGoalCard(goal: goal,
                                       showsNextStep: !goal.isCompleted,
                                       onContinue: { router.push(.goalDetail(goal)) })
                        }
                    }
                    .padding(MYSpacing.screen)
                }
                .myTabBarInset()
            }
        }
        .myScreenBackground()
        .navigationTitle("أهدافي")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { router.push(.createGoal) } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(MYColor.primary)
                }
                .accessibilityLabel("إنشاء هدف")
            }
        }
    }

    private var segmented: some View {
        HStack(spacing: 0) {
            seg("الحالية", on: !showCompleted) { showCompleted = false }
            seg("المكتملة", on: showCompleted) { showCompleted = true }
        }
        .padding(3)
        .background(MYColor.surfaceSecondary)
        .clipShape(Capsule())
    }

    private func seg(_ title: String, on: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.selection()
            withAnimation(.easeOut(duration: 0.15)) { action() }
        } label: {
            Text(title)
                .font(MYTypography.button)
                .foregroundStyle(on ? .white : MYColor.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, MYSpacing.sm)
                .background(on ? MYColor.primary : .clear)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    NavigationStack { GoalsView() }
        .environment(Router())
        .environment(GoalsStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
