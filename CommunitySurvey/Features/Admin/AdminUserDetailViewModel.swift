import Foundation
import Observation

@MainActor
@Observable
final class AdminUserDetailViewModel {
    let userID: String
    var user: AdminUser?
    var isLoading = false
    var errorMessage: String?

    private let adminService: AdminServiceProtocol

    init(userID: String, adminService: AdminServiceProtocol) {
        self.userID = userID
        self.adminService = adminService
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            user = try await adminService.fetchUserDetail(id: userID)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
