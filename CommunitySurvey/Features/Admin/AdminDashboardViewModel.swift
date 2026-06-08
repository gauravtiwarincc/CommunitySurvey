import Foundation
import Observation

@MainActor
@Observable
final class AdminDashboardViewModel {
    var dashboard: AdminDashboard?
    var analytics: [SurveyAnalytics] = []
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
            async let dashboard = adminService.fetchDashboard()
            async let analytics = adminService.fetchSurveyAnalytics()
            self.dashboard = try await dashboard
            self.analytics = try await analytics
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
