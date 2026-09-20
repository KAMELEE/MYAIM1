import Foundation

/// Shared shape for a bottom-nav item, so `MYTabBar` works for both the
/// trainee tabs (`AppTab`) and the provider tabs (`ProviderTab`).
protocol TabBarItem: Hashable, Identifiable {
    var title: String { get }
    var icon: String { get }
    var selectedIcon: String { get }
}
