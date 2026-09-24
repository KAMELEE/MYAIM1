import SwiftUI

struct CreateGoalView: View {
    @Environment(GoalsStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var category: ServiceCategory = .selfDevelopment
    @State private var steps: [String] = [""]

    private var canCreate: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                MYTextField(title: "عنوان الهدف", icon: "target",
                            placeholder: "مثال: تحسين لياقتي البدنية", text: $title)

                VStack(alignment: .leading, spacing: MYSpacing.sm) {
                    Text("المجال").font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: MYSpacing.sm) {
                            ForEach(ServiceCategory.allCases) { c in
                                let isOn = category == c
                                Button {
                                    Haptics.selection(); category = c
                                } label: {
                                    HStack(spacing: MYSpacing.xs) {
                                        Image(systemName: c.icon).font(.system(size: 13, weight: .semibold))
                                        Text(c.title).font(MYTypography.secondary)
                                    }
                                    .foregroundStyle(isOn ? .white : MYColor.textPrimary)
                                    .padding(.horizontal, MYSpacing.md)
                                    .padding(.vertical, MYSpacing.sm)
                                    .background(isOn ? MYColor.primary : MYColor.surface)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().strokeBorder(isOn ? .clear : MYColor.border, lineWidth: 1))
                                }
                            }
                        }
                    }
                }

                stepsEditor
            }
            .padding(MYSpacing.screen)
        }
        .safeAreaInset(edge: .bottom) {
            MYButton(title: "إنشاء الهدف", icon: "checkmark", isEnabled: canCreate) {
                create()
            }
            .padding(MYSpacing.lg)
            .background(.regularMaterial)
            .myTabBarClearance()
        }
        .myScreenBackground()
        .navigationTitle("هدف جديد")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
    }

    private var stepsEditor: some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            Text("الخطوات (اختياري)").font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
            ForEach(steps.indices, id: \.self) { i in
                HStack(spacing: MYSpacing.sm) {
                    Image(systemName: "circle").foregroundStyle(MYColor.textTertiary)
                    TextField("خطوة", text: $steps[i])
                        .font(MYTypography.body)
                        .padding(.horizontal, MYSpacing.md)
                        .frame(height: 48)
                        .background(MYColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: MYRadius.sm, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: MYRadius.sm, style: .continuous)
                            .strokeBorder(MYColor.border, lineWidth: 1))
                    if steps.count > 1 {
                        Button { steps.remove(at: i) } label: {
                            Image(systemName: "minus.circle.fill").foregroundStyle(MYColor.textTertiary)
                        }
                    }
                }
            }
            Button {
                steps.append("")
            } label: {
                Label("إضافة خطوة", systemImage: "plus")
                    .font(MYTypography.secondary)
                    .foregroundStyle(MYColor.primary)
            }
        }
    }

    private func create() {
        let goalSteps = steps
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { GoalStep(title: $0, isDone: false) }
        let goal = Goal(title: title.trimmingCharacters(in: .whitespaces),
                        category: category, steps: goalSteps)
        store.add(goal)
        Haptics.success()
        dismiss()
    }
}

#Preview {
    NavigationStack { CreateGoalView() }
        .environment(GoalsStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
