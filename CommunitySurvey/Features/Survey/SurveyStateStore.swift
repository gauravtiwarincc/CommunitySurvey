import Foundation
import Observation

@MainActor
@Observable
final class SurveyStateStore {
    private let repository: SurveyRepositoryProtocol

    var dashboard: DashboardSurveyResponse?
    var isLoading = false
    var errorMessage: String?
    private var hasLoaded = false

    init(repository: SurveyRepositoryProtocol) {
        self.repository = repository
    }

    var availableSurveys: [Survey] { (dashboard?.availableSurveys ?? []) + (dashboard?.organizationSurveys ?? []) }
    var completedSurveys: [Survey] { (dashboard?.completedSurveys ?? []) + (dashboard?.completedOrganizationSurveys ?? []) }
    var availableGlobalSurveys: [Survey] { dashboard?.availableSurveys ?? [] }
    var completedGlobalSurveys: [Survey] { dashboard?.completedSurveys ?? [] }
    var availableOrgSurveys: [Survey] { dashboard?.organizationSurveys ?? [] }
    var completedOrgSurveys: [Survey] { dashboard?.completedOrganizationSurveys ?? [] }

    var stats: DashboardStats {
        dashboard?.stats ?? DashboardStats(availableCount: 0, completedCount: 0, rewardPoints: 0, walletBalance: 0)
    }
    var isEmpty: Bool { hasLoaded && availableGlobalSurveys.isEmpty && completedGlobalSurveys.isEmpty && availableOrgSurveys.isEmpty && completedOrgSurveys.isEmpty && errorMessage == nil }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        await refresh()
    }

    func reset() {
        dashboard = nil
        errorMessage = nil
        isLoading = false
        hasLoaded = false
    }

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            dashboard = try await repository.fetchDashboardSurveys()
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func markCompleted(surveyID: String, rewardEarned: Int) {
        guard var dashboard else { return }
        
        if let index = dashboard.availableSurveys.firstIndex(where: { $0.id == surveyID }) {
            var completedSurvey = dashboard.availableSurveys.remove(at: index)
            completedSurvey.isCompleted = true
            dashboard.completedSurveys.insert(completedSurvey, at: 0)
            
            var currentStats = dashboard.stats ?? DashboardStats(availableCount: 0, completedCount: 0, rewardPoints: 0, walletBalance: 0)
            currentStats.availableCount = dashboard.availableSurveys.count + (dashboard.organizationSurveys?.count ?? 0)
            currentStats.completedCount = dashboard.completedSurveys.count + (dashboard.completedOrganizationSurveys?.count ?? 0)
            currentStats.rewardPoints += rewardEarned
            currentStats.walletBalance += rewardEarned
            dashboard.stats = currentStats
            
            self.dashboard = dashboard
        } else if var orgSurveys = dashboard.organizationSurveys,
                  let index = orgSurveys.firstIndex(where: { $0.id == surveyID }) {
            var completedSurvey = orgSurveys.remove(at: index)
            completedSurvey.isCompleted = true
            dashboard.organizationSurveys = orgSurveys
            
            var completedOrgSurveys = dashboard.completedOrganizationSurveys ?? []
            completedOrgSurveys.insert(completedSurvey, at: 0)
            dashboard.completedOrganizationSurveys = completedOrgSurveys
            
            var currentStats = dashboard.stats ?? DashboardStats(availableCount: 0, completedCount: 0, rewardPoints: 0, walletBalance: 0)
            currentStats.availableCount = dashboard.availableSurveys.count + orgSurveys.count
            currentStats.completedCount = dashboard.completedSurveys.count + completedOrgSurveys.count
            currentStats.rewardPoints += rewardEarned
            currentStats.walletBalance += rewardEarned
            dashboard.stats = currentStats
            
            self.dashboard = dashboard
        }
    }
}
