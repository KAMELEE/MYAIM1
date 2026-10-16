import SwiftUI

/// What a page shows in the violet hero area.
private enum OnboardingHero {
    /// A sample academy card (real photo) — the marketplace at a glance.
    case academyCard
    /// One of the bundled illustrations, framed in a white card.
    case illustration(String)
}

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let hero: OnboardingHero
    let title: String
    let subtitle: String
    /// Small chip pinned to the hero card.
    let badge: (icon: String, text: String)
}

/// Onboarding — direction «ب — جريء بالهوية»: violet hero with the rings
/// motif and a tilted white card, under a white sheet with the copy, page
/// dots and one wide primary button. The hero swipes; the sheet's copy
/// cross-fades with it.
struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var index = 0

    private let pages: [OnboardingPage] = [
        .init(hero: .academyCard,
              title: "كل الأكاديميات في مكان واحد",
              subtitle: "رياضة، تعليم، تقنية وتطوير ذات — اكتشف الجهات التدريبية الموثوقة وقارن بينها.",
              badge: ("checkmark.seal.fill", "جهات موثّقة")),
        .init(hero: .illustration("onboard_nearby"),
              title: "الأقرب لك أولًا",
              subtitle: "نرتّب الأكاديميات حسب موقعك، فتعرف المسافة قبل أن تحجز.",
              badge: ("location.fill", "حسب موقعك")),
        .init(hero: .illustration("onboard_choice"),
              title: "قارن واختر بثقة",
              subtitle: "فلاتر للسعر والتخصص والتوقيت تختصر عليك المقارنة.",
              badge: ("slider.horizontal.3", "فلاتر واضحة")),
        .init(hero: .illustration("onboard_offers"),
              title: "أسعار واضحة من البداية",
              subtitle: "السعر معلن مع كل خدمة، وخصومات متجددة على دورات مختارة.",
              badge: ("tag.fill", "خصومات متجددة"))
    ]

    private var isLast: Bool { index == pages.count - 1 }
    private var page: OnboardingPage { pages[index] }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                MYColor.brandSolid.ignoresSafeArea()

                BrandRings(size: geo.size.width * 1.45)
                    .position(x: geo.size.width * 0.38, y: geo.size.height * 0.08)

                VStack(spacing: 0) {
                    header

                    TabView(selection: $index) {
                        ForEach(Array(pages.enumerated()), id: \.element.id) { i, p in
                            HeroCard(page: p, tilt: i.isMultiple(of: 2) ? -3 : 3)
                                .padding(.horizontal, 44)
                                .tag(i)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    sheet
                }
            }
        }
    }

    // MARK: Header — white logo + skip pill
    private var header: some View {
        HStack {
            Image("LogoWhite")
                .resizable()
                .scaledToFit()
                .frame(height: 22)
                .accessibilityLabel("MY AIM")
            Spacer()
            if !isLast {
                Button {
                    finish()
                } label: {
                    Text("تخطي")
                        .font(MYTypography.secondary.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, MYSpacing.md)
                        .frame(height: 36)
                        .background(.white.opacity(0.16), in: Capsule())
                }
                .frame(minHeight: 44)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, MYSpacing.screen)
        .padding(.top, MYSpacing.sm)
        .animation(.easeInOut(duration: 0.2), value: isLast)
    }

    // MARK: Bottom sheet — copy, dots, one wide button
    private var sheet: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            VStack(alignment: .leading, spacing: MYSpacing.sm) {
                Text(page.title)
                    .font(.appFont(28, weight: .bold, relativeTo: .largeTitle))
                    .foregroundStyle(MYColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(page.subtitle)
                    .font(MYTypography.body)
                    .foregroundStyle(MYColor.textSecondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 128, alignment: .top)
            .id(index)
            .transition(.opacity.combined(with: .offset(y: 8)))

            dots

            MYButton(title: isLast ? "ابدأ الآن" : "التالي") {
                Haptics.selection()
                if isLast {
                    finish()
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) { index += 1 }
                }
            }
            .padding(.top, MYSpacing.xs)
        }
        .padding(.horizontal, MYSpacing.screen)
        .padding(.top, 30)
        .padding(.bottom, MYSpacing.lg)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32, style: .continuous)
                .fill(MYColor.surface)
                .ignoresSafeArea(edges: .bottom)
        )
        .animation(.easeInOut(duration: 0.25), value: index)
    }

    private var dots: some View {
        HStack(spacing: 6) {
            ForEach(pages.indices, id: \.self) { i in
                Capsule()
                    .fill(i == index ? MYColor.primary : MYColor.border)
                    .frame(width: i == index ? 22 : 6, height: 6)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: index)
        .accessibilityElement()
        .accessibilityLabel("الصفحة \(index + 1) من \(pages.count)")
    }

    private func finish() {
        Haptics.light()
        withAnimation { appState.completeOnboarding() }
    }
}

// MARK: - Hero card (tilted white card, gentle float)

private struct HeroCard: View {
    let page: OnboardingPage
    let tilt: Double

    @State private var up = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        card
            .overlay(alignment: .topLeading) { badge.offset(x: -10, y: -14) }
            .rotationEffect(.degrees(tilt))
            .offset(y: up ? -5 : 5)
            .frame(maxHeight: .infinity)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) { up = true }
            }
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var card: some View {
        switch page.hero {
        case .academyCard:
            VStack(alignment: .leading, spacing: 0) {
                Image("photo_sports")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .clipped()
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("برنامج اللياقة الشامل")
                            .font(MYTypography.cardTitle)
                            .foregroundStyle(Color(hex: "#14181F"))
                        Spacer(minLength: 4)
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill").foregroundStyle(MYColor.star)
                            Text("4.8").foregroundStyle(Color(hex: "#14181F"))
                        }
                        .font(MYTypography.caption)
                    }
                    Text("أكاديمية النخبة الرياضية · الرياض")
                        .font(MYTypography.description)
                        .foregroundStyle(Color(hex: "#6B7280"))
                    Text(MYFormat.startingPrice(450))
                        .font(MYTypography.cardTitle)
                        .foregroundStyle(MYColor.brandSolid)
                }
                .padding(MYSpacing.md)
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

        case .illustration(let name):
            Image(name)
                .resizable()
                .scaledToFit()
                .padding(MYSpacing.lg)
                .frame(maxWidth: .infinity)
                .frame(height: 250)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }

    private var badge: some View {
        HStack(spacing: 5) {
            Image(systemName: page.badge.icon).font(.system(size: 11, weight: .bold))
            Text(page.badge.text).font(MYTypography.caption.weight(.semibold))
        }
        .foregroundStyle(MYColor.brandSolid)
        .padding(.horizontal, 12)
        .frame(height: 30)
        .background(Color(hex: "#EEEAFB"), in: Capsule())
        .overlay(Capsule().strokeBorder(.white, lineWidth: 2))
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
