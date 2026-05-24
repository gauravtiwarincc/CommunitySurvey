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

    var availableSurveys: [Survey] { dashboard?.availableSurveys ?? [] }
    var completedSurveys: [Survey] { dashboard?.completedSurveys ?? [] }
    var stats: DashboardStats {
        dashboard?.stats ?? DashboardStats(availableCount: 0, completedCount: 0, rewardPoints: 0, walletBalance: 0)
    }
    var isEmpty: Bool { hasLoaded && availableSurveys.isEmpty && completedSurveys.isEmpty && errorMessage == nil }

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
        guard let index = dashboard.availableSurveys.firstIndex(where: { $0.id == surveyID }) else { return }
        var completedSurvey = dashboard.availableSurveys.remove(at: index)
        completedSurvey.isCompleted = true
        dashboard.completedSurveys.insert(completedSurvey, at: 0)
        dashboard.stats.availableCount = dashboard.availableSurveys.count
        dashboard.stats.completedCount = dashboard.completedSurveys.count
        dashboard.stats.rewardPoints += rewardEarned
        dashboard.stats.walletBalance += rewardEarned
        self.dashboard = dashboard
    }
}
