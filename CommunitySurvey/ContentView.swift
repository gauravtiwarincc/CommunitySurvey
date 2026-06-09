import SwiftUI

struct ContentView: View {
    @State private var container = DependencyContainer.live()
    @State private var showSplash = true

    @State private var hasCompletedOnboarding = false

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
                } else if !hasCompletedOnboarding {
                    OrganizationCodeView(
                        themeManager: container.themeManager,
                        organizationService: container.organizationService,
                        onComplete: { hasCode in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                hasCompletedOnboarding = true
                            }
                            if hasCode {
                                container.router.navigate(to: .registration)
                            }
                        }
                    )
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
                try? await container.themeManager.loadConfig(code: nil, using: container.organizationService)
            }
        }
        .onChange(of: container.sessionManager.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                Task {
                    try? await container.themeManager.loadConfig(code: nil, using: container.organizationService)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UserSessionExpired"))) { notification in
            if let message = notification.userInfo?["message"] as? String {
                container.sessionManager.logout()
                presentGlobalAlert(title: "Session Expired", message: message)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UserDeactivatedDuringAuth"))) { notification in
            if let message = notification.userInfo?["message"] as? String {
                presentGlobalAlert(title: "Account Deactivated", message: message)
            }
        }
    }

    private func presentGlobalAlert(title: String, message: String) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            topVC.present(alert, animated: true)
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
                AdminUserDetailView(viewModel: AdminUserDetailViewModel(userID: id, adminService: container.adminService, sessionManager: container.sessionManager))
            }
        case .adminSurveyManagement:
            adminOnly {
                AdminSurveyListView(router: container.router)
            }
        case .createSurvey:
            adminWriteOnly {
                CreateSurveyView(viewModel: CreateSurveyViewModel(adminService: container.adminService))
            }
        case .adminThemeCustomization:
            adminWriteOnly {
                AdminThemeCustomizationView(viewModel: AdminThemeCustomizationViewModel(adminService: container.adminService, themeManager: container.themeManager, sessionManager: container.sessionManager))
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
