import Foundation
import Observation

@MainActor
@Observable
final class SurveyDetailViewModel {
    enum CompletionState: Equatable {
        case editing
        case submitting
        case completed(String)
    }

    let surveyID: String
    var survey: SurveyDetail?
    var selectedAnswers: [String: String] = [:]
    var isLoading = false
    var errorMessage: String?
    var completionState: CompletionState = .editing

    private let repository: SurveyRepositoryProtocol
    private let surveyStore: SurveyStateStore

    init(surveyID: String, repository: SurveyRepositoryProtocol, surveyStore: SurveyStateStore) {
        self.surveyID = surveyID
        self.repository = repository
        self.surveyStore = surveyStore
    }

    var canSubmit: Bool {
        guard let survey, !survey.questions.isEmpty else { return false }
        return survey.questions.allSatisfy { selectedAnswers[$0.id] != nil } && completionState == .editing
    }

    var answeredCount: Int { selectedAnswers.count }
    var totalQuestions: Int { survey?.questions.count ?? 0 }
    var isAlreadyCompleted: Bool { surveyStore.completedSurveys.contains { $0.id == surveyID } }

    func load() async {
        await surveyStore.loadIfNeeded()
        guard !isAlreadyCompleted else {
            completionState = .completed("This survey has already been completed.")
            return
        }
        guard survey == nil else { return }
        isLoading = true
        errorMessage = nil
        do {
            survey = try await repository.fetchSurveyDetail(id: surveyID)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func select(option: SurveyOption, for question: SurveyQuestion) {
        guard completionState == .editing, !isAlreadyCompleted else { return }
        selectedAnswers[question.id] = option.title
    }

    func submit() async {
        guard !isAlreadyCompleted else {
            errorMessage = "This survey has already been completed."
            completionState = .completed("This survey has already been completed.")
            return
        }
        guard canSubmit else {
            errorMessage = "Please answer all questions before submitting."
            return
        }
        completionState = .submitting
        errorMessage = nil
        do {
            let answers = selectedAnswers.map { SurveySubmissionAnswer(questionId: $0.key, selectedOption: $0.value) }
            let response = try await repository.submitSurvey(surveyID: surveyID, answers: answers)
            surveyStore.markCompleted(surveyID: surveyID, rewardEarned: response.rewardEarned)
            await surveyStore.refresh()
            completionState = .completed(response.message)
        } catch {
            completionState = .editing
            errorMessage = error.localizedDescription
        }
    }
}
