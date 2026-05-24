import Foundation

struct AuthenticatedUser: Codable, Equatable, Hashable, Sendable {
    let id: String
    let mobileNumber: String
    let countryCode: String
}

struct AuthSession: Codable, Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    let user: AuthenticatedUser

    var isExpired: Bool {
        Date().addingTimeInterval(60) >= expiresAt
    }
}

struct OTPRequest: Codable, Equatable, Sendable {
    let mobileNumber: String
    let countryCode: String
}

struct OTPResponse: Codable, Equatable, Sendable {
    let transactionID: String
    let expiresIn: Int
    let otp: String?
}

struct OTPVerificationRequest: Codable, Equatable, Sendable {
    let transactionID: String
    let otp: String
}

struct TokenRefreshResponse: Codable, Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}

struct AadhaarVerificationRequest: Codable, Equatable, Sendable {
    let aadhaarNumber: String
}

struct AadhaarVerificationResult: Codable, Equatable, Hashable, Sendable {
    enum Status: String, Codable, Sendable {
        case verified
        case pending
        case failed
    }

    let referenceID: String
    let maskedAadhaar: String
    let status: Status
    let message: String
    let verifiedAt: Date?
}
