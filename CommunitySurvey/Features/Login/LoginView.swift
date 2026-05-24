import SwiftUI

struct LoginView: View {
    @State private var viewModel: AuthViewModel

    init(viewModel: AuthViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 24)
            VStack(spacing: 10) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 62, weight: .bold))
                    .foregroundStyle(AppTheme.brandGradient)
                Text("Verified Opinion Network")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Text("Login with your registered mobile number.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            PremiumCard {
                VStack(spacing: 14) {
                    FloatingTextField(
                        title: "Mobile Number",
                        text: mobileBinding,
                        keyboardType: .numberPad
                    )
                    .frame(height: 56) // ← constrain to a sensible height

                    if let errorMessage = viewModel.errorMessage {
                        ErrorBanner(message: errorMessage)
                    }

                    GradientButton(
                        title: "Send OTP",
                        systemImage: "paperplane.fill",
                        isEnabled: viewModel.canLogin
                    ) {
                        Task { await viewModel.login() }
                    }
                }
                .fixedSize(horizontal: false, vertical: true) // ← don't let card grow beyond content
            }
            Spacer()
        }
        .padding(20)
        .background(AppTheme.softGradient.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Register") { viewModel.openRegister() }
            }
        }
        .loadingOverlay(viewModel.isLoading, message: "Sending OTP")
    }

    private var mobileBinding: Binding<String> {
        Binding(get: { viewModel.mobile }, set: { viewModel.mobile = String($0.filter(\.isNumber).prefix(10)) })
    }
}
