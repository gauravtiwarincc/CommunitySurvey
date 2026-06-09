import Foundation

protocol AuthServiceProtocol: Sendable {
    func register(
        fullName: String,
        fathersName: String,
        gender: String,
        mobile: String,
        aadhaar: String,
        address: String,
        role: UserRole,
        organizationId: String?,
        organizationName: String?,
        organizationType: String?,
        organizationCode: String?,
        state: String,
        district: String,
        pincode: String,
        education: String,
        occupation: String,
        socialCategory: String,
        city: String
    ) async throws -> AuthSession
    func login(mobile: String) async throws -> User
    func getProfile() async throws -> User
    func updateProfile(fullName: String?) async throws -> User
    func logout() async
    func isAuthenticated() -> Bool
    func joinOrganization(code: String) async throws -> User

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

    func register(
        fullName: String,
        fathersName: String,
        gender: String,
        mobile: String,
        aadhaar: String,
        address: String,
        role: UserRole,
        organizationId: String?,
        organizationName: String?,
        organizationType: String?,
        organizationCode: String?,
        state: String,
        district: String,
        pincode: String,
        education: String,
        occupation: String,
        socialCategory: String,
        city: String
    ) async throws -> AuthSession {
        let response: RegisterUserResponse = try await apiClient.request(
            path: "/auth/register",
            method: .post,
            body: RegisterUserRequest(
                fullName: fullName,
                fathersName: fathersName,
                gender: gender,
                mobile: mobile,
                aadhaar: aadhaar,
                address: address,
                role: role,
                organizationId: organizationId,
                organizationName: organizationName,
                organizationType: organizationType,
                organizationCode: organizationCode,
                state: state,
                district: district,
                pincode: pincode,
                education: education,
                occupation: occupation,
                socialCategory: socialCategory,
                city: city
            ),
            requiresAuthentication: false,
            responseType: RegisterUserResponse.self
        )
        try keychainService.save(token: response.token)
        return makeSession(token: response.token, user: response.user, mobileNumber: mobile, countryCode: "+91")
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

    func joinOrganization(code: String) async throws -> User {
        struct JoinOrgRequest: Encodable {
            let organizationCode: String
        }
        struct JoinOrgResponse: Decodable {
            let success: Bool
            let user: User
        }
        let response = try await apiClient.request(
            path: "/auth/join-org",
            method: .post,
            body: JoinOrgRequest(organizationCode: code),
            requiresAuthentication: true,
            responseType: JoinOrgResponse.self
        )
        return response.user
    }

    func requestOTP(mobileNumber: String, countryCode: String) async throws -> OTPResponse {
        let response: OTPLoginResponse = try await apiClient.request(
            path: "/auth/send-otp",
            method: .post,
            body: LoginUserRequest(mobile: mobileNumber),
            requiresAuthentication: false,
            responseType: OTPLoginResponse.self
        )
        return OTPResponse(transactionID: UUID().uuidString, expiresIn: 60, otp: response.otp)
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
        return makeSession(token: response.token, user: response.user, mobileNumber: mobileNumber, countryCode: countryCode)
    }

    func refresh(session: AuthSession) async throws -> AuthSession { session }

    private func makeSession(token: String, user: User, mobileNumber: String, countryCode: String) -> AuthSession {
        AuthSession(
            accessToken: token,
            refreshToken: "",
            expiresAt: Date().addingTimeInterval(3600),
            user: AuthenticatedUser(
                id: user.id,
                mobileNumber: user.mobile ?? mobileNumber,
                countryCode: countryCode,
                role: user.role,
                organization: user.organizationId
            )
        )
    }
}

struct EmptyRequest: Encodable, Sendable { }
