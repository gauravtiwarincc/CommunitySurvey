import Foundation

protocol AdminServiceProtocol: Sendable {
    func fetchDashboard() async throws -> AdminDashboard
    func fetchUsers(search: String, page: Int) async throws -> AdminUsersResponse
    func fetchUserDetail(id: String) async throws -> AdminUser
    func fetchSurveyAnalytics() async throws -> [SurveyAnalytics]
    func createSurvey(request: CreateSurveyRequest) async throws -> APIResponse
    func archiveSurvey(id: String) async throws -> APIResponse
}

@MainActor
struct AdminService: AdminServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchDashboard() async throws -> AdminDashboard {
        let response: AdminDashboardResponse = try await apiClient.request(
            path: "/admin/dashboard",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: true,
            responseType: AdminDashboardResponse.self
        )
        return response.dashboard
    }

    func fetchUsers(search: String, page: Int) async throws -> AdminUsersResponse {
        let encodedSearch = search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return try await apiClient.request(
            path: "/admin/users?search=\(encodedSearch)&page=\(page)",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: true,
            responseType: AdminUsersResponse.self
        )
    }

    func fetchUserDetail(id: String) async throws -> AdminUser {
        let response: AdminUserDetailResponse = try await apiClient.request(
            path: "/admin/users/\(id)",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: true,
            responseType: AdminUserDetailResponse.self
        )
        return response.user
    }

    func fetchSurveyAnalytics() async throws -> [SurveyAnalytics] {
        let response: AdminSurveyAnalyticsResponse = try await apiClient.request(
            path: "/admin/surveys/analytics",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: true,
            responseType: AdminSurveyAnalyticsResponse.self
        )
        return response.analytics
    }

    func createSurvey(request: CreateSurveyRequest) async throws -> APIResponse {
        try await apiClient.request(
            path: "/admin/surveys",
            method: .post,
            body: request,
            requiresAuthentication: true,
            responseType: APIResponse.self
        )
    }

    func archiveSurvey(id: String) async throws -> APIResponse {
        try await apiClient.request(
            path: "/admin/surveys/\(id)/archive",
            method: .post,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: true,
            responseType: APIResponse.self
        )
    }
}
