import SwiftUI

struct FavoritesView: View {
    @Environment(Router.self) private var router
    @Environment(FavoritesStore.self) private var favorites

    private let columns = [GridItem(.flexible(), spacing: MYSpacing.md),
                           GridItem(.flexible(), spacing: MYSpacing.md)]

    var body: some View {
        Group {
            if favorites.services.isEmpty {
                MYEmptyState(icon: "heart",
                             title: "لا توجد مفضلة بعد",
                             message: "أضف الخدمات والأكاديميات المفضلة لديك للوصول إليها بسرعة.",
                             actionTitle: "اكتشف الآن",
                             onAction: { router.push(.allServices(title: "اكتشف")) })
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: MYSpacing.md) {
                        ForEach(favorites.services) { service in
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
