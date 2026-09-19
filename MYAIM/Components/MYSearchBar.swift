import SwiftUI

/// Editable search field used on the Discover / Search screens.
struct MYSearchBar: View {
    @Binding var text: String
    var placeholder: String = "ابحث عن أكاديمية، مدرب، دورة أو مهارة"
    var onSubmit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: MYSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(MYColor.textSecondary)

            TextField(placeholder, text: $text)
                .font(MYTypography.body)
                .foregroundStyle(MYColor.textPrimary)
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit { onSubmit?() }

            if !text.isEmpty {
                Button {
                    text = ""
                    Haptics.selection()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(MYColor.textTertiary)
                }
            }
        }
        .padding(.horizontal, MYSpacing.md)
        .frame(height: 48)
        .background(MYColor.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
    }
}

/// Non-editable search entry point (a button) used on Home. Tapping opens Search.
struct MYSearchButton: View {
    var placeholder: String = "ابحث عن أكاديمية، مدرب، دورة أو مهارة"
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.light()
            action()
        } label: {
            HStack(spacing: MYSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(MYColor.textSecondary)
                Text(placeholder)
                    .font(MYTypography.body)
                    .foregroundStyle(MYColor.textSecondary)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, MYSpacing.md)
            .frame(height: 48)
            .background(MYColor.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    struct Wrap: View {
        @State var text = ""
        var body: some View {
            VStack(spacing: 16) {
                MYSearchBar(text: $text)
                MYSearchButton {}
            }
            .padding()
        }
    }
    return Wrap().environment(\.layoutDirection, .rightToLeft)
}
