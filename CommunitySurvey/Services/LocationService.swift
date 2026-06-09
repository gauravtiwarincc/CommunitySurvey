import Foundation

protocol LocationServiceProtocol: Sendable {
    func fetchStates() async throws -> [LocationItem]
    func fetchDistricts(stateId: String) async throws -> [LocationItem]
    func fetchCities(districtId: String) async throws -> [LocationItem]
}

@MainActor
struct LocationService: LocationServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchStates() async throws -> [LocationItem] {
        let response: LocationResponse<LocationItem> = try await apiClient.request(
            path: "/location/states",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: false,
            responseType: LocationResponse<LocationItem>.self
        )
        return response.data
    }

    func fetchDistricts(stateId: String) async throws -> [LocationItem] {
        let encoded = stateId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? stateId
        let response: LocationResponse<LocationItem> = try await apiClient.request(
            path: "/location/districts?stateId=\(encoded)",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: false,
            responseType: LocationResponse<LocationItem>.self
        )
        return response.data
    }

    func fetchCities(districtId: String) async throws -> [LocationItem] {
        let encoded = districtId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? districtId
        let response: LocationResponse<LocationItem> = try await apiClient.request(
            path: "/location/cities?districtId=\(encoded)",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: false,
            responseType: LocationResponse<LocationItem>.self
        )
        return response.data
    }
}
