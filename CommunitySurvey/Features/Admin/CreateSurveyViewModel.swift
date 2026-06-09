import Foundation
import Observation

@MainActor
@Observable
final class CreateSurveyViewModel {
    var title = ""
    var description = ""
    var rewardPoints = ""
    var questions: [CreateSurveyQuestion] = [CreateSurveyQuestion(id: UUID(), question: "", options: [CreateSurveyOption(id: UUID(), title: ""), CreateSurveyOption(id: UUID(), title: "")])]
    var isLoading = false
    var errorMessage: String?
    var successMessage: String?

    private let adminService: AdminServiceProtocol

    init(adminService: AdminServiceProtocol) {
        self.adminService = adminService
    }

    var canSubmit: Bool {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              Int(rewardPoints) != nil else { return false }
        return questions.allSatisfy { question in
            !question.question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && question.options.filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count >= 2
        }
    }

    func addQuestion() {
        questions.append(CreateSurveyQuestion(id: UUID(), question: "", options: [CreateSurveyOption(id: UUID(), title: ""), CreateSurveyOption(id: UUID(), title: "")]))
    }

    func removeQuestion(id: UUID) {
        guard questions.count > 1 else { return }
        questions.removeAll { $0.id == id }
    }

    func addOption(to questionID: UUID) {
        guard let index = questions.firstIndex(where: { $0.id == questionID }) else { return }
        questions[index].options.append(CreateSurveyOption(id: UUID(), title: ""))
    }

    func removeOption(_ optionID: UUID, from questionID: UUID) {
        guard let index = questions.firstIndex(where: { $0.id == questionID }), questions[index].options.count > 2 else { return }
        questions[index].options.removeAll { $0.id == optionID }
    }

    func submit() async {
        guard canSubmit, let points = Int(rewardPoints) else {
            errorMessage = "Complete the survey title, reward points, questions, and at least two options per question."
            return
        }
        isLoading = true
        errorMessage = nil
        successMessage = nil
        do {
            let requestQuestions = questions.map { question in
                CreateQuestionItem(
                    question: question.question.trimmingCharacters(in: .whitespacesAndNewlines),
                    options: question.options
                        .filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                        .map { CreateOptionItem(title: $0.title.trimmingCharacters(in: .whitespacesAndNewlines)) }
                )
            }
            let request = CreateSurveyRequest(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                rewardPoints: points,
                questions: requestQuestions
            )
            let response = try await adminService.createSurvey(request: request)
            successMessage = response.message
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
