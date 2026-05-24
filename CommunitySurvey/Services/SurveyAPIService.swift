import Foundation

protocol SurveyServiceProtocol: Sendable {
    func getDashboardSurveys() async throws -> DashboardSurveyResponse
    func getSurveys() async throws -> [Survey]
    func getSurveyDetails(id: String) async throws -> SurveyDetail
    func submitSurvey(surveyId: String, answers: [SurveySubmissionAnswer]) async throws -> SurveySubmitResponse
}

@MainActor
struct SurveyAPIService: SurveyServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func getDashboardSurveys() async throws -> DashboardSurveyResponse {
        try await apiClient.request(
            path: "/surveys",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: true,
            responseType: DashboardSurveyResponse.self
        )
    }

    func getSurveys() async throws -> [Survey] {
        try await getDashboardSurveys().allSurveys
    }

    func getSurveyDetails(id: String) async throws -> SurveyDetail {
        let response: SurveyDetailResponse = try await apiClient.request(
            path: "/surveys/\(id)",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: true,
            responseType: SurveyDetailResponse.self
        )
        return response.survey
    }

    func submitSurvey(surveyId: String, answers: [SurveySubmissionAnswer]) async throws -> SurveySubmitResponse {
        try await apiClient.request(
            path: "/surveys/submit",
            method: .post,
            body: SubmitSurveyRequest(surveyId: surveyId, answers: answers),
            requiresAuthentication: true,
            responseType: SurveySubmitResponse.self
        )
    }
}
