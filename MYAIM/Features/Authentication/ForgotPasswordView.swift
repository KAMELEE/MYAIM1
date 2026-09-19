import SwiftUI

struct ForgotPasswordView: View {
    @Bindable var vm: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                if vm.resetSent {
                    successState
                } else {
                    formState
                }
            }
            .padding(MYSpacing.screen)
        }
        .myScreenBackground()
        .navigationTitle("نسيت كلمة المرور")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
    }

    private var formState: some View {
        VStack(alignment: .leading, spacing: MYSpacing.lg) {
            VStack(alignment: .leading, spacing: MYSpacing.xs) {
                Text("استعادة كلمة المرور")
                    .font(MYTypography.pageTitle)
                    .foregroundStyle(MYColor.textPrimary)
                Text("أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين.")
                    .font(MYTypography.secondary)
                    .foregroundStyle(MYColor.textSecondary)
            }
            .padding(.top, MYSpacing.sm)

            MYTextField(title: "البريد الإلكتروني", icon: "envelope",
                        placeholder: "name@example.com",
                        text: $vm.forgotEmail, keyboard: .emailAddress,
                        textContentType: .emailAddress,
                        error: vm.fieldErrors["forgotEmail"])

            if let msg = vm.errorMessage {
                AuthErrorBanner(message: msg)
            }

            MYButton(title: "إرسال الرابط", isLoading: vm.isLoading) {
                Task { await vm.requestReset() }
            }
        }
    }

    private var successState: some View {
        VStack(spacing: MYSpacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(MYColor.success)
                .padding(.top, MYSpacing.xxxl)
            Text("تم الإرسال")
                .font(MYTypography.pageTitle)
                .foregroundStyle(MYColor.textPrimary)
            Text("راجع بريدك الإلكتروني \(vm.forgotEmail) لإعادة تعيين كلمة المرور.")
                .font(MYTypography.secondary)
                .foregroundStyle(MYColor.textSecondary)
                .multilineTextAlignment(.center)
            MYButton(title: "العودة لتسجيل الدخول", style: .secondary) {
                dismiss()
            }
            .padding(.top, MYSpacing.md)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack { ForgotPasswordView(vm: AuthViewModel()) }
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
