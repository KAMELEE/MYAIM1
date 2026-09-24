import SwiftUI

struct RegisterView: View {
    @Bindable var vm: AuthViewModel
    @Binding var path: [AuthRoute]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                VStack(alignment: .leading, spacing: MYSpacing.xs) {
                    Text("إنشاء حساب")
                        .font(MYTypography.pageTitle)
                        .foregroundStyle(MYColor.textPrimary)
                    Text("انضم إلى MY AIM وابدأ بتحقيق أهدافك")
                        .font(MYTypography.secondary)
                        .foregroundStyle(MYColor.textSecondary)
                }
                .padding(.top, MYSpacing.sm)

                MYTextField(title: "الاسم", icon: "person",
                            placeholder: "اسمك الكامل",
                            text: $vm.regName, textContentType: .name,
                            error: vm.fieldErrors["regName"])

                MYTextField(title: "البريد الإلكتروني", icon: "envelope",
                            placeholder: "name@example.com",
                            text: $vm.regEmail, keyboard: .emailAddress,
                            textContentType: .emailAddress,
                            error: vm.fieldErrors["regEmail"])

                MYTextField(title: "رقم الجوال", icon: "phone",
                            placeholder: "05XXXXXXXX",
                            text: $vm.regPhone, keyboard: .phonePad,
                            textContentType: .telephoneNumber,
                            error: vm.fieldErrors["regPhone"])

                MYTextField(title: "كلمة المرور", icon: "lock",
                            placeholder: "6 أحرف على الأقل",
                            text: $vm.regPassword, isSecure: true,
                            textContentType: .newPassword,
                            error: vm.fieldErrors["regPassword"])

                if let msg = vm.errorMessage {
                    AuthErrorBanner(message: msg)
                }

                MYButton(title: "إنشاء الحساب", isLoading: vm.isLoading) {
                    Task {
                        if await vm.register() { path.append(.otp) }
                    }
                }
                .padding(.top, MYSpacing.xs)

                Text("بإنشائك الحساب فإنك توافق على الشروط والأحكام وسياسة الخصوصية.")
                    .font(MYTypography.caption)
                    .foregroundStyle(MYColor.textTertiary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(MYSpacing.screen)
        }
        .myScreenBackground()
        .navigationTitle("إنشاء حساب")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        #if DEBUG
        .onAppear { scheduleAutoRegister() }
        #endif
    }

    #if DEBUG
        /// CI automation: launched with -autoRegister → fill demo values and
        /// submit, navigating to OTP exactly like a real user would.
        private func scheduleAutoRegister() {
            guard ProcessInfo.processInfo.arguments.contains("-autoRegister") else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                vm.regName = "مستخدم تجربة"
                vm.regEmail = "demo@myaim.app"
                vm.regPhone = "0555555555"
                vm.regPassword = "Demo1234!"
                Task { if await vm.register() { path.append(.otp) } }
            }
        }
        #endif
}

#Preview {
    NavigationStack {
        RegisterView(vm: AuthViewModel(), path: .constant([]))
    }
    .environment(\.layoutDirection, .rightToLeft)
    .environment(\.locale, Locale(identifier: "ar"))
}
