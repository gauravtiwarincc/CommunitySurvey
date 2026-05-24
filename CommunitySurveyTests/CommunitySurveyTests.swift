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
            user: AuthenticatedUser(id: "1", mobileNumber: "9876543210", countryCode: "+91")
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
