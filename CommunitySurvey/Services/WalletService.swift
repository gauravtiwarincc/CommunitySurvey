import Foundation

protocol WalletServiceProtocol: Sendable {
    func getWallet() async throws -> WalletResponse
}

@MainActor
struct WalletService: WalletServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func getWallet() async throws -> WalletResponse {
        try await apiClient.request(path: "/wallet", method: .get, body: Optional<EmptyRequest>.none, requiresAuthentication: true, responseType: WalletResponse.self)
    }
}
