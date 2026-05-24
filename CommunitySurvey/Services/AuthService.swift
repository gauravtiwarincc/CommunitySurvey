import Foundation

protocol AuthServiceProtocol: Sendable {
    func register(fullName: String, mobile: String, aadhaar: String) async throws -> User
    func login(mobile: String) async throws -> User
    func getProfile() async throws -> User
    func updateProfile(fullName: String?) async throws -> User
    func logout() async
    func isAuthenticated() -> Bool

    func requestOTP(mobileNumber: String, countryCode: String) async throws -> OTPResponse
    func verifyOTP(transactionID: String, otp: String, mobileNumber: String, countryCode: String) async throws -> AuthSession
    func refresh(session: AuthSession) async throws -> AuthSession
}

@MainActor
struct AuthService: AuthServiceProtocol {
    private let apiClient: APIClientProtocol
    private let keychainService: KeychainService

    init(apiClient: APIClientProtocol, keychainService: KeychainService) {
        self.apiClient = apiClient
        self.keychainService = keychainService
    }

    func register(fullName: String, mobile: String, aadhaar: String) async throws -> User {
        let response: RegisterUserResponse = try await apiClient.request(
            path: "/auth/register",
            method: .post,
            body: RegisterUserRequest(fullName: fullName, mobile: mobile, aadhaar: aadhaar),
            requiresAuthentication: false,
            responseType: RegisterUserResponse.self
        )
        return response.user
    }

    func login(mobile: String) async throws -> User {
        let response: LoginUserResponse = try await apiClient.request(
            path: "/auth/login",
            method: .post,
            body: LoginUserRequest(mobile: mobile),
            requiresAuthentication: false,
            responseType: LoginUserResponse.self
        )
        try keychainService.save(token: response.token)
        return response.user
    }

    func getProfile() async throws -> User {
        let response: ProfileResponse = try await apiClient.request(
            path: "/auth/profile",
            method: .get,
            body: Optional<EmptyRequest>.none,
            requiresAuthentication: true,
            responseType: ProfileResponse.self
        )
        return response.user
    }

    func updateProfile(fullName: String?) async throws -> User {
        let response: ProfileResponse = try await apiClient.request(
            path: "/auth/profile",
            method: .put,
            body: UpdateProfileRequest(fullName: fullName),
            requiresAuthentication: true,
            responseType: ProfileResponse.self
        )
        return response.user
    }

    func logout() async {
        try? keychainService.deleteToken()
    }

    func isAuthenticated() -> Bool {
        keychainService.getToken() != nil
    }

    func requestOTP(mobileNumber: String, countryCode: String) async throws -> OTPResponse {
        let response: OTPLoginResponse = try await apiClient.request(
            path: "/auth/send-otp",
            method: .post,
            body: LoginUserRequest(mobile: mobileNumber),
            requiresAuthentication: false,
            responseType: OTPLoginResponse.self
        )
        return OTPResponse(
            transactionID: UUID().uuidString,
            expiresIn: 60,
            otp: response.otp
        )
    }

    func verifyOTP(transactionID: String, otp: String, mobileNumber: String, countryCode: String) async throws -> AuthSession {
        let response: VerifyOTPResponse = try await apiClient.request(
            path: "/auth/verify-otp",
            method: .post,
            body: VerifyOTPRequest(mobile: mobileNumber, otp: otp),
            requiresAuthentication: false,
            responseType: VerifyOTPResponse.self
        )
        try keychainService.save(token: response.token)
        return AuthSession(
            accessToken: response.token,
            refreshToken: "",
            expiresAt: Date().addingTimeInterval(3600),
            user: AuthenticatedUser(id: response.user.id, mobileNumber: response.user.mobile ?? mobileNumber, countryCode: countryCode)
        )
    }

    func refresh(session: AuthSession) async throws -> AuthSession { session }
}

struct EmptyRequest: Encodable, Sendable { }

struct MockAuthService: AuthServiceProtocol {
    func register(fullName: String, mobile: String, aadhaar: String) async throws -> User {
        User(id: UUID().uuidString, fullName: fullName, mobile: mobile, aadhaar: aadhaar)
    }

    func login(mobile: String) async throws -> User {
        User(id: UUID().uuidString, fullName: "Verified Citizen", mobile: mobile, aadhaar: "XXXX XXXX 0019")
    }

    func getProfile() async throws -> User {
        User(id: "mock-user", fullName: "Verified Citizen", mobile: "9876543210", aadhaar: "XXXX XXXX 0019")
    }

    func updateProfile(fullName: String?) async throws -> User {
        User(id: "mock-user", fullName: fullName ?? "Verified Citizen", mobile: "9876543210", aadhaar: "XXXX XXXX 0019")
    }

    func logout() async { }
    func isAuthenticated() -> Bool { false }

    func requestOTP(mobileNumber: String, countryCode: String) async throws -> OTPResponse {
        OTPResponse(transactionID: UUID().uuidString, expiresIn: 60, otp: "123456")
    }

    func verifyOTP(transactionID: String, otp: String, mobileNumber: String, countryCode: String) async throws -> AuthSession {
        guard otp == "123456" else { throw APIError.unauthorized }
        return AuthSession(accessToken: "mock", refreshToken: "mock", expiresAt: Date().addingTimeInterval(3600), user: AuthenticatedUser(id: "mock-user", mobileNumber: mobileNumber, countryCode: countryCode))
    }

    func refresh(session: AuthSession) async throws -> AuthSession { session }
}
