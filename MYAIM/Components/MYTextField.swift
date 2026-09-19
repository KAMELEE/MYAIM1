import SwiftUI

/// Labeled input field with an icon, optional secure toggle, and inline error.
struct MYTextField: View {
    let title: String
    var icon: String
    var placeholder: String = ""
    @Binding var text: String
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var error: String? = nil

    @State private var revealSecure = false
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: MYSpacing.xs) {
            Text(title)
                .font(MYTypography.caption)
                .foregroundStyle(MYColor.textSecondary)

            HStack(spacing: MYSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(focused ? MYColor.primary : MYColor.textTertiary)
                    .frame(width: 20)

                Group {
                    if isSecure && !revealSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .font(MYTypography.body)
                .foregroundStyle(MYColor.textPrimary)
                .keyboardType(keyboard)
                .textContentType(textContentType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focused)

                if isSecure {
                    Button {
                        revealSecure.toggle()
                    } label: {
                        Image(systemName: revealSecure ? "eye.slash" : "eye")
                            .font(.system(size: 15))
                            .foregroundStyle(MYColor.textTertiary)
                    }
                }
            }
            .padding(.horizontal, MYSpacing.md)
            .frame(height: 52)
            .background(MYColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 1)
            )

            if let error {
                Text(error)
                    .font(MYTypography.caption)
                    .foregroundStyle(MYColor.error)
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.15), value: error)
        .animation(.easeOut(duration: 0.15), value: focused)
    }

    private var borderColor: Color {
        if error != nil { return MYColor.error }
        return focused ? MYColor.primary : MYColor.border
    }
}

#Preview {
    struct Wrap: View {
        @State var email = ""
        @State var pass = ""
        var body: some View {
            VStack(spacing: 16) {
                MYTextField(title: "البريد الإلكتروني", icon: "envelope",
                            placeholder: "name@example.com", text: $email, keyboard: .emailAddress)
                MYTextField(title: "كلمة المرور", icon: "lock",
                            placeholder: "••••••", text: $pass, isSecure: true,
                            error: "كلمة المرور 6 أحرف على الأقل")
            }
            .padding()
            .myScreenBackground()
        }
    }
    return Wrap().environment(\.layoutDirection, .rightToLeft)
}
