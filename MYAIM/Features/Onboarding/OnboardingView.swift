import SwiftUI

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
}

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var index = 0

    private let pages: [OnboardingPage] = [
        .init(icon: "sparkle.magnifyingglass",
              title: "اكتشف ما يناسب هدفك",
              subtitle: "تصفّح أكاديميات ومدربين وبرامج مصمّمة لتحقيق أهدافك."),
        .init(icon: "calendar.badge.checkmark",
              title: "احجز بسهولة",
              subtitle: "احجز خدمتك بخطوات بسيطة وسريعة في أي وقت."),
        .init(icon: "chart.line.uptrend.xyaxis",
              title: "تابع تقدمك",
              subtitle: "حدّد أهدافك وتابع إنجازك خطوة بخطوة نحو النجاح.")
    ]

    private var isLast: Bool { index == pages.count - 1 }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                MYLogo(size: 40)
                Spacer()
                Button("تخطي") { finish() }
                    .font(MYTypography.secondary)
                    .foregroundStyle(MYColor.textSecondary)
            }
            .padding(MYSpacing.screen)

            TabView(selection: $index) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { i, page in
                    pageView(page).tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: index)

            dots.padding(.bottom, MYSpacing.xl)

            controls.padding(.horizontal, MYSpacing.screen)
                .padding(.bottom, MYSpacing.xl)
        }
        .myScreenBackground()
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: MYSpacing.lg) {
            Spacer()
            Image(systemName: page.icon)
                .font(.system(size: 76, weight: .light))
                .foregroundStyle(MYColor.primary)
                .frame(width: 160, height: 160)
                .background(MYColor.primaryTint)
                .clipShape(Circle())

            Text(page.title)
                .font(MYTypography.largeTitle)
                .foregroundStyle(MYColor.textPrimary)
                .multilineTextAlignment(.center)

            Text(page.subtitle)
                .font(MYTypography.body)
                .foregroundStyle(MYColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MYSpacing.xl)
            Spacer()
        }
        .padding(.horizontal, MYSpacing.screen)
    }

    private var dots: some View {
        HStack(spacing: MYSpacing.xs) {
            ForEach(pages.indices, id: \.self) { i in
                Capsule()
                    .fill(i == index ? MYColor.primary : MYColor.border)
                    .frame(width: i == index ? 22 : 7, height: 7)
                    .animation(.easeOut(duration: 0.25), value: index)
            }
        }
    }

    private var controls: some View {
        MYButton(title: isLast ? "ابدأ الآن" : "التالي",
                 icon: isLast ? "arrow.forward" : nil) {
            if isLast {
                finish()
            } else {
                withAnimation { index += 1 }
            }
        }
    }

    private func finish() {
        Haptics.light()
        withAnimation { appState.completeOnboarding() }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
