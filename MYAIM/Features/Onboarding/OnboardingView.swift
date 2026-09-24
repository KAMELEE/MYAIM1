import SwiftUI

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let icon: String
    let eyebrow: String
    let titlePlain: String
    let titleBold: String
    let subtitle: String
    let stats: [(icon: String, text: String)]
}

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var index = 0
    @State private var illustrationAppeared = false

    private let pages: [OnboardingPage] = [
        .init(imageName: "onboard_verified",
              icon: "checkmark.seal.fill",
              eyebrow: "MY AIM",
              titlePlain: "أكاديميات",
              titleBold: "موثقة في كل التخصصات",
              subtitle: "نتحقق من كل مزوّد قبل ظهوره لك، فتحجز وأنت مطمئن للجودة والمصداقية.",
              stats: [("checkmark.shield.fill", "توثيق كامل"), ("star.fill", "تقييمات حقيقية")]),
        .init(imageName: "onboard_nearby",
              icon: "location.fill",
              eyebrow: "MY AIM",
              titlePlain: "أقرب الخيارات",
              titleBold: "قريبة منك",
              subtitle: "نرتب لك الأكاديميات والخدمات حسب موقعك، فتوفّر وقتك وتختار الأقرب لك.",
              stats: [("map.fill", "فرز بالمسافة"), ("bolt.fill", "نتائج فورية")]),
        .init(imageName: "onboard_choice",
              icon: "slider.horizontal.3",
              eyebrow: "MY AIM",
              titlePlain: "اختر",
              titleBold: "ما يناسبك تمامًا",
              subtitle: "فلاتر ذكية للسعر والتخصص والتوقيت، لتصل لخيارك المثالي بضغطات قليلة.",
              stats: [("target", "توصيات مخصّصة"), ("slider.horizontal.below.rectangle", "فلترة دقيقة")]),
        .init(imageName: "onboard_offers",
              icon: "tag.fill",
              eyebrow: "MY AIM",
              titlePlain: "أسعار وعروض",
              titleBold: "تناسب ميزانيتك",
              subtitle: "خصومات وباقات حصرية تتجدد باستمرار، لتحصل على أفضل قيمة لكل ريال.",
              stats: [("percent", "عروض أسبوعية"), ("wallet.pass.fill", "خيارات لكل ميزانية")])
    ]

    private var isLast: Bool { index == pages.count - 1 }

    var body: some View {
        VStack(spacing: 0) {
            header

            TabView(selection: $index) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { i, page in
                    pageView(page).tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: index)
            .onChange(of: index) { _, _ in
                illustrationAppeared = false
                Haptics.selection()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.05)) {
                    illustrationAppeared = true
                }
            }

            dots.padding(.vertical, MYSpacing.lg)

            controls
                .padding(.horizontal, MYSpacing.screen)
                .padding(.bottom, MYSpacing.xl)
        }
        .myScreenBackground()
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.1)) {
                illustrationAppeared = true
            }
        }
    }

    // MARK: Header
    private var header: some View {
        HStack {
            MYLogo(size: 36)
            Spacer()
            if !isLast {
                Button("تخطي") { finish() }
                    .font(MYTypography.secondary)
                    .foregroundStyle(MYColor.textSecondary)
            }
        }
        .padding(.horizontal, MYSpacing.screen)
        .padding(.top, MYSpacing.sm)
    }

    // MARK: Page
    private func pageView(_ page: OnboardingPage) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: MYSpacing.xl) {
                illustration(page)
                    .padding(.top, MYSpacing.sm)

                VStack(spacing: MYSpacing.md) {
                    Text(page.eyebrow)
                        .font(MYTypography.caption)
                        .foregroundStyle(MYColor.primary)
                        .tracking(1.2)

                    (Text(page.titlePlain + " ")
                        .foregroundStyle(MYColor.textPrimary)
                     + Text(page.titleBold)
                        .foregroundStyle(MYColor.primary))
                        .font(MYTypography.largeTitle)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(page.subtitle)
                        .font(MYTypography.body)
                        .foregroundStyle(MYColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, MYSpacing.lg)
                }

                statChips(page.stats)
                    .padding(.bottom, MYSpacing.md)
            }
            .padding(.horizontal, MYSpacing.screen)
        }
    }

    /// Illustration image with a floating breathing animation, an animated
    /// interactive icon badge, and a spring-in entrance transition.
    private func illustration(_ page: OnboardingPage) -> some View {
        ZStack(alignment: .bottomTrailing) {
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 190)
                .frame(maxWidth: .infinity, minHeight: 240)
                .background(
                    RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous)
                        .fill(MYColor.surfaceSecondary)
                )
                .modifier(FloatingAnimation())

            InteractiveIconBadge(icon: page.icon)
                .offset(x: -8, y: 8)
        }
        .scaleEffect(illustrationAppeared ? 1 : 0.85)
        .opacity(illustrationAppeared ? 1 : 0)
    }

    private func statChips(_ stats: [(icon: String, text: String)]) -> some View {
        HStack(spacing: MYSpacing.sm) {
            ForEach(stats, id: \.text) { stat in
                HStack(spacing: MYSpacing.xs) {
                    Image(systemName: stat.icon)
                        .font(.system(size: 11, weight: .semibold))
                    Text(stat.text)
                        .font(MYTypography.caption)
                }
                .foregroundStyle(MYColor.primary)
                .padding(.horizontal, MYSpacing.md)
                .padding(.vertical, MYSpacing.sm)
                .background(MYColor.primaryTint)
                .clipShape(Capsule())
            }
        }
    }

    // MARK: Dots
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

    // MARK: Controls — circular back / forward, final pill "start"
    private var controls: some View {
        HStack(spacing: MYSpacing.md) {
            if index > 0 {
                circleButton(icon: "chevron.forward", style: .outline) {
                    Haptics.selection()
                    withAnimation { index -= 1 }
                }
                .transition(.scale.combined(with: .opacity))
            }

            if isLast {
                MYButton(title: "ابدأ الآن", icon: "chevron.backward") { finish() }
            } else {
                Spacer(minLength: 0)
                circleButton(icon: "chevron.backward", style: .primary) {
                    Haptics.selection()
                    withAnimation { index += 1 }
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: index)
    }

    private func circleButton(icon: String, style: MYButtonStyle, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(style == .primary ? MYColor.onPrimary : MYColor.textSecondary)
                .frame(width: 52, height: 52)
                .background(style == .primary ? MYColor.primary : MYColor.surfaceSecondary)
                .clipShape(Circle())
                .overlay(
                    Circle().strokeBorder(MYColor.border, lineWidth: style == .primary ? 0 : 1)
                )
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func finish() {
        Haptics.light()
        withAnimation { appState.completeOnboarding() }
    }
}

/// Small circular icon badge with a continuous, subtle "breathing" scale and
/// a tap ripple — the "interactive icon" accent floating over the illustration.
private struct InteractiveIconBadge: View {
    let icon: String
    @State private var pulse = false
    @State private var tapped = false

    var body: some View {
        Button {
            Haptics.light()
            tapped = true
            withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) { tapped = false }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(MYColor.onPrimary)
                .frame(width: 44, height: 44)
                .background(MYColor.primary)
                .clipShape(Circle())
                .myShadow(MYShadow.raised)
                .scaleEffect(pulse ? 1.08 : 1.0)
                .scaleEffect(tapped ? 0.85 : 1.0)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

/// Continuous gentle vertical float, used to give the flat illustrations
/// a sense of life without any heavy motion.
private struct FloatingAnimation: ViewModifier {
    @State private var floating = false

    func body(content: Content) -> some View {
        content
            .offset(y: floating ? -6 : 6)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                    floating = true
                }
            }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
