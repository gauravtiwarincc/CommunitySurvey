import Foundation
import Observation

@MainActor
@Observable
final class SurveyViewModel {
    let survey: Survey
    var selectedOptionID: String?
    var currentIndex = 0
    var answers: [SurveyAnswer] = []
    var secondsRemaining = 60
    var isSubmitting = false
    var completion: RewardTransaction?
    var errorMessage: String?

    private let repository: SurveyRepositoryProtocol
    private let router: AppRouter
    private var timerTask: Task<Void, Never>?

    init(survey: Survey, repository: SurveyRepositoryProtocol, router: AppRouter) {
        self.survey = survey
        self.repository = repository
        self.router = router
        startTimer()
    }

    var questions: [SurveyQuestion] { survey.questions ?? [] }
    var question: SurveyQuestion { questions[currentIndex] }
    var progress: Double { Double(currentIndex + 1) / Double(max(questions.count, 1)) }
    var isLastQuestion: Bool { currentIndex == questions.count - 1 }

    func select(_ option: SurveyOption) {
        selectedOptionID = option.id
    }

    func skip() {
        selectedOptionID = nil
        moveNext()
    }

    func next() async {
        guard let selectedOptionID else { return }
        answers.append(SurveyAnswer(questionID: question.id, optionID: selectedOptionID))
        self.selectedOptionID = nil
        if isLastQuestion {
            await submit()
        } else {
            moveNext()
        }
    }

    private func moveNext() {
        if !isLastQuestion {
            currentIndex += 1
            secondsRemaining = 60
        }
    }

    private func submit() async {
        isSubmitting = true
        do {
            completion = try await repository.submitSurvey(surveyID: survey.id, answers: answers)
            router.navigate(to: .wallet)
        } catch {
            errorMessage = (error as? AppError ?? .unknown(error.localizedDescription)).localizedDescription
        }
        isSubmitting = false
    }

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self else { break }
                if self.secondsRemaining > 0 { self.secondsRemaining -= 1 }
            }
        }
    }
}
