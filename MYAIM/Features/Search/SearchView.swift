import SwiftUI

struct SearchView: View {
    @Environment(Router.self) private var router
    @State private var vm = SearchViewModel()
    @FocusState private var focused: Bool

    private let columns = [GridItem(.flexible(), spacing: MYSpacing.md),
                           GridItem(.flexible(), spacing: MYSpacing.md)]

    var body: some View {
        VStack(spacing: 0) {
            MYSearchBar(text: $vm.query, onSubmit: { vm.submit(vm.query) })
                .focused($focused)
                .padding(MYSpacing.screen)

            Divider().background(MYColor.border)

            if vm.isSearching {
                searchingContent
            } else {
                idleContent
            }
        }
        .myScreenBackground()
        .navigationTitle("بحث")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: vm.query) { _, _ in vm.onQueryChange() }
        .onAppear { focused = true }
    }

    // MARK: Idle (no query) — recent + popular
    private var idleContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.xl) {
                if !vm.recent.isEmpty {
                    VStack(alignment: .leading, spacing: MYSpacing.md) {
                        HStack {
                            Text("عمليات البحث الأخيرة")
                                .font(MYTypography.section)
                                .foregroundStyle(MYColor.textPrimary)
                            Spacer()
                            Button("مسح") { vm.clearRecent() }
                                .font(MYTypography.secondary)
                                .foregroundStyle(MYColor.primary)
                        }
                        ForEach(vm.recent, id: \.self) { term in
                            recentRow(term)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: MYSpacing.md) {
                    Text("الأكثر بحثًا")
                        .font(MYTypography.section)
                        .foregroundStyle(MYColor.textPrimary)
                    FlexChips(items: vm.popular) { vm.submit($0) }
                }
            }
            .padding(MYSpacing.screen)
        }
        .myTabBarInset()
    }

    private func recentRow(_ term: String) -> some View {
        Button {
            vm.submit(term)
        } label: {
            HStack(spacing: MYSpacing.md) {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundStyle(MYColor.textTertiary)
                Text(term)
                    .font(MYTypography.body)
                    .foregroundStyle(MYColor.textPrimary)
                Spacer()
                Image(systemName: "arrow.up.left")
                    .font(.system(size: 13))
                    .foregroundStyle(MYColor.textTertiary)
            }
            .padding(.vertical, MYSpacing.sm)
            .contentShape(Rectangle())
        }
    }

    // MARK: Searching — suggestions + results
    private var searchingContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                if !vm.suggestions.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(vm.suggestions, id: \.self) { s in
                            Button { vm.submit(s) } label: {
                                HStack(spacing: MYSpacing.md) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundStyle(MYColor.textTertiary)
                                    Text(s).font(MYTypography.body).foregroundStyle(MYColor.textPrimary)
                                    Spacer()
                                }
                                .padding(.vertical, MYSpacing.sm)
                                .contentShape(Rectangle())
                            }
                            if s != vm.suggestions.last { Divider().background(MYColor.border) }
                        }
                    }
                    .padding(.horizontal, MYSpacing.screen)
                    .padding(.top, MYSpacing.md)
                }

                resultsSection
            }
        }
        .myTabBarInset()
    }

    @ViewBuilder
    private var resultsSection: some View {
        switch vm.results {
        case .loading, .idle:
            ProgressView().tint(MYColor.primary)
                .frame(maxWidth: .infinity)
                .padding(.top, MYSpacing.xl)
        case .loaded(let services):
            LazyVGrid(columns: columns, spacing: MYSpacing.md) {
                ForEach(services) { service in
                    MYServiceCard(service: service,
                                  onTap: { router.push(.serviceDetail(service)) })
                }
            }
            .padding(MYSpacing.screen)
        case .empty:
            MYEmptyState(icon: "magnifyingglass", title: "لا توجد نتائج",
                         message: "لم نجد ما يطابق «\(vm.query)». جرّب كلمة مختلفة.")
        case .failed(let message):
            MYEmptyState(icon: "wifi.exclamationmark", title: "حدث خطأ", message: message)
        }
    }
}

/// Simple wrapping chips (uses a horizontal scroll rows layout).
private struct FlexChips: View {
    let items: [String]
    let onTap: (String) -> Void

    var body: some View {
        let rows = stride(from: 0, to: items.count, by: 3).map {
            Array(items[$0..<min($0 + 3, items.count)])
        }
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: MYSpacing.sm) {
                    ForEach(row, id: \.self) { item in
                        Button { onTap(item) } label: {
                            Text(item)
                                .font(MYTypography.secondary)
                                .foregroundStyle(MYColor.textPrimary)
                                .padding(.horizontal, MYSpacing.md)
                                .padding(.vertical, MYSpacing.sm)
                                .background(MYColor.surface)
                                .clipShape(Capsule())
                                .overlay(Capsule().strokeBorder(MYColor.border, lineWidth: 1))
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { SearchView() }
        .environment(Router())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
