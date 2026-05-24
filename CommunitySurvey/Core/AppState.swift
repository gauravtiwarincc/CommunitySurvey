import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    private let tokenStore: TokenStoreProtocol

    var isAuthenticated = false
    var user: AuthenticatedUser?
    var environment: APIEnvironment

    init(tokenStore: TokenStoreProtocol, environment: APIEnvironment = .current) {
        self.tokenStore = tokenStore
        self.environment = environment
        self.isAuthenticated = tokenStore.loadSession() != nil
    }

    func restoreSession() {
        if let session = tokenStore.loadSession(), !session.isExpired {
            user = session.user
            isAuthenticated = true
        } else {
            logout()
        }
    }

    func completeLogin(session: AuthSession) {
        tokenStore.save(session: session)
        user = session.user
        isAuthenticated = true
    }

    func logout() {
        tokenStore.clear()
        user = nil
        isAuthenticated = false
    }
}
