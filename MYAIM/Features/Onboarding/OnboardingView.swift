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

    private let pages: [OnboardingPage] = [
        .init(imageName: "onboard_verified",
              icon: "building.2.fill",
              eyebrow: "MY AIM",
              titlePlain: "اكتشف أفضل الأكاديميات",
              titleBold: "والجهات التدريبية",
              subtitle: "ابحث عن الأكاديمية أو الدورة التي تناسبك، وقارن الخيارات المتاحة واختر ما يناسب تخصصك واحتياجك.",
              stats: [("checkmark.seal.fill", "جهات تدريبية موثوقة"),
                      ("books.vertical.fill", "دورات وتخصصات متنوعة")]),
        .init(imageName: "onboard_nearby",
              icon: "location.circle.fill",
              eyebrow: "MY AIM",
              titlePlain: "الجهات الأقرب",
              titleBold: "لك أولاً",
              subtitle: "نعرض لك الأكاديميات والخدمات مرتبة حسب موقعك، فتعرف المسافة قبل أن تحجز.",
              stats: [("map.fill", "ترتيب حسب المسافة"),
                      ("figure.walk.motion", "خيارات قريبة")]),
        .init(imageName: "onboard_choice",
              icon: "slider.horizontal.3",
              eyebrow: "MY AIM",
              titlePlain: "قارن الخيارات",
              titleBold: "واختر بثقة",
              subtitle: "فلاتر للسعر والتخصص والتوقيت تسهّل المقارنة بين الجهات حتى تصل لما يناسبك.",
              stats: [("arrow.left.arrow.right", "مقارنة مباشرة"),
                      ("line.3.horizontal.decrease.circle.fill", "فلاتر واضحة")]),
        .init(imageName: "onboard_offers",
              icon: "tag.fill",
              eyebrow: "MY AIM",
              titlePlain: "أسعار واضحة",
              titleBold: "من البداية",
              subtitle: "السعر يظهر مع كل خدمة، وتجد خصومات على دورات مختارة بشكل مستمر.",
              stats: [("percent", "خصومات متجددة"),
                      ("banknote.fill", "سعر معلن لكل خدمة")])
    ]

    private var isLast: Bool { index == pages.count - 1 }

    var body: some View {
        VStack(spacing: 0) {
            header

            TabView(selection: $index) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { i, page in
                    PageContent(page: page, isActive: i == index)
                        .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: index)

            dots.padding(.vertical, MYSpacing.lg)

            controls
                .padding(.horizontal, MYSpacing.screen)
                .padding(.bottom, MYSpacing.xl)
        }
        .myScreenBackground()
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

    // MARK: Dots
    private var dots: some View {
        HStack(spacing: MYSpacing.xs) {
            ForEach(pages.indices, id: \.self) { i in
                Capsule()
                    .fill(i == index ? MYColor.primary : MYColor.border)
                    .frame(width: i == index ? 26 : 8, height: 8)
                    .scaleEffect(i == index ? 1 : 0.85, anchor: .center)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: index)
            }
        }
        .padding(MYSpacing.xs)
        .background(Capsule().fill(MYColor.surfaceSecondary))
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

// MARK: - Page content (staggered entrance, breathing illustration)

/// One onboarding page. Content enters in a staggered sequence (illustration
/// → eyebrow → title → subtitle → chips) whenever the page becomes active,
/// giving each swipe a crisp, layered reveal.
private struct PageContent: View {
    let page: OnboardingPage
    let isActive: Bool

    @State private var appeared = false

    private let columns = [GridItem(.flexible(), spacing: MYSpacing.md),
                           GridItem(.flexible(), spacing: MYSpacing.md)]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: MYSpacing.xl) {
                illustration
                    .padding(.top, MYSpacing.sm)

                VStack(spacing: MYSpacing.md) {
                    Text(page.eyebrow)
                        .font(MYTypography.caption)
                        .foregroundStyle(MYColor.primary)
                        .tracking(1.2)
                        .stagger(0.10, appeared: appeared)

                    (Text(page.titlePlain + " ")
                        .foregroundStyle(MYColor.textPrimary)
                     + Text(page.titleBold)
                        .foregroundStyle(MYColor.primary))
                        .font(MYTypography.largeTitle)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .stagger(0.20, appeared: appeared)

                    Text(page.subtitle)
                        .font(MYTypography.body)
                        .foregroundStyle(MYColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, MYSpacing.lg)
                        .fixedSize(horizontal: false, vertical: true)
                        .stagger(0.30, appeared: appeared)
                }

                statChips(page.stats)
                    .padding(.bottom, MYSpacing.md)
                    .stagger(0.42, appeared: appeared)
            }
            .padding(.horizontal, MYSpacing.screen)
        }
        .onAppear { play() }
        .onChange(of: isActive) { _, active in if active { play() } }
    }

    private func play() {
        appeared = false
        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) { appeared = true }
    }

    /// Illustration with a gentle continuous float and a gradient icon badge.
    private var illustration: some View {
        ZStack(alignment: .bottomLeading) {
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

            IconBadge(icon: page.icon)
                .offset(x: 8, y: 8)
        }
        .scaleEffect(appeared ? 1 : 0.85)
        .opacity(appeared ? 1 : 0)
    }

    private func statChips(_ stats: [(icon: String, text: String)]) -> some View {
        HStack(spacing: MYSpacing.sm) {
            ForEach(stats, id: \.text) { stat in
                HStack(spacing: MYSpacing.xs) {
                    Image(systemName: stat.icon)
                        .font(.system(size: 12, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                    Text(stat.text)
                        .font(MYTypography.caption)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundStyle(MYColor.primary)
                .padding(.horizontal, MYSpacing.md)
                .padding(.vertical, MYSpacing.sm)
                .background(MYColor.primaryTint, in: Capsule())
            }
        }
    }
}

/// Slide-up + fade entrance, staggered by delay.
private struct StaggerEffect: ViewModifier {
    let delay: Double
    let appeared: Bool

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 18)
    }
}

private extension View {
    func stagger(_ delay: Double, appeared: Bool) -> some View {
        modifier(StaggerEffect(delay: delay, appeared: appeared))
            .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(delay),
                       value: appeared)
    }
}

/// Rounded-square gradient badge with a soft breathing pulse — the modern
/// replacement for the old circle badge.
private struct IconBadge: View {
    let icon: String
    @State private var pulse = false

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 48, height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(LinearGradient(colors: [MYColor.primary,
                                                  MYColor.primary.opacity(0.72)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .myShadow(MYShadow.raised)
            .scaleEffect(pulse ? 1.06 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}

/// Continuous gentle vertical float, used to give the flat illustrations
/// a sense of life without any heavy motion.
private struct FloatingAnimation: ViewModifier {
    @State private var up = false

    func body(content: Content) -> some View {
        content
            .offset(y: up ? -6 : 6)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    up = true
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
