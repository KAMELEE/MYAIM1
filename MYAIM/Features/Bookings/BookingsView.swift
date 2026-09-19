import SwiftUI

struct BookingsView: View {
    @Environment(Router.self) private var router
    @State private var vm = BookingsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            segmented
                .padding(MYSpacing.screen)
            Divider().background(MYColor.border)
            content
        }
        .myScreenBackground()
        .navigationTitle("حجوزاتي")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.load() }
    }

    private var segmented: some View {
        HStack(spacing: 0) {
            tabButton("القادمة", tab: .upcoming)
            tabButton("السابقة", tab: .past)
        }
        .padding(3)
        .background(MYColor.surfaceSecondary)
        .clipShape(Capsule())
    }

    private func tabButton(_ title: String, tab: BookingsViewModel.Tab) -> some View {
        let isOn = vm.tab == tab
        return Button {
            Haptics.selection()
            withAnimation(.easeOut(duration: 0.15)) { vm.tab = tab }
        } label: {
            Text(title)
                .font(MYTypography.button)
                .foregroundStyle(isOn ? .white : MYColor.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, MYSpacing.sm)
                .background(isOn ? MYColor.primary : .clear)
                .clipShape(Capsule())
        }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.current {
        case .idle, .loading:
            ProgressView().tint(MYColor.primary).frame(maxHeight: .infinity)
        case .loaded(let bookings):
            ScrollView {
                LazyVStack(spacing: MYSpacing.md) {
                    ForEach(bookings) { booking in
                        card(booking)
                    }
                }
                .padding(MYSpacing.screen)
            }
            .myTabBarInset()
        case .empty:
            MYEmptyState(icon: "calendar.badge.exclamationmark",
                         title: "ما عندك حجوزات حالياً",
                         message: "اكتشف برامج وخدمات تناسب هدفك وابدأ رحلتك.",
                         actionTitle: "اكتشف الآن",
                         onAction: { router.push(.allServices(title: "اكتشف")) })
                .frame(maxHeight: .infinity)
        case .failed(let message):
            MYEmptyState(icon: "wifi.exclamationmark", title: "حدث خطأ",
                         message: message, actionTitle: "إعادة المحاولة",
                         onAction: { Task { await vm.refresh() } })
                .frame(maxHeight: .infinity)
        }
    }

    private func card(_ booking: Booking) -> some View {
        Button {
            router.push(.serviceDetail(booking.service))
        } label: {
            VStack(alignment: .leading, spacing: MYSpacing.md) {
                HStack(spacing: MYSpacing.md) {
                    MYRemoteImage(assetName: booking.service.category.imageName,
                                  urlString: booking.service.imageURL,
                                  fallbackIcon: booking.service.category.icon,
                                  accent: booking.service.category.accent)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: MYRadius.sm, style: .continuous))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(booking.service.title)
                            .font(MYTypography.cardTitle)
                            .foregroundStyle(MYColor.textPrimary)
                            .lineLimit(1)
                        Text(booking.service.providerName)
                            .font(MYTypography.description)
                            .foregroundStyle(MYColor.textSecondary)
                    }
                    Spacer(minLength: 0)
                    MYTag(text: booking.status.title, style: booking.status.tagStyle)
                }

                Divider().background(MYColor.border)

                HStack(spacing: MYSpacing.lg) {
                    infoItem("calendar", MYFormat.longDate(booking.date))
                    infoItem("clock", booking.time)
                }
                infoItem("mappin.and.ellipse", booking.service.location.city)
            }
            .myCard()
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func infoItem(_ icon: String, _ text: String) -> some View {
        HStack(spacing: MYSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(MYColor.textTertiary)
            Text(text)
                .font(MYTypography.caption)
                .foregroundStyle(MYColor.textSecondary)
        }
    }
}

#Preview {
    NavigationStack { BookingsView() }
        .environment(Router())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
