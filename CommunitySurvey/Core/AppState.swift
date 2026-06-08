import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    private let tokenStore: TokenStoreProtocol
    private let keychainService: KeychainService

    var isAuthenticated = false
    var user: AuthenticatedUser?
    var environment: APIEnvironment

    init(tokenStore: TokenStoreProtocol, keychainService: KeychainService, environment: APIEnvironment = .current) {
        self.tokenStore = tokenStore
        self.keychainService = keychainService
        self.environment = environment
        self.isAuthenticated = false
    }

    func restoreSession() {
        if let session = tokenStore.loadSession(), !session.isExpired {
            try? keychainService.save(token: session.accessToken)
            user = session.user
            isAuthenticated = true
        } else {
            logout()
        }
    }

    func completeLogin(session: AuthSession) {
        tokenStore.save(session: session)
        try? keychainService.save(token: session.accessToken)
        user = session.user
        isAuthenticated = true
    }

    func logout() {
        tokenStore.clear()
        try? keychainService.deleteToken()
        user = nil
        isAuthenticated = false
    }
}
