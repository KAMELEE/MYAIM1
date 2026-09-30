import SwiftUI

@MainActor
@Observable
private final class BookingRequestsVM {
    private let repo: BookingRepository
    var state: LoadingState<[Booking]> = .idle
    var processing: Set<UUID> = []

    init(repo: BookingRepository = AppRepositories.bookings()) { self.repo = repo }

    func load() async {
        state = .loading
        do {
            let items = try await repo.pendingRequests()
            state = items.isEmpty ? .empty : .loaded(items)
        } catch { state = .failed("تعذر تحميل الطلبات.") }
    }

    func approve(_ b: Booking) async { await act(b) { try await self.repo.approve(b) } }
    func reject(_ b: Booking) async { await act(b) { try await self.repo.reject(b) } }

    private func act(_ b: Booking, _ op: @escaping () async throws -> Void) async {
        processing.insert(b.id)
        defer { processing.remove(b.id) }
        do { try await op(); Haptics.success(); await load() }
        catch { Haptics.error() }
    }
}

struct BookingRequestsView: View {
    @State private var vm = BookingRequestsVM()

    var body: some View {
        Group {
            switch vm.state {
            case .idle, .loading:
                ProgressView().tint(MYColor.primary).frame(maxHeight: .infinity)
            case .empty:
                MYEmptyState(icon: "tray", title: "لا طلبات جديدة",
                             message: "ستظهر هنا طلبات الحجز بانتظار موافقتك.")
                    .frame(maxHeight: .infinity)
            case .loaded(let items):
                ScrollView {
                    LazyVStack(spacing: MYSpacing.md) {
                        ForEach(items) { card($0) }
                    }
                    .padding(MYSpacing.screen)
                }
            case .failed(let m):
                MYEmptyState(icon: "wifi.exclamationmark", title: "خطأ", message: m,
                             actionTitle: "إعادة", onAction: { Task { await vm.load() } })
                    .frame(maxHeight: .infinity)
            }
        }
        .myTabBarInset()
        .myScreenBackground()
        .navigationTitle("طلبات الحجز")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.load() }
    }

    private func card(_ b: Booking) -> some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            HStack(spacing: MYSpacing.md) {
                MYRemoteImage(assetName: b.service.category.imageName, accent: b.service.category.accent)
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: MYRadius.sm, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text(b.service.title).font(MYTypography.cardTitle).foregroundStyle(MYColor.textPrimary).lineLimit(1)
                    Text(MYFormat.price(b.service.startingPrice)).font(MYTypography.secondary).foregroundStyle(MYColor.primary)
                }
                Spacer(minLength: 0)
                MYTag(text: b.paymentMethod.title, icon: b.paymentMethod.icon, style: .neutral)
            }

            HStack(spacing: MYSpacing.lg) {
                info("calendar", MYFormat.longDate(b.date))
                info("clock", b.time)
            }

            Divider().background(MYColor.border)

            if vm.processing.contains(b.id) {
                ProgressView().tint(MYColor.primary).frame(maxWidth: .infinity)
            } else {
                HStack(spacing: MYSpacing.md) {
                    MYButton(title: "رفض", style: .outline) { Task { await vm.reject(b) } }
                        .frame(maxWidth: 120)
                    MYButton(title: "تأكيد الحجز", icon: "checkmark") { Task { await vm.approve(b) } }
                }
            }
        }
        .myCard()
    }

    private func info(_ icon: String, _ text: String) -> some View {
        HStack(spacing: MYSpacing.xs) {
            Image(systemName: icon).font(.system(size: 12)).foregroundStyle(MYColor.textTertiary)
            Text(text).font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
        }
    }
}

#Preview {
    NavigationStack { BookingRequestsView() }
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
