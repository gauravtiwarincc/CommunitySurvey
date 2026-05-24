import Foundation
import Observation

@MainActor
@Observable
final class DashboardViewModel {
    private let surveyStore: SurveyStateStore

    init(surveyStore: SurveyStateStore) {
        self.surveyStore = surveyStore
    }

    var stats: DashboardStats { surveyStore.stats }
    var availableSurveys: [Survey] { surveyStore.availableSurveys }
    var completedSurveys: [Survey] { surveyStore.completedSurveys }
    var isLoading: Bool { surveyStore.isLoading }
    var errorMessage: String? { surveyStore.errorMessage }
    var isEmpty: Bool { surveyStore.isEmpty }

    func load() async {
        await surveyStore.loadIfNeeded()
    }

    func refresh() async {
        await surveyStore.refresh()
    }
}
