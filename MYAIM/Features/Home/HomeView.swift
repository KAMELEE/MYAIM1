import SwiftUI

/// Home screen — driven by `HomeViewModel` (repositories + loading states).
struct HomeView: View {
    @Environment(Router.self) private var router
    @Environment(FavoritesStore.self) private var favorites
    @Environment(LocationService.self) private var location
    @Environment(MessagesStore.self) private var messages
    @State private var vm = HomeViewModel()
    @State private var demoPushed = false
    @State private var seenStoryIds: Set<UUID> = []
    @State private var activeStory: ActiveStory?

    private let categories = ServiceCategory.allCases

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                MYHomeHeader(onLocationTap: {},
                             onNotificationsTap: { router.push(.notifications) })

                storiesSection

                searchRow

                HomeHero(onCTA: { router.push(.allServices(title: "الأكاديميات")) })

                HeroFeatureTiles(onTap: { router.push(.allServices(title: "كل الخدمات")) })

                categoriesSection

                dynamicContent

                MYAcademyCTA(onRegister: { router.push(.registerAcademy) })
                    .padding(.top, MYSpacing.xs)
            }
            .padding(.horizontal, MYSpacing.screen)
            .padding(.top, MYSpacing.sm)
        }
        .myTabBarInset()
        .myScreenBackground()
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
            case "goalDetail":      router.push(.goalDetail(SampleData.goals[0]))
            case "registerAcademy": router.push(.registerAcademy)
            case "providerProfile": router.push(.providerProfile(SampleData.providers[0]))
            case "settings":        router.push(.settings)
            case "messages":        router.push(.messages)
            case "chat":            if let c = messages.conversations.first { router.push(.chat(c)) }
            default: break
            }
            #endif
        }
    }

    // MARK: Academy stories (first thing on Home)
    private var storiesSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            AcademyStoriesRow(
                stories: SampleData.academyStories,
                seenStoryIds: $seenStoryIds,
                onTap: { story in
                    if let i = SampleData.academyStories.firstIndex(where: { $0.id == story.id }) {
                        activeStory = ActiveStory(index: i)
                    }
                }
            )
        }
        .fullScreenCover(item: $activeStory) { active in
            StoryViewer(
                stories: SampleData.academyStories,
                startIndex: active.index,
                seenStoryIds: $seenStoryIds,
                onClose: { activeStory = nil }
            )
        }
    }

    // MARK: Search + filter
    private var searchRow: some View {
        HStack(spacing: MYSpacing.sm) {
            MYSearchButton { router.push(.search) }
            Button {
                Haptics.light()
                router.push(.search)
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(MYColor.primary)
                    .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
            }
            .accessibilityLabel("الفلاتر")
        }
    }

    // MARK: Categories
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            MYSectionHeader(title: "استكشف الأقسام",
                            onAction: { router.push(.allServices(title: "كل الأقسام")) })
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MYSpacing.sm) {
                    ForEach(categories) { category in
                        Button {
                            Haptics.selection()
                            router.push(.category(category))
                        } label: {
                            HStack(spacing: MYSpacing.xs) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 14, weight: .semibold))
                                    .symbolRenderingMode(.hierarchical)
                                Text(category.title).font(MYTypography.secondary)
                            }
                            .foregroundStyle(category.accent)
                            .padding(.horizontal, MYSpacing.md)
                            .padding(.vertical, MYSpacing.sm)
                            .background(category.accent.opacity(0.09))
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(category.accent.opacity(0.25), lineWidth: 1))
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(.horizontal, MYSpacing.screen)
            }
            .padding(.horizontal, -MYSpacing.screen)
        }
    }

    // MARK: Dynamic (state-driven) content
    @ViewBuilder
    private var dynamicContent: some View {
        switch vm.state {
        case .idle, .loading:
            skeletonSection
        case .loaded(let content):
            if let goal = content.currentGoal {
                VStack(alignment: .leading, spacing: MYSpacing.md) {
                    MYSectionHeader(title: "هدفك الحالي", actionTitle: nil)
                    MYGoalCard(goal: goal, onContinue: { router.push(.goalDetail(goal)) })
                }
            }
            serviceRow("الأكثر حجزاً", content.popular)
            serviceRow("قريب منك", content.nearby)
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

/// Identifiable wrapper so the stories viewer can present via fullScreenCover(item:).
private struct ActiveStory: Identifiable {
    let index: Int
    var id: Int { index }
}

#Preview {
    NavigationStack { HomeView() }
        .environment(Router())
        .environment(FavoritesStore())
        .environment(LocationService())
        .environment(MessagesStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
