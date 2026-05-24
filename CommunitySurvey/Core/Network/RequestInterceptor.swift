import Foundation

protocol RequestIntercepting: Sendable {
    func adapt(_ request: URLRequest, endpoint: Endpoint) async throws -> URLRequest
}

struct RequestInterceptor: RequestIntercepting {
    private let keychainService: KeychainService

    init(keychainService: KeychainService) {
        self.keychainService = keychainService
    }

    func adapt(_ request: URLRequest, endpoint: Endpoint) async throws -> URLRequest {
        var request = request
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("no-store", forHTTPHeaderField: "Cache-Control")
        request.setValue("iOS", forHTTPHeaderField: "X-Client-Platform")

        guard endpoint.requiresAuthentication else { return request }
        guard let token = keychainService.getToken(), !token.isEmpty else {
            throw APIError.unauthorized
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

typealias AuthRequestInterceptor = RequestInterceptor
