import Foundation
import Observation

@MainActor
@Observable
final class SessionManager {
    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    var isAuthenticated: Bool { appState.isAuthenticated }
    var currentUser: AuthenticatedUser? { appState.user }
    var currentRole: UserRole { appState.user?.role ?? .user }
    var currentOrganization: OrganizationConfig? { appState.user?.organization }

    func completeLogin(session: AuthSession) {
        appState.completeLogin(session: session)
    }

    func updateUser(user: AuthenticatedUser) {
        appState.updateUser(user: user)
    }

    func restore() {
        appState.restoreSession()
    }

    func logout() {
        appState.logout()
    }
}

@MainActor
@Observable
final class RoleManager {
    private let sessionManager: SessionManager

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }

    var currentRole: UserRole { sessionManager.currentRole }
    var canAccessAdmin: Bool { currentRole == .admin || currentRole == .superAdmin }
    var canAccessSuperAdminControls: Bool { currentRole == .superAdmin }
    var canPerformAdminWrites: Bool { currentRole == .admin }
}
