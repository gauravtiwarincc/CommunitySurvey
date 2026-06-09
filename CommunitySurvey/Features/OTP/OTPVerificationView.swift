import SwiftUI

struct OTPVerificationView: View {
    @State private var viewModel: OTPVerificationViewModel

    init(viewModel: OTPVerificationViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            PremiumCard {
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "message.badge.filled.fill")
                        .font(.title)
                        .foregroundStyle(AppTheme.brandGradient)
                    Text("Verify OTP")
                        .font(.largeTitle.bold())
                    Text("Enter the 6-digit code sent to \(viewModel.countryCode) \(viewModel.mobileNumber).")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            OTPInputView(digits: $viewModel.digits, onDigitChanged: viewModel.updateDigit, onAutoFill: viewModel.applyAutoFill)
                .frame(maxWidth: .infinity, alignment: .center)
            if let debugOTP = viewModel.debugOTP {
                developmentOTPBanner(debugOTP)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            if let errorMessage = viewModel.errorMessage {
                ErrorBanner(message: errorMessage)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            GradientButton(title: "Verify & Continue", systemImage: "checkmark.circle.fill", isEnabled: viewModel.canVerify) {
                Task { await viewModel.verify() }
            }
            HStack {
                Text(viewModel.canResend ? "Didn't receive it?" : "Resend available in \(viewModel.resendSecondsRemaining)s")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Resend") { Task { await viewModel.resend() } }
                    .disabled(!viewModel.canResend)
            }
            .accessibilityElement(children: .combine)
            Spacer()
        }
        .padding(20)
        .background(AppTheme.softGradient.ignoresSafeArea())
        .navigationTitle("OTP")
        .loadingOverlay(viewModel.state.isLoading, message: "Verifying OTP")
        .animation(.spring(response: 0.32, dampingFraction: 0.84), value: viewModel.errorMessage)
        .onAppear {
            viewModel.fillDebugOTP()
        }
    }

    private func developmentOTPBanner(_ otp: String) -> some View {
        Button {
            viewModel.fillDebugOTP()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "number.square.fill")
                    .foregroundStyle(AppTheme.deepSaffron)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Development OTP")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(otp)
                        .font(.title3.weight(.bold).monospacedDigit())
                        .foregroundStyle(.primary)
                }
                Spacer()
                Text("Tap to fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.indiaGreen)
            }
            .padding(12)
            .background(AppTheme.saffron.opacity(0.14), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppTheme.saffron.opacity(0.24), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Development OTP is \(otp). Tap to fill OTP fields.")
    }
}

#Preview {
    NavigationStack {
        let container = DependencyContainer.live()
        OTPVerificationView(viewModel: OTPVerificationViewModel(mobileNumber: "9876543210", countryCode: "+91", validationManager: container.validationManager, authService: container.authService, sessionManager: container.sessionManager, router: container.router))
    }
}
