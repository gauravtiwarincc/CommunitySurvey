import Foundation
import Testing
@testable import CommunitySurvey

@MainActor
@Suite("CommunitySurvey Core")
struct CommunitySurveyTests {
    @Test func mobileValidationAcceptsIndianNumbers() throws {
        let validator = ValidationManager()
        let value = try validator.validateMobile("98765 43210").get()
        #expect(value == "9876543210")
    }

    @Test func otpValidationRequiresSixDigits() throws {
        let validator = ValidationManager()
        let value = try validator.validateOTP("123456").get()
        #expect(value == "123456")
        if case .failure = validator.validateOTP("123") {
            #expect(true)
        } else {
            #expect(Bool(false), "Short OTP should fail validation")
        }
    }

    @Test func mockAuthServiceCreatesSessionForExpectedOTP() async throws {
        let service = MockAuthService()
        let response = try await service.requestOTP(mobileNumber: "9876543210", countryCode: "+91")
        let session = try await service.verifyOTP(transactionID: response.transactionID, otp: "123456", mobileNumber: "9876543210", countryCode: "+91")
        #expect(session.user.mobileNumber == "9876543210")
        #expect(session.isExpired == false)
    }

    @Test func tokenStorePersistsAndClearsSession() {
        let keychain = InMemoryKeychain()
        let store = TokenStore(keychain: keychain)
        let session = AuthSession(
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(300),
            user: AuthenticatedUser(id: "1", mobileNumber: "9876543210", countryCode: "+91", role: .user, organization: nil)
        )

        store.save(session: session)
        #expect(store.loadSession()?.accessToken == "access")
        store.clear()
        #expect(store.loadSession() == nil)
    }

    @Test func mockAadhaarVerificationReturnsMaskedResult() async throws {
        let service = MockAadhaarService()
        let result = try await service.verify(aadhaarNumber: "999999990019")
        #expect(result.status == .verified)
        #expect(result.maskedAadhaar == "XXXX XXXX 0019")
    }

    @Test func userDecodingDefaultIsActiveToTrue() throws {
        let jsonStr = """
        {
            "_id": "user123",
            "fullName": "John Doe",
            "mobile": "9876543210",
            "aadhaar": "XXXX XXXX 1234",
            "role": "user"
        }
        """
        let data = jsonStr.data(using: .utf8)!
        let user = try JSONDecoder().decode(UserProfileInfo.self, from: data)
        #expect(user.id == "user123")
        #expect(user.isActive == true)
    }

    @Test func userDecodingParsesIsActiveFalse() throws {
        let jsonStr = """
        {
            "_id": "user123",
            "fullName": "John Doe",
            "mobile": "9876543210",
            "aadhaar": "XXXX XXXX 1234",
            "role": "user",
            "isActive": false
        }
        """
        let data = jsonStr.data(using: .utf8)!
        let user = try JSONDecoder().decode(UserProfileInfo.self, from: data)
        #expect(user.isActive == false)
    }

    @Test func apiUserDecodingDefaultIsActiveToTrue() throws {
        let jsonStr = """
        {
            "_id": "user123",
            "fullName": "John Doe",
            "mobile": "9876543210",
            "aadhaar": "XXXX XXXX 1234",
            "role": "user"
        }
        """
        let data = jsonStr.data(using: .utf8)!
        let user = try JSONDecoder().decode(User.self, from: data)
        #expect(user.id == "user123")
        #expect(user.isActive == true)
    }
}

final class InMemoryKeychain: KeychainManaging, @unchecked Sendable {
    private var storage: [String: Data] = [:]

    func save(_ data: Data, for key: String) throws {
        storage[key] = data
    }

    func load(key: String) throws -> Data? {
        storage[key]
    }

    func delete(key: String) throws {
        storage.removeValue(forKey: key)
    }
}

struct MockAuthService: AuthServiceProtocol {
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
        AuthSession(
            accessToken: "mock",
            refreshToken: "mock",
            expiresAt: Date().addingTimeInterval(3600),
            user: AuthenticatedUser(id: "mock-user", mobileNumber: mobile, countryCode: "+91", role: role, organization: nil)
        )
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
    
    func joinOrganization(code: String) async throws -> User {
        User(id: "mock-user", fullName: "Verified Citizen", mobile: "9876543210", aadhaar: "XXXX XXXX 0019")
    }

    func requestOTP(mobileNumber: String, countryCode: String) async throws -> OTPResponse {
        OTPResponse(transactionID: UUID().uuidString, expiresIn: 60, otp: "123456")
    }

    func verifyOTP(transactionID: String, otp: String, mobileNumber: String, countryCode: String) async throws -> AuthSession {
        guard otp == "123456" else { throw APIError.unauthorized }
        return AuthSession(
            accessToken: "mock",
            refreshToken: "mock",
            expiresAt: Date().addingTimeInterval(3600),
            user: AuthenticatedUser(id: "mock-user", mobileNumber: mobileNumber, countryCode: countryCode, role: .user, organization: nil)
        )
    }

    func refresh(session: AuthSession) async throws -> AuthSession { session }
}

