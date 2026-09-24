import SwiftUI

struct LoginView: View {
    @Bindable var vm: AuthViewModel
    @Binding var path: [AuthRoute]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                VStack(alignment: .center, spacing: MYSpacing.md) {
                    MYLogo(size: 72)
                    Text("مرحبًا بعودتك")
                        .font(MYTypography.pageTitle)
                        .foregroundStyle(MYColor.textPrimary)
                    Text("سجّل دخولك لمتابعة رحلتك نحو هدفك")
                        .font(MYTypography.secondary)
                        .foregroundStyle(MYColor.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, MYSpacing.xl)

                MYTextField(title: "البريد الإلكتروني", icon: "envelope",
                            placeholder: "name@example.com",
                            text: $vm.loginEmail, keyboard: .emailAddress,
                            textContentType: .emailAddress,
                            error: vm.fieldErrors["loginEmail"])

                MYTextField(title: "كلمة المرور", icon: "lock",
                            placeholder: "••••••••",
                            text: $vm.loginPassword, isSecure: true,
                            textContentType: .password,
                            error: vm.fieldErrors["loginPassword"])

                Button("نسيت كلمة المرور؟") { path.append(.forgot) }
                    .font(MYTypography.secondary)
                    .foregroundStyle(MYColor.primary)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                if let msg = vm.errorMessage {
                    AuthErrorBanner(message: msg)
                }

                MYButton(title: "تسجيل الدخول", isLoading: vm.isLoading) {
                    Task { await vm.login() }
                }

                HStack(spacing: MYSpacing.xs) {
                    Text("ليس لديك حساب؟")
                        .font(MYTypography.secondary)
                        .foregroundStyle(MYColor.textSecondary)
                    Button("إنشاء حساب") { path.append(.register) }
                        .font(.appFont(14, weight: .bold))
                        .foregroundStyle(MYColor.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, MYSpacing.sm)
            }
            .padding(MYSpacing.screen)
        }
        .myScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        #if DEBUG
        .onAppear { scheduleAutoLogin() }
        #endif
    }

    #if DEBUG
        /// CI automation: launched with -autoLogin → fill demo credentials and
        /// submit, so the build pipeline can exercise the login flow end-to-end.
        private func scheduleAutoLogin() {
            guard ProcessInfo.processInfo.arguments.contains("-autoLogin") else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                vm.loginEmail = "demo@myaim.app"
                vm.loginPassword = "Demo1234!"
                Task { await vm.login() }
            }
        }
        #endif
}

/// Inline error banner shared by auth screens.
struct AuthErrorBanner: View {
    let message: String
    var body: some View {
        HStack(spacing: MYSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(MYColor.error)
            Text(message)
                .font(MYTypography.secondary)
                .foregroundStyle(MYColor.error)
        }
        .padding(MYSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MYColor.error.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: MYRadius.sm, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        LoginView(vm: AuthViewModel(), path: .constant([]))
    }
    .environment(\.layoutDirection, .rightToLeft)
    .environment(\.locale, Locale(identifier: "ar"))
}
