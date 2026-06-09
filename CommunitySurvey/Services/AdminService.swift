import Foundation

protocol AdminServiceProtocol: Sendable {
    func fetchDashboard() async throws -> AdminDashboardResponse
    func fetchUsers(search: String, page: Int) async throws -> AdminUsersResponse
    func fetchUserDetail(id: String) async throws -> AdminUserDetailResponse
    func fetchSurveyAnalytics() async throws -> [SurveyAnalytics]
    func createSurvey(request: CreateSurveyRequest) async throws -> APIResponse
    func archiveSurvey(id: String) async throws -> APIResponse
    func updateTheme(request: UpdateThemeRequest) async throws -> UpdateThemeResponse
    func updateUserStatus(id: String, isActive: Bool) async throws -> UpdateUserStatusResponse
}

@MainActor
struct AdminService: AdminServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchDashboard() async throws -> AdminDashboardResponse {
        return try await apiClient.request(
            path: "/admin/dashboard",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: true,
            responseType: AdminDashboardResponse.self
        )
    }

    func fetchUsers(search: String, page: Int) async throws -> AdminUsersResponse {
        let encodedSearch = search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return try await apiClient.request(
            path: "/admin/users?search=\(encodedSearch)&page=\(page)&limit=15",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: true,
            responseType: AdminUsersResponse.self
        )
    }

    func fetchUserDetail(id: String) async throws -> AdminUserDetailResponse {
        return try await apiClient.request(
            path: "/admin/users/\(id)",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: true,
            responseType: AdminUserDetailResponse.self
        )
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

    func updateTheme(request: UpdateThemeRequest) async throws -> UpdateThemeResponse {
        try await apiClient.request(
            path: "/organizations/theme",
            method: .put,
            body: request,
            requiresAuthentication: true,
            responseType: UpdateThemeResponse.self
        )
    }

    func updateUserStatus(id: String, isActive: Bool) async throws -> UpdateUserStatusResponse {
        try await apiClient.request(
            path: "/admin/users/\(id)/status",
            method: .patch,
            body: UpdateUserStatusRequest(isActive: isActive),
            requiresAuthentication: true,
            responseType: UpdateUserStatusResponse.self
        )
    }
}
