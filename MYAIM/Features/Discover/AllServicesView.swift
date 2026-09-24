import SwiftUI

/// A scrollable 2-column grid of services, optionally filtered by category.
/// Used by "عرض الكل" and by tapping a category.
struct AllServicesView: View {
    let title: String
    var category: ServiceCategory?

    @Environment(Router.self) private var router
    @Environment(FavoritesStore.self) private var favorites
    @State private var catalog: [Service] = []

    private let columns = [GridItem(.flexible(), spacing: MYSpacing.md),
                           GridItem(.flexible(), spacing: MYSpacing.md)]

    private var services: [Service] {
        guard let category else { return catalog }
        return catalog.filter { $0.category == category }
    }

    var body: some View {
        ScrollView {
            if services.isEmpty {
                MYEmptyState(icon: "square.stack.3d.up.slash",
                             title: "لا توجد نتائج",
                             message: "جرّب قسمًا آخر أو ابحث عن خدمة مختلفة.")
                    .padding(.top, MYSpacing.xxxl)
            } else {
                LazyVGrid(columns: columns, spacing: MYSpacing.md) {
                    ForEach(services) { service in
                        MYServiceCard(
                            service: service,
                            isFavorite: favorites.contains(service.id),
                            onFavorite: { favorites.toggle(service.id) },
                            onTap: { router.push(.serviceDetail(service)) }
                        )
                    }
                }
                .padding(MYSpacing.screen)
            }
        }
        .myTabBarInset()
        .myScreenBackground()
        .task {
            catalog = (try? await AppRepositories.services().services(in: category)) ?? []
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AllServicesView(title: "الأكثر حجزاً", category: nil)
            .environment(Router())
            .environment(FavoritesStore())
    }
    .environment(\.layoutDirection, .rightToLeft)
    .environment(\.locale, Locale(identifier: "ar"))
}
