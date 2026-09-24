import SwiftUI

/// Fetches the live catalog once so favorites resolve against real data.
@MainActor
@Observable
final class FavoritesViewModel {
    var catalog: [Service] = []
    private let repo: ServiceRepository

    init(repo: ServiceRepository = AppRepositories.services()) {
        self.repo = repo
    }

    func load() async {
        catalog = (try? await repo.services(in: nil)) ?? []
    }
}

struct FavoritesView: View {
    @Environment(Router.self) private var router
    @Environment(FavoritesStore.self) private var favorites
    @State private var vm = FavoritesViewModel()

    private let columns = [GridItem(.flexible(), spacing: MYSpacing.md),
                           GridItem(.flexible(), spacing: MYSpacing.md)]

    private var favoritesList: [Service] { favorites.services(in: vm.catalog) }

    var body: some View {
        Group {
            if favoritesList.isEmpty {
                MYEmptyState(icon: "heart",
                             title: "لا توجد مفضلة بعد",
                             message: "أضف الخدمات والأكاديميات المفضلة لديك للوصول إليها بسرعة.",
                             actionTitle: "اكتشف الآن",
                             onAction: { router.push(.allServices(title: "اكتشف")) })
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: MYSpacing.md) {
                        ForEach(favoritesList) { service in
                            MYServiceCard(
                                service: service,
                                isFavorite: true,
                                onFavorite: { favorites.toggle(service.id) },
                                onTap: { router.push(.serviceDetail(service)) }
                            )
                        }
                    }
                    .padding(MYSpacing.screen)
                }
                .myTabBarInset()
            }
        }
        .myScreenBackground()
        .navigationTitle("المفضلة")
        .task { await vm.load() }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { FavoritesView() }
        .environment(Router())
        .environment(FavoritesStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
