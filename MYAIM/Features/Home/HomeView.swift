import SwiftUI

/// Home screen — driven by `HomeViewModel` (repositories + loading states).
struct HomeView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    @Environment(FavoritesStore.self) private var favorites
    @Environment(LocationService.self) private var location
    @Environment(MessagesStore.self) private var messages
    @Environment(FeaturedStore.self) private var featured
    @State private var vm = HomeViewModel()
    @State private var demoPushed = false
    @State private var seenStoryIds: Set<UUID> = []
    @State private var activeStory: ActiveStory?

    private let categories = ServiceCategory.allCases

    var body: some View {
        ZStack(alignment: .top) {
            MYColor.background.ignoresSafeArea()
            // Violet behind the top so pulling down never reveals a light gap.
            MYColor.brandSolid.frame(height: 420).ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(spacing: 0) {
                    brandHeader
                        .padding(.horizontal, MYSpacing.screen)
                        .padding(.top, MYSpacing.sm)
                        .padding(.bottom, MYSpacing.lg + Self.sheetRadius)
                        .frame(maxWidth: .infinity)
                        .background(alignment: .topLeading) {
                            BrandRings(size: 460)
                                .offset(x: -190, y: -250)
                        }
                        .clipped()

                    content
                        .padding(.top, MYSpacing.lg)
                        .frame(maxWidth: .infinity)
                        .background(
                            UnevenRoundedRectangle(topLeadingRadius: Self.sheetRadius,
                                                   topTrailingRadius: Self.sheetRadius,
                                                   style: .continuous)
                                .fill(MYColor.background)
                        )
                        .padding(.top, -Self.sheetRadius)
                }
            }
            .myTabBarInset()
        }
        .myStatusBarScrim(MYColor.brandSolid)
        .toolbar(.hidden, for: .navigationBar)
        .task { await vm.load() }
        .refreshable { await vm.reload() }
        .onAppear {
            #if DEBUG
            guard !demoPushed, let r = DemoLaunch.route else { return }
            demoPushed = true
            switch r {
            case "serviceDetail":   router.push(.serviceDetail(SampleData.services[0]))
            case "booking":         router.push(.booking(SampleData.services[0]))
            case "search":          router.push(.search)
            case "favorites":       router.push(.favorites)
            case "notifications":   router.push(.notifications)
            case "registerAcademy": router.push(.registerAcademy)
            case "help":            router.push(.help)
            case "providerProfile": router.push(.providerProfile(SampleData.providers[0]))
            case "settings":        router.push(.settings)
            case "messages":        router.push(.messages)
            case "chat":            if let c = messages.conversations.first { router.push(.chat(c)) }
            default: break
            }
            #endif
        }
    }

    private static let sheetRadius: CGFloat = 28

    // MARK: Content sheet (light, rounded top)
    private var content: some View {
        VStack(alignment: .leading, spacing: MYSpacing.lg) {
            // Paid academy ads — the first thing trainees see.
            SponsoredAdsCarousel(ads: featured.liveAds) { ad in
                router.push(.allServices(title: ad.providerName))
            }
            .myAppear()

            storiesSection
                .myAppear(delay: 0.05)

            categoriesSection
                .myAppear(delay: 0.1)

            dynamicContent
                .myAppear(delay: 0.15)

            MYAcademyCTA(onRegister: { router.push(.registerAcademy) })
                .padding(.top, MYSpacing.xs)
        }
        .padding(.horizontal, MYSpacing.screen)
    }

    // MARK: Violet header — greeting, location, notifications, search
    private var brandHeader: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            HStack(spacing: MYSpacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(greeting)
                        .font(MYTypography.secondary)
                        .foregroundStyle(.white.opacity(0.85))
                    Text(appState.currentUser?.name ?? "أهلاً بك")
                        .font(.appFont(22, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                Spacer(minLength: MYSpacing.sm)

                Button { Haptics.selection() } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 14, weight: .semibold))
                        Text("الرياض")
                            .font(.appFont(13, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .background(.white.opacity(0.14), in: Capsule())
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("الموقع: الرياض")

                Button {
                    Haptics.light()
                    router.push(.notifications)
                } label: {
                    Image(systemName: "bell")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.14), in: Circle())
                        .overlay(alignment: .topTrailing) {
                            Circle()
                                .fill(MYColor.star)
                                .frame(width: 8, height: 8)
                                .offset(x: -11, y: 10)
                        }
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("الإشعارات")
            }

            Button {
                Haptics.light()
                router.push(.search)
            } label: {
                HStack(spacing: MYSpacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(MYColor.textSecondary)
                    Text("ابحث عن مهارة، أكاديمية أو مدرّب")
                        .font(MYTypography.body)
                        .foregroundStyle(MYColor.textSecondary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(MYColor.primary)
                }
                .padding(.horizontal, MYSpacing.md)
                .frame(height: 52)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("البحث والفلاتر")
        }
    }

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: .now)
        return h < 12 ? "صباح الخير" : "مساء الخير"
    }

    // MARK: Academy stories (first thing on Home)
    private var storiesSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            AcademyStoriesRow(
                stories: featured.stories,
                seenStoryIds: $seenStoryIds,
                onTap: { story in
                    if let i = featured.stories.firstIndex(where: { $0.id == story.id }) {
                        activeStory = ActiveStory(index: i)
                    }
                }
            )
        }
        .fullScreenCover(item: $activeStory) { active in
            StoryViewer(
                stories: featured.stories,
                startIndex: active.index,
                seenStoryIds: $seenStoryIds,
                onClose: { activeStory = nil }
            )
        }
    }

    // MARK: Categories — four tiles
    private var categoriesSection: some View {
        HStack(spacing: MYSpacing.sm) {
            ForEach(categories) { category in
                Button {
                    Haptics.selection()
                    router.push(.category(category))
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: category.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(category.accent)
                            .frame(width: 42, height: 42)
                            .background(category.accent.opacity(0.12),
                                        in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        Text(category.shortTitle)
                            .font(.appFont(12, weight: .semibold))
                            .foregroundStyle(MYColor.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, MYSpacing.sm)
                    .background(MYColor.surface,
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel(category.title)
            }
        }
    }

    // MARK: Dynamic (state-driven) content
    @ViewBuilder
    private var dynamicContent: some View {
        switch vm.state {
        case .idle, .loading:
            skeletonSection
        case .loaded(let content):
            serviceRow("قريب منك", content.nearby)
            serviceRow("الأكثر حجزاً", content.popular)
            serviceRow("موصى لك", content.recommended)
        case .empty:
            MYEmptyState(icon: "sparkles", title: "لا يوجد محتوى بعد",
                         message: "تحقق لاحقًا لاكتشاف برامج جديدة.")
        case .failed(let message):
            MYEmptyState(icon: "wifi.exclamationmark", title: "حدث خطأ",
                         message: message, actionTitle: "إعادة المحاولة",
                         onAction: { Task { await vm.reload() } })
        }
    }

    private func serviceRow(_ title: String, _ services: [Service]) -> some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            MYSectionHeader(title: title,
                            onAction: { router.push(.allServices(title: title)) })
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MYSpacing.md) {
                    ForEach(services.map { $0.distanced(from: location.userLocation) }) { service in
                        MYServiceCard(
                            service: service,
                            isFavorite: favorites.contains(service.id),
                            onFavorite: { favorites.toggle(service.id) },
                            onTap: { router.push(.serviceDetail(service)) }
                        )
                        .frame(width: 244)
                    }
                }
                .padding(.horizontal, MYSpacing.screen)
            }
            .padding(.horizontal, -MYSpacing.screen)
        }
    }

    // MARK: Skeleton
    private var skeletonSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            MYSkeleton().frame(width: 140, height: 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MYSpacing.md) {
                    ForEach(0..<3, id: \.self) { _ in skeletonCard }
                }
                .padding(.horizontal, MYSpacing.screen)
            }
            .padding(.horizontal, -MYSpacing.screen)
        }
    }

    private var skeletonCard: some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            MYSkeleton(cornerRadius: MYRadius.md).frame(width: 244, height: 120)
            MYSkeleton().frame(width: 170, height: 15)
            MYSkeleton().frame(width: 110, height: 13)
            MYSkeleton().frame(width: 90, height: 15)
        }
        .padding(MYSpacing.md)
        .frame(width: 244, alignment: .leading)
        .background(MYColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous)
            .strokeBorder(MYColor.border, lineWidth: 0.5))
    }
}

private extension ServiceCategory {
    /// Compact label for the Home category tiles.
    var shortTitle: String {
        switch self {
        case .selfDevelopment: return "تطوير ذات"
        case .sports:          return "رياضة"
        case .education:       return "تعليم"
        case .tech:            return "تقنية"
        }
    }
}

/// Identifiable wrapper so the stories viewer can present via fullScreenCover(item:).
private struct ActiveStory: Identifiable {
    let index: Int
    var id: Int { index }
}

#Preview {
    NavigationStack { HomeView() }
        .environment(Router())
        .environment(AppState())
        .environment(FavoritesStore())
        .environment(LocationService())
        .environment(MessagesStore())
        .environment(FeaturedStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
