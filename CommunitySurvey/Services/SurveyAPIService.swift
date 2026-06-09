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
            path: "/dashboard",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: true,
            responseType: DashboardSurveyResponse.self
        )
    }

    func getSurveys() async throws -> [Survey] {
        let response: DashboardSurveyResponse = try await apiClient.request(
            path: "/surveys",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: true,
            responseType: DashboardSurveyResponse.self
        )
        return response.allSurveys
    }

    func getSurveyDetails(id: String) async throws -> SurveyDetail {
        guard let survey = try await getSurveys().first(where: { $0.id == id }) else {
            throw APIError.serverError("Survey is not available or has already been completed.")
        }
        return SurveyDetail(survey: survey)
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
