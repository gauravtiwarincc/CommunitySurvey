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
    let surveyService: SurveyServiceProtocol
    let walletService: WalletServiceProtocol
    let aadhaarService: AadhaarServiceProtocol
    let surveyRepository: SurveyRepositoryProtocol
    let appState: AppState
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
        let surveyService = SurveyAPIService(apiClient: apiClient)
        let walletService = WalletService(apiClient: apiClient)
        let aadhaarService = MockAadhaarService()
        let surveyRepository = MockSurveyRepository()
        let appState = AppState(tokenStore: tokenStore, environment: environment)
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
            surveyService: surveyService,
            walletService: walletService,
            aadhaarService: aadhaarService,
            surveyRepository: surveyRepository,
            appState: appState,
            router: router
        )
    }
}
