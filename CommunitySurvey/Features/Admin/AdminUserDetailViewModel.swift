import Foundation
import Observation

@MainActor
@Observable
final class AdminUserDetailViewModel {
    let userID: String
    var userProfile: UserProfileInfo?
    var completedSurveys: [CompletedSurveyItem] = []
    var pendingSurveys: [PendingSurveyItem] = []
    var isLoading = false
    var errorMessage: String?

    private let adminService: AdminServiceProtocol
    private let sessionManager: SessionManager

    init(userID: String, adminService: AdminServiceProtocol, sessionManager: SessionManager) {
        self.userID = userID
        self.adminService = adminService
        self.sessionManager = sessionManager
    }

    var isSelf: Bool {
        userID == sessionManager.currentUser?.id
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            let response = try await adminService.fetchUserDetail(id: userID)
            userProfile = response.user
            completedSurveys = response.completedSurveys
            pendingSurveys = response.pendingSurveys
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func toggleUserStatus() async {
        guard let currentProfile = userProfile else { return }
        let targetStatus = !currentProfile.isActive
        isLoading = true
        errorMessage = nil
        do {
            let response = try await adminService.updateUserStatus(id: userID, isActive: targetStatus)
            if response.success {
                userProfile?.isActive = response.user.isActive
            } else {
                errorMessage = "Failed to update status."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
