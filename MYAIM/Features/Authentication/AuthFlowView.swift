import SwiftUI

enum AuthRoute: Hashable {
    case register
    case otp
    case forgot
}

/// Hosts the authentication flow (login → register → OTP, and forgot password).
struct AuthFlowView: View {
    @Environment(AppState.self) private var appState
    @State private var vm = AuthViewModel()
    @State private var path: [AuthRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            LoginView(vm: vm, path: $path)
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .register: RegisterView(vm: vm, path: $path)
                    case .otp:      OTPView(vm: vm)
                    case .forgot:   ForgotPasswordView(vm: vm)
                    }
                }
        }
        .tint(MYColor.primary)
        .onAppear {
            vm.onAuthenticated = { user in
                appState.signIn(user)
            }
        }
    }
}

#Preview {
    AuthFlowView()
        .environment(AppState())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
