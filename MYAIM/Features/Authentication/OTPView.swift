import SwiftUI

struct OTPView: View {
    @Bindable var vm: AuthViewModel

    private let length = 4
    @State private var code = ""
    @FocusState private var focused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: MYSpacing.lg) {
                Image(systemName: "envelope.badge")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(MYColor.primary)
                    .padding(.top, MYSpacing.xl)

                Text("رمز التحقق")
                    .font(MYTypography.pageTitle)
                    .foregroundStyle(MYColor.textPrimary)

                Text("أدخل الرمز المرسل إلى \(destination)")
                    .font(MYTypography.secondary)
                    .foregroundStyle(MYColor.textSecondary)
                    .multilineTextAlignment(.center)

                otpBoxes
                    .padding(.vertical, MYSpacing.md)

                if let msg = vm.errorMessage {
                    AuthErrorBanner(message: msg)
                }

                MYButton(title: "تأكيد", isLoading: vm.isLoading) {
                    Task { await vm.verifyOTP(code) }
                }

                HStack(spacing: MYSpacing.xs) {
                    Text("لم يصلك الرمز؟")
                        .font(MYTypography.secondary)
                        .foregroundStyle(MYColor.textSecondary)
                    Button("إعادة الإرسال") {
                        Haptics.selection()
                        code = ""
                    }
                    .font(.appFont(14, weight: .bold))
                    .foregroundStyle(MYColor.primary)
                }
                .padding(.top, MYSpacing.sm)
            }
            .padding(MYSpacing.screen)
        }
        .myScreenBackground()
        .navigationTitle("التحقق")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            focused = true
            #if DEBUG
            scheduleAutoOTP()
            #endif
        }
    }

    #if DEBUG
        /// CI automation: launched with -autoOTP → enter the demo code and verify,
        /// completing the registration flow end-to-end.
        private func scheduleAutoOTP() {
            guard ProcessInfo.processInfo.arguments.contains("-autoOTP") else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                code = "1234"
                Task { await vm.verifyOTP("1234") }
            }
        }
        #endif

    private var destination: String {
        vm.regPhone.isEmpty ? "بريدك الإلكتروني" : vm.regPhone
    }

    private var otpBoxes: some View {
        ZStack {
            // Hidden field captures digits.
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($focused)
                .opacity(0.02)
                .onChange(of: code) { _, newValue in
                    let digits = newValue.filter(\.isNumber)
                    code = String(digits.prefix(length))
                    if code.count == length {
                        Task { await vm.verifyOTP(code) }
                    }
                }

            HStack(spacing: MYSpacing.md) {
                ForEach(0..<length, id: \.self) { index in
                    box(at: index)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { focused = true }
        }
    }

    private func box(at index: Int) -> some View {
        let chars = Array(code)
        let isActive = index == code.count
        let digit = index < chars.count ? String(chars[index]) : ""
        return Text(digit)
            .font(MYTypography.pageTitle)
            .foregroundStyle(MYColor.textPrimary)
            .frame(width: 58, height: 62)
            .background(MYColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                    .strokeBorder(isActive ? MYColor.primary : MYColor.border,
                                  lineWidth: isActive ? 2 : 1)
            )
    }
}

#Preview {
    NavigationStack { OTPView(vm: AuthViewModel()) }
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
