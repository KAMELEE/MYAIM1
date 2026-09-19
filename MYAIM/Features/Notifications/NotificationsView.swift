import SwiftUI

struct NotificationsView: View {
    @State private var items: [AppNotification] = SampleData.notifications

    var body: some View {
        Group {
            if items.isEmpty {
                MYEmptyState(icon: "bell.slash", title: "لا توجد إشعارات",
                             message: "ستظهر هنا تنبيهات حجوزاتك وأهدافك واقتراحاتك.")
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: MYSpacing.sm) {
                        ForEach(items) { item in
                            row(item)
                        }
                    }
                    .padding(MYSpacing.screen)
                }
            }
        }
        .myTabBarInset()
        .myScreenBackground()
        .navigationTitle("الإشعارات")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("تعليم الكل كمقروء") { markAllRead() }
                    .font(MYTypography.caption)
                    .foregroundStyle(MYColor.primary)
            }
        }
    }

    private func row(_ item: AppNotification) -> some View {
        HStack(alignment: .top, spacing: MYSpacing.md) {
            Image(systemName: item.kind.icon)
                .font(.system(size: 18))
                .foregroundStyle(item.kind.tint)
                .frame(width: 44, height: 44)
                .background(item.kind.tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(item.title)
                        .font(MYTypography.cardTitle)
                        .foregroundStyle(MYColor.textPrimary)
                    Spacer()
                    if item.isUnread {
                        Circle().fill(MYColor.primary).frame(width: 8, height: 8)
                    }
                }
                Text(item.body)
                    .font(MYTypography.secondary)
                    .foregroundStyle(MYColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(relative(item.date))
                    .font(MYTypography.caption)
                    .foregroundStyle(MYColor.textTertiary)
            }
        }
        .padding(MYSpacing.md)
        .background(item.isUnread ? MYColor.primaryTint.opacity(0.5) : MYColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
            .strokeBorder(MYColor.border, lineWidth: 0.5))
        .onTapGesture { markRead(item) }
    }

    private func relative(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: "ar")
        f.unitsStyle = .full
        return f.localizedString(for: date, relativeTo: Date())
    }

    private func markRead(_ item: AppNotification) {
        guard let idx = items.firstIndex(of: item) else { return }
        items[idx].isUnread = false
    }

    private func markAllRead() {
        Haptics.selection()
        for i in items.indices { items[i].isUnread = false }
    }
}

#Preview {
    NavigationStack { NotificationsView() }
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
