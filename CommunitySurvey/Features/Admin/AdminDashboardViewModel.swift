import Foundation
import Observation

@MainActor
@Observable
final class AdminDashboardViewModel {
    var dashboardResponse: AdminDashboardResponse?
    var isLoading = false
    var errorMessage: String?

    private let adminService: AdminServiceProtocol

    init(adminService: AdminServiceProtocol) {
        self.adminService = adminService
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            dashboardResponse = try await adminService.fetchDashboard()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
