import Foundation

protocol SurveyRepositoryProtocol: Sendable {
    func fetchDashboardSurveys() async throws -> DashboardSurveyResponse
    func fetchSurveys() async throws -> [Survey]
    func fetchSurveyDetail(id: String) async throws -> SurveyDetail
    func submitSurvey(surveyID: String, answers: [SurveySubmissionAnswer]) async throws -> SurveySubmitResponse

    func fetchDashboard() async throws -> DashboardSnapshot
    func submitSurvey(surveyID: String, answers: [SurveyAnswer]) async throws -> RewardTransaction
    func fetchRewards() async throws -> [RewardTransaction]
}

struct DashboardSnapshot: Equatable, Sendable {
    let profile: VONUserProfile
    let availableSurveys: [Survey]
    let completedSurveys: [Survey]
    let transactions: [RewardTransaction]
}

@MainActor
struct SurveyRepository: SurveyRepositoryProtocol {
    private let surveyService: SurveyServiceProtocol

    init(surveyService: SurveyServiceProtocol) {
        self.surveyService = surveyService
    }

    func fetchDashboardSurveys() async throws -> DashboardSurveyResponse {
        try await surveyService.getDashboardSurveys()
    }

    func fetchSurveys() async throws -> [Survey] {
        try await surveyService.getSurveys()
    }

    func fetchSurveyDetail(id: String) async throws -> SurveyDetail {
        try await surveyService.getSurveyDetails(id: id)
    }

    func submitSurvey(surveyID: String, answers: [SurveySubmissionAnswer]) async throws -> SurveySubmitResponse {
        try await surveyService.submitSurvey(surveyId: surveyID, answers: answers)
    }

    func fetchDashboard() async throws -> DashboardSnapshot {
        let dashboard = try await fetchDashboardSurveys()
        return DashboardSnapshot(
            profile: VONUserProfile(
                id: "",
                fullName: "",
                mobileNumber: "",
                maskedAadhaar: "",
                state: "",
                district: "",
                isAadhaarVerified: true,
                walletBalance: Decimal(dashboard.stats?.walletBalance ?? 0),
                rewardPoints: dashboard.stats?.rewardPoints ?? 0
            ),
            availableSurveys: dashboard.availableSurveys,
            completedSurveys: dashboard.completedSurveys,
            transactions: []
        )
    }

    func submitSurvey(surveyID: String, answers: [SurveyAnswer]) async throws -> RewardTransaction {
        let submissionAnswers = answers.map { SurveySubmissionAnswer(questionId: $0.questionID, selectedOption: $0.optionID) }
        let response = try await submitSurvey(surveyID: surveyID, answers: submissionAnswers)
        return RewardTransaction(id: surveyID, title: response.message ?? "Survey submitted", kind: .survey, amount: Decimal(response.rewardEarned), date: Date())
    }

    func fetchRewards() async throws -> [RewardTransaction] { [] }
}
