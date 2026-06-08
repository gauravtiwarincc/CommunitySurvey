import Foundation

protocol OrganizationServiceProtocol: Sendable {
    func fetchOrganizationTypes() async throws -> [String]
    func fetchOrganizations(type: String) async throws -> [OrganizationSummary]
}

@MainActor
struct OrganizationService: OrganizationServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchOrganizationTypes() async throws -> [String] {
        let response: OrganizationTypesResponse = try await apiClient.request(
            path: "/organizations/types",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: false,
            responseType: OrganizationTypesResponse.self
        )
        return response.types
    }

    func fetchOrganizations(type: String) async throws -> [OrganizationSummary] {
        let encodedType = type.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? type
        let response: OrganizationsResponse = try await apiClient.request(
            path: "/organizations?type=\(encodedType)",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: false,
            responseType: OrganizationsResponse.self
        )
        return response.organizations
    }
}
