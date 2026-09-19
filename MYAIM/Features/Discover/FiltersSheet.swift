import SwiftUI

/// Filters bottom-sheet content. Edits a local copy, then applies on confirm.
struct FiltersSheet: View {
    @Environment(\.dismiss) private var dismiss
    let initial: SearchFilters
    let onApply: (SearchFilters) -> Void

    @State private var draft: SearchFilters

    init(initial: SearchFilters, onApply: @escaping (SearchFilters) -> Void) {
        self.initial = initial
        self.onApply = onApply
        _draft = State(initialValue: initial)
    }

    var body: some View {
        VStack(spacing: 0) {
            MYSheetHeader(title: "الفلاتر", onClose: { dismiss() })

            ScrollView {
                VStack(alignment: .leading, spacing: MYSpacing.xl) {
                    group("الفئة") {
                        CategoryChips(selection: draft.category) { draft.category = $0 }
                    }
                    group("السعر") {
                        chips(["بلا حد": nil, "حتى ٥٠٠": 500, "حتى ١٠٠٠": 1000, "حتى ٢٠٠٠": 2000],
                              order: ["بلا حد", "حتى ٥٠٠", "حتى ١٠٠٠", "حتى ٢٠٠٠"],
                              current: draft.maxPrice) { draft.maxPrice = $0 }
                    }
                    group("التقييم") {
                        chips(["الكل": nil, "٤.٠+": 4.0, "٤.٥+": 4.5],
                              order: ["الكل", "٤.٠+", "٤.٥+"],
                              current: draft.minRating) { draft.minRating = $0 }
                    }
                    group("المسافة") {
                        chips(["الكل": nil, "حتى ٢ كم": 2000, "حتى ٥ كم": 5000],
                              order: ["الكل", "حتى ٢ كم", "حتى ٥ كم"],
                              current: draft.maxDistanceMeters) { draft.maxDistanceMeters = $0 }
                    }
                    Toggle(isOn: $draft.availableOnly) {
                        Text("المتاح فقط").font(MYTypography.cardTitle)
                    }
                    .tint(MYColor.primary)
                }
                .padding(.vertical, MYSpacing.lg)
            }

            MYSheetFooter(
                onReset: { draft = .none },
                onApply: { onApply(draft); dismiss() }
            )
            .padding(.bottom, MYSpacing.lg)
        }
    }

    // MARK: helpers
    private func group<Content: View>(_ title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            Text(title).font(MYTypography.cardTitle).foregroundStyle(MYColor.textPrimary)
            content()
        }
    }

    /// Chips for a Double? option set.
    private func chips(_ map: [String: Double?], order: [String],
                       current: Double?, set: @escaping (Double?) -> Void) -> some View {
        HStack(spacing: MYSpacing.sm) {
            ForEach(order, id: \.self) { key in
                let value = map[key] ?? nil
                let isOn = current == value
                Button {
                    Haptics.selection()
                    set(value)
                } label: {
                    Text(key)
                        .font(MYTypography.secondary)
                        .foregroundStyle(isOn ? .white : MYColor.textPrimary)
                        .padding(.horizontal, MYSpacing.md)
                        .padding(.vertical, MYSpacing.sm)
                        .background(isOn ? MYColor.primary : MYColor.surfaceSecondary)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

/// Category chips row (includes an "الكل" option).
private struct CategoryChips: View {
    let selection: ServiceCategory?
    let onSelect: (ServiceCategory?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MYSpacing.sm) {
                pill("الكل", isOn: selection == nil) { onSelect(nil) }
                ForEach(ServiceCategory.allCases) { category in
                    pill(category.title, isOn: selection == category) { onSelect(category) }
                }
            }
        }
    }

    private func pill(_ title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            Text(title)
                .font(MYTypography.secondary)
                .foregroundStyle(isOn ? .white : MYColor.textPrimary)
                .padding(.horizontal, MYSpacing.md)
                .padding(.vertical, MYSpacing.sm)
                .background(isOn ? MYColor.primary : MYColor.surfaceSecondary)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    Color.clear
        .myBottomSheet(isPresented: .constant(true)) {
            FiltersSheet(initial: .none) { _ in }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
