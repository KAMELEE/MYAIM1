import SwiftUI

/// A drag handle + title + optional close button, for the top of a bottom sheet.
struct MYSheetHeader: View {
    let title: String
    var onClose: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: MYSpacing.sm) {
            Capsule()
                .fill(MYColor.border)
                .frame(width: 40, height: 5)
                .padding(.top, MYSpacing.sm)

            HStack {
                Text(title)
                    .font(MYTypography.section)
                    .foregroundStyle(MYColor.textPrimary)
                Spacer()
                if let onClose {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(MYColor.textSecondary)
                            .frame(width: 30, height: 30)
                            .background(MYColor.surfaceSecondary)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("إغلاق")
                }
            }
        }
    }
}

/// A two-action footer used by the filters sheet: "إعادة تعيين" + "عرض النتائج".
struct MYSheetFooter: View {
    var resetTitle: String = "إعادة تعيين"
    var applyTitle: String = "عرض النتائج"
    let onReset: () -> Void
    let onApply: () -> Void

    var body: some View {
        HStack(spacing: MYSpacing.md) {
            MYButton(title: resetTitle, style: .outline, action: onReset)
                .frame(maxWidth: 130)
            MYButton(title: applyTitle, style: .primary, action: onApply)
        }
        .padding(.top, MYSpacing.sm)
        .background(MYColor.surface)
    }
}

extension View {
    /// Presents a native bottom sheet with MY AIM defaults (medium/large detents).
    func myBottomSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        detents: Set<PresentationDetent> = [.medium, .large],
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            content()
                .padding(.horizontal, MYSpacing.lg)
                .presentationDetents(detents)
                .presentationDragIndicator(.hidden) // we draw our own handle
                .presentationCornerRadius(MYRadius.xl)
        }
    }
}

#Preview {
    struct Wrap: View {
        @State var show = true
        var body: some View {
            Color.clear
                .myBottomSheet(isPresented: $show) {
                    VStack(alignment: .leading, spacing: 16) {
                        MYSheetHeader(title: "الفلاتر", onClose: { show = false })
                        Spacer()
                        MYSheetFooter(onReset: {}, onApply: { show = false })
                    }
                    .padding(.bottom, MYSpacing.lg)
                }
        }
    }
    return Wrap().environment(\.layoutDirection, .rightToLeft)
}
