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
                id: "current-user",
                fullName: "Verified Citizen",
                mobileNumber: "",
                maskedAadhaar: "",
                state: "",
                district: "",
                isAadhaarVerified: true,
                walletBalance: Decimal(dashboard.stats.walletBalance),
                rewardPoints: dashboard.stats.rewardPoints
            ),
            availableSurveys: dashboard.availableSurveys,
            completedSurveys: dashboard.completedSurveys,
            transactions: []
        )
    }

    func submitSurvey(surveyID: String, answers: [SurveyAnswer]) async throws -> RewardTransaction {
        let submissionAnswers = answers.map { SurveySubmissionAnswer(questionId: $0.questionID, selectedOption: $0.optionID) }
        let response = try await submitSurvey(surveyID: surveyID, answers: submissionAnswers)
        return RewardTransaction(id: UUID().uuidString, title: response.message, kind: .survey, amount: Decimal(response.rewardEarned), date: Date())
    }

    func fetchRewards() async throws -> [RewardTransaction] { [] }
}

struct MockSurveyRepository: SurveyRepositoryProtocol {
    func fetchDashboardSurveys() async throws -> DashboardSurveyResponse {
        DashboardSurveyResponse(
            success: true,
            availableSurveys: Self.sampleSurveys.filter { !$0.isCompleted },
            completedSurveys: Self.sampleSurveys.filter(\.isCompleted),
            stats: DashboardStats(availableCount: 1, completedCount: 1, rewardPoints: 30, walletBalance: 30)
        )
    }

    func fetchSurveys() async throws -> [Survey] {
        try await fetchDashboardSurveys().allSurveys
    }

    func fetchSurveyDetail(id: String) async throws -> SurveyDetail {
        SurveyDetail(
            id: id,
            title: "2026 Election Opinion Survey",
            description: "Public opinion regarding upcoming elections",
            rewardPoints: 20,
            questions: [
                SurveyQuestion(id: "q1", question: "Who should become Prime Minister?", options: [SurveyOption(id: "o1", title: "Candidate A"), SurveyOption(id: "o2", title: "Candidate B")])
            ]
        )
    }

    func submitSurvey(surveyID: String, answers: [SurveySubmissionAnswer]) async throws -> SurveySubmitResponse {
        SurveySubmitResponse(success: true, message: "Survey submitted successfully", rewardEarned: 20)
    }

    func fetchDashboard() async throws -> DashboardSnapshot {
        let dashboard = try await fetchDashboardSurveys()
        return DashboardSnapshot(
            profile: VONUserProfile(id: "von-user-001", fullName: "Verified Citizen", mobileNumber: "9876543210", maskedAadhaar: "XXXX XXXX 0019", state: "Maharashtra", district: "Mumbai", isAadhaarVerified: true, walletBalance: Decimal(dashboard.stats.walletBalance), rewardPoints: dashboard.stats.rewardPoints),
            availableSurveys: dashboard.availableSurveys,
            completedSurveys: dashboard.completedSurveys,
            transactions: Self.sampleTransactions
        )
    }

    func submitSurvey(surveyID: String, answers: [SurveyAnswer]) async throws -> RewardTransaction {
        RewardTransaction(id: UUID().uuidString, title: "Survey reward credited", kind: .survey, amount: Decimal(25), date: Date())
    }

    func fetchRewards() async throws -> [RewardTransaction] {
        Self.sampleTransactions
    }

    static let sampleSurveys: [Survey] = [
        Survey(id: "survey-001", title: "2026 Election Opinion Survey", description: "Public opinion regarding upcoming elections", rewardPoints: 20, isCompleted: false),
        Survey(id: "survey-002", title: "Digital Payments Trust", description: "Tell us how citizens use UPI and cash.", rewardPoints: 10, isCompleted: true)
    ]

    static let sampleTransactions: [RewardTransaction] = [
        RewardTransaction(id: "txn-001", title: "2026 Election Opinion Survey", kind: .survey, amount: Decimal(20), date: Date().addingTimeInterval(-86_400)),
        RewardTransaction(id: "txn-002", title: "Referral bonus", kind: .referral, amount: Decimal(50), date: Date().addingTimeInterval(-172_800))
    ]
}
