import Foundation
import Observation

@MainActor
@Observable
final class SurveyListViewModel {
    private let surveyStore: SurveyStateStore

    init(surveyStore: SurveyStateStore) {
        self.surveyStore = surveyStore
    }

    var availableSurveys: [Survey] { surveyStore.availableSurveys }
    var completedSurveys: [Survey] { surveyStore.completedSurveys }
    var stats: DashboardStats { surveyStore.stats }
    var isLoading: Bool { surveyStore.isLoading }
    var errorMessage: String? { surveyStore.errorMessage }
    var hasEmptyState: Bool { surveyStore.isEmpty }
    var surveys: [Survey] { availableSurveys + completedSurveys }

    func load() async {
        await surveyStore.loadIfNeeded()
    }

    func refresh() async {
        await surveyStore.refresh()
    }
}
