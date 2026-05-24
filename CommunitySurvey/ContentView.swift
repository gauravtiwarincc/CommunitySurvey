import SwiftUI

struct ContentView: View {
    @State private var container = DependencyContainer.live()
    @State private var showSplash = true

    var body: some View {
        @Bindable var router = container.router

        NavigationStack(path: $router.path) {
            Group {
                if showSplash {
                    SplashView {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            showSplash = false
                        }
                    }
                } else {
                    LoginView(viewModel: makeAuthViewModel())
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
            }
        }
        .tint(AppTheme.indiaGreen)
        .onAppear {
            if container.authService.isAuthenticated() {
                showSplash = false
                container.router.replaceStack(with: .dashboard)
            }
        }
    }

    private func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(authService: container.authService, router: container.router)
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .registration:
            RegisterView(viewModel: makeAuthViewModel())
        case .login:
            LoginView(viewModel: makeAuthViewModel())
        case .surveyList:
            SurveyListView(viewModel: SurveyListViewModel(surveyStore: container.surveyStateStore), router: container.router)
        case .surveyDetail(let id):
            SurveyDetailView(viewModel: SurveyDetailViewModel(surveyID: id, repository: container.surveyRepository, surveyStore: container.surveyStateStore))
        case .wallet:
            WalletView(viewModel: WalletViewModel(walletService: container.walletService))
        case .profile:
            ProfileView(viewModel: ProfileViewModel(profileService: container.profileService, authService: container.authService, surveyStore: container.surveyStateStore, router: container.router))
        case .otp(let mobileNumber, let countryCode, let transactionID, let debugOTP):
            OTPVerificationView(viewModel: OTPVerificationViewModel(mobileNumber: mobileNumber, countryCode: countryCode, transactionID: transactionID, debugOTP: debugOTP, validationManager: container.validationManager, authService: container.authService, appState: container.appState, surveyStore: container.surveyStateStore, router: container.router))
        case .aadhaar:
            AadhaarVerificationView(viewModel: AadhaarViewModel(validationManager: container.validationManager, aadhaarService: container.aadhaarService, router: container.router))
        case .verificationStatus(let result):
            VerificationStatusView(result: result) { container.router.replaceStack(with: .dashboard) }
        case .dashboard:
            DashboardView(viewModel: DashboardViewModel(surveyStore: container.surveyStateStore), router: container.router)
        case .survey(let survey):
            SurveyQuestionView(viewModel: SurveyViewModel(survey: survey, repository: container.surveyRepository, router: container.router))
        case .rewards:
            RewardsView(viewModel: RewardsViewModel(repository: container.surveyRepository))
        }
    }
}

#Preview {
    ContentView()
}
