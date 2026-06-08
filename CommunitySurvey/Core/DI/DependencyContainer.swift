import Foundation

@MainActor
struct DependencyContainer {
    let environment: APIEnvironment
    let validationManager: ValidationManager
    let keychainManager: KeychainManaging
    let keychainService: KeychainService
    let userDefaultsStore: UserDefaultsStoreProtocol
    let tokenStore: TokenStoreProtocol
    let networkMonitor: NetworkMonitoring
    let apiClient: APIClientProtocol
    let authService: AuthServiceProtocol
    let profileService: ProfileServiceProtocol
    let organizationService: OrganizationServiceProtocol
    let locationService: LocationServiceProtocol
    let surveyService: SurveyServiceProtocol
    let walletService: WalletServiceProtocol
    let adminService: AdminServiceProtocol
    let aadhaarService: AadhaarServiceProtocol
    let surveyRepository: SurveyRepositoryProtocol
    let surveyStateStore: SurveyStateStore
    let appState: AppState
    let sessionManager: SessionManager
    let roleManager: RoleManager
    let themeManager: ThemeManager
    let router: AppRouter

    static func live() -> DependencyContainer {
        let environment = APIEnvironment.current
        let validationManager = ValidationManager()
        let keychainManager = KeychainManager(service: "com.verifiedopinionnetwork.auth")
        let keychainService = KeychainService()
        let userDefaultsStore = UserDefaultsStore()
        let tokenStore = TokenStore(keychain: keychainManager)
        let networkMonitor = NetworkMonitor()
        let interceptor = RequestInterceptor(keychainService: keychainService)
        let apiClient = APIClient(environment: environment, interceptor: interceptor, networkMonitor: networkMonitor)
        let authService = AuthService(apiClient: apiClient, keychainService: keychainService)
        let profileService = ProfileService(authService: authService)
        let organizationService = OrganizationService(apiClient: apiClient)
        let locationService = LocationService(apiClient: apiClient)
        let surveyService = SurveyAPIService(apiClient: apiClient)
        let walletService = WalletService(apiClient: apiClient)
        let adminService = AdminService(apiClient: apiClient)
        let aadhaarService = MockAadhaarService()
        let surveyRepository = SurveyRepository(surveyService: surveyService)
        let surveyStateStore = SurveyStateStore(repository: surveyRepository)
        let appState = AppState(tokenStore: tokenStore, keychainService: keychainService, environment: environment)
        let sessionManager = SessionManager(appState: appState)
        let roleManager = RoleManager(sessionManager: sessionManager)
        let themeManager = ThemeManager.shared
        let router = AppRouter()

        return DependencyContainer(
            environment: environment,
            validationManager: validationManager,
            keychainManager: keychainManager,
            keychainService: keychainService,
            userDefaultsStore: userDefaultsStore,
            tokenStore: tokenStore,
            networkMonitor: networkMonitor,
            apiClient: apiClient,
            authService: authService,
            profileService: profileService,
            organizationService: organizationService,
            locationService: locationService,
            surveyService: surveyService,
            walletService: walletService,
            adminService: adminService,
            aadhaarService: aadhaarService,
            surveyRepository: surveyRepository,
            surveyStateStore: surveyStateStore,
            appState: appState,
            sessionManager: sessionManager,
            roleManager: roleManager,
            themeManager: themeManager,
            router: router
        )
    }
}
