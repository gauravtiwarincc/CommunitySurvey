import SwiftUI

struct AadhaarVerificationView: View {
    @State private var viewModel: AadhaarViewModel
    @FocusState private var aadhaarFocused: Bool

    init(viewModel: AadhaarViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            GradientBrandCard {
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                    Text("Aadhaar Verification")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                    Text("Securely verify identity before entering paid public opinion surveys.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.82))
                }
            }
            PremiumCard {
                VStack(alignment: .leading, spacing: 14) {
                    FloatingTextField(title: "12-digit Aadhaar", text: aadhaarBinding, keyboardType: .numberPad, isSecure: true)
                        .focused($aadhaarFocused)
                    if !viewModel.aadhaarNumber.isEmpty {
                        Text(viewModel.maskedAadhaar)
                            .font(.footnote.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    if viewModel.state.isLoading {
                        ShimmerView().frame(height: 18)
                    }
                    if let errorMessage = viewModel.errorMessage {
                        ErrorBanner(message: errorMessage)
                    }
                    GradientButton(title: "Complete Verification", systemImage: "lock.shield.fill", isEnabled: viewModel.canVerify) {
                        aadhaarFocused = false
                        Task { await viewModel.verify() }
                    }
                }
            }
            Spacer()
        }
        .padding(20)
        .background(AppTheme.softGradient.ignoresSafeArea())
        .navigationTitle("Aadhaar")
        .loadingOverlay(viewModel.state.isLoading, message: "Verifying Aadhaar")
    }

    private var aadhaarBinding: Binding<String> {
        Binding(get: { viewModel.aadhaarNumber }, set: { viewModel.aadhaarNumber = String($0.filter(\.isNumber).prefix(12)) })
    }
}

#Preview {
    NavigationStack {
        let container = DependencyContainer.live()
        AadhaarVerificationView(viewModel: AadhaarViewModel(validationManager: container.validationManager, aadhaarService: container.aadhaarService, router: container.router))
    }
}
