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
                } else if container.sessionManager.isAuthenticated {
                    MainTabView(container: container)
                } else {
                    LoginView(viewModel: makeAuthViewModel())
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
            }
        }
        .environment(\.themeManager, container.themeManager)
        .tint(AppTheme.accent)
        .task {
            await container.themeManager.load()
            container.sessionManager.restore()
            container.themeManager.apply(organization: container.sessionManager.currentUser?.organization)
            if container.sessionManager.isAuthenticated {
                showSplash = false
            }
        }
    }

    private func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(authService: container.authService, organizationService: container.organizationService, locationService: container.locationService, sessionManager: container.sessionManager, themeManager: container.themeManager, surveyStore: container.surveyStateStore, router: container.router)
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
            ProfileView(viewModel: ProfileViewModel(profileService: container.profileService, authService: container.authService, surveyStore: container.surveyStateStore, sessionManager: container.sessionManager, themeManager: container.themeManager, router: container.router))
        case .otp(let mobileNumber, let countryCode, let transactionID, let debugOTP):
            OTPVerificationView(viewModel: OTPVerificationViewModel(mobileNumber: mobileNumber, countryCode: countryCode, transactionID: transactionID, debugOTP: debugOTP, validationManager: container.validationManager, authService: container.authService, sessionManager: container.sessionManager, themeManager: container.themeManager, surveyStore: container.surveyStateStore, router: container.router))
        case .aadhaar:
            AadhaarVerificationView(viewModel: AadhaarViewModel(validationManager: container.validationManager, aadhaarService: container.aadhaarService, router: container.router))
        case .verificationStatus(let result):
            VerificationStatusView(result: result) { container.router.resetToRoot() }
        case .dashboard:
            DashboardView(viewModel: DashboardViewModel(surveyStore: container.surveyStateStore), router: container.router)
        case .survey(let survey):
            SurveyQuestionView(viewModel: SurveyViewModel(survey: survey, repository: container.surveyRepository, router: container.router))
        case .rewards:
            RewardsView(viewModel: RewardsViewModel(repository: container.surveyRepository))
        case .adminUsers:
            adminOnly {
                AdminUsersView(viewModel: AdminUsersViewModel(adminService: container.adminService), router: container.router)
            }
        case .adminUserDetail(let id):
            adminOnly {
                AdminUserDetailView(viewModel: AdminUserDetailViewModel(userID: id, adminService: container.adminService))
            }
        case .adminSurveyManagement:
            adminOnly {
                AdminSurveyListView(router: container.router)
            }
        case .createSurvey:
            adminWriteOnly {
                CreateSurveyView(viewModel: CreateSurveyViewModel(adminService: container.adminService))
            }
        }
    }

    @ViewBuilder
    private func adminOnly<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if container.roleManager.canAccessAdmin {
            content()
        } else {
            ErrorStateView(message: "Admin access is required for this screen.") {
                container.router.resetToRoot()
            }
        }
    }

    @ViewBuilder
    private func adminWriteOnly<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if container.roleManager.canPerformAdminWrites {
            content()
        } else if container.roleManager.canAccessAdmin {
            ErrorStateView(message: "This action is read-only for platform administrators.") {
                container.router.resetToRoot()
            }
        } else {
            ErrorStateView(message: "Admin access is required for this screen.") {
                container.router.resetToRoot()
            }
        }
    }
}

#Preview {
    ContentView()
}
