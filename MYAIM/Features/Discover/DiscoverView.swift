import SwiftUI
import CoreLocation

struct DiscoverView: View {
    @Environment(Router.self) private var router
    @Environment(FavoritesStore.self) private var favorites
    @Environment(LocationService.self) private var location
    @State private var vm = DiscoverViewModel()
    @State private var showFilters = false

    private let columns = [GridItem(.flexible(), spacing: MYSpacing.md),
                           GridItem(.flexible(), spacing: MYSpacing.md)]

    var body: some View {
        VStack(spacing: 0) {
            controls
            Divider().background(MYColor.border)
            content
        }
        .myScreenBackground()
        .navigationTitle("اكتشف")
        .navigationBarTitleDisplayMode(.inline)
        .task { vm.loadIfNeeded() }
        .onAppear {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-demoMode") { return }
            #endif
            location.request()
        }
        .onChange(of: vm.query) { _, _ in vm.onQueryChange() }
        .myBottomSheet(isPresented: $showFilters) {
            FiltersSheet(initial: vm.filters) { vm.apply($0) }
        }
    }

    // MARK: Top controls
    private var controls: some View {
        VStack(spacing: MYSpacing.md) {
            HStack(spacing: MYSpacing.sm) {
                MYSearchBar(text: $vm.query, onSubmit: { vm.runSearch() })
                filterButton
            }
            categoryChips
            viewToggle
        }
        .padding(MYSpacing.screen)
    }

    private var filterButton: some View {
        Button {
            Haptics.light()
            showFilters = true
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(MYColor.primary)
                .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
                .overlay(alignment: .topTrailing) {
                    if vm.filters.activeCount > 0 {
                        Text("\(vm.filters.activeCount)")
                            .font(.appFont(10, weight: .bold))
                            .foregroundStyle(MYColor.primary)
                            .frame(width: 18, height: 18)
                            .background(.white)
                            .clipShape(Circle())
                            .offset(x: -4, y: 4)
                    }
                }
        }
        .accessibilityLabel("الفلاتر")
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MYSpacing.sm) {
                chip("الكل", isOn: vm.selectedCategory == nil) { vm.selectedCategory = nil }
                ForEach(ServiceCategory.allCases) { c in
                    chip(c.title, isOn: vm.selectedCategory == c) { vm.selectedCategory = c }
                }
            }
        }
    }

    private func chip(_ title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            Text(title)
                .font(MYTypography.secondary)
                .foregroundStyle(isOn ? .white : MYColor.textPrimary)
                .padding(.horizontal, MYSpacing.md)
                .padding(.vertical, MYSpacing.sm)
                .background(isOn ? MYColor.primary : MYColor.surface)
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(isOn ? .clear : MYColor.border, lineWidth: 1))
        }
    }

    private var viewToggle: some View {
        HStack(spacing: 0) {
            toggleButton("قائمة", "list.bullet", mode: .list)
            toggleButton("خريطة", "map", mode: .map)
        }
        .padding(3)
        .background(MYColor.surfaceSecondary)
        .clipShape(Capsule())
    }

    private func toggleButton(_ title: String, _ icon: String, mode: DiscoverViewMode) -> some View {
        let isOn = vm.viewMode == mode
        return Button {
            Haptics.selection()
            withAnimation(.easeOut(duration: 0.15)) { vm.viewMode = mode }
        } label: {
            HStack(spacing: MYSpacing.xs) {
                Image(systemName: icon).font(.system(size: 14, weight: .semibold))
                Text(title).font(MYTypography.secondary)
            }
            .foregroundStyle(isOn ? .white : MYColor.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, MYSpacing.sm)
            .background(isOn ? MYColor.primary : .clear)
            .clipShape(Capsule())
        }
    }

    // MARK: Results
    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .loading:
            loadingGrid
        case .loaded(let services):
            let located = Self.located(services, from: location.userLocation)
            if vm.viewMode == .map {
                MapResultsView(services: located, userLocation: location.userLocation) {
                    router.push(.serviceDetail($0))
                }
            } else {
                resultsList(located)
            }
        case .empty:
            MYEmptyState(icon: "magnifyingglass", title: "لا توجد نتائج",
                         message: "جرّب تعديل الفلاتر أو البحث بكلمة مختلفة.",
                         actionTitle: "إعادة تعيين الفلاتر",
                         onAction: { vm.resetFilters() })
                .frame(maxHeight: .infinity)
        case .failed(let message):
            MYEmptyState(icon: "wifi.exclamationmark", title: "حدث خطأ",
                         message: message, actionTitle: "إعادة المحاولة",
                         onAction: { vm.runSearch() })
                .frame(maxHeight: .infinity)
        }
    }

    /// Recompute distances from the live location; sort nearest-first when known.
    private static func located(_ services: [Service],
                                from userLocation: CLLocationCoordinate2D?) -> [Service] {
        let mapped = services.map { $0.distanced(from: userLocation) }
        guard userLocation != nil else { return mapped }
        return mapped.sorted { ($0.distanceMeters ?? .greatestFiniteMagnitude)
                              < ($1.distanceMeters ?? .greatestFiniteMagnitude) }
    }

    private func resultsList(_ services: [Service]) -> some View {
        ScrollView {
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
        .myTabBarInset()
    }

    private var loadingGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: MYSpacing.md) {
                ForEach(0..<6, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: MYSpacing.sm) {
                        MYSkeleton(cornerRadius: MYRadius.md).frame(height: 120)
                        MYSkeleton().frame(height: 15)
                        MYSkeleton().frame(width: 90, height: 13)
                    }
                    .padding(MYSpacing.md)
                    .background(MYColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous)
                        .strokeBorder(MYColor.border, lineWidth: 0.5))
                }
            }
            .padding(MYSpacing.screen)
        }
    }
}

#Preview {
    NavigationStack { DiscoverView() }
        .environment(Router())
        .environment(FavoritesStore())
        .environment(LocationService())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
