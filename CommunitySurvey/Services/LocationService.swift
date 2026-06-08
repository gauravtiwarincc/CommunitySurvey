import Foundation

protocol LocationServiceProtocol: Sendable {
    func fetchStates() async throws -> [String]
    func fetchDistricts(state: String) async throws -> [String]
    func fetchCities(district: String) async throws -> [String]
}

@MainActor
struct LocationService: LocationServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchStates() async throws -> [String] {
        let response: LocationListResponse = try await apiClient.request(
            path: "/location/states",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: false,
            responseType: LocationListResponse.self
        )
        return response.values
    }

    func fetchDistricts(state: String) async throws -> [String] {
        let encoded = state.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? state
        let response: LocationListResponse = try await apiClient.request(
            path: "/location/districts?state=\(encoded)",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: false,
            responseType: LocationListResponse.self
        )
        return response.values
    }

    func fetchCities(district: String) async throws -> [String] {
        let encoded = district.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? district
        let response: LocationListResponse = try await apiClient.request(
            path: "/location/cities?district=\(encoded)",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: false,
            responseType: LocationListResponse.self
        )
        return response.values
    }
}
