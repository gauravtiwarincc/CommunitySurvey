import Foundation

protocol ProfileServiceProtocol: Sendable {
    func getProfile() async throws -> User
    func updateProfile(fullName: String?) async throws -> User
}

@MainActor
struct ProfileService: ProfileServiceProtocol {
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func getProfile() async throws -> User {
        try await authService.getProfile()
    }

    func updateProfile(fullName: String?) async throws -> User {
        try await authService.updateProfile(fullName: fullName)
    }
}
