import Foundation

struct User: Codable, Equatable, Hashable, Sendable, Identifiable {
    let id: String
    var fullName: String
    let mobile: String?
    let aadhaar: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fullName
        case mobile
        case aadhaar
    }
}

struct RegisterUserRequest: Codable, Equatable, Sendable {
    let fullName: String
    let mobile: String
    let aadhaar: String
}

struct RegisterUserResponse: Codable, Equatable, Sendable {
    let success: Bool
    let user: User
}

struct LoginUserRequest: Codable, Equatable, Sendable {
    let mobile: String
}

struct LoginUserResponse: Codable, Equatable, Sendable {
    let success: Bool
    let token: String
    let user: User
}

struct OTPLoginResponse: Codable, Equatable, Sendable {
    let success: Bool
    let message: String?
    let otp: String?
}

struct VerifyOTPRequest: Codable, Equatable, Sendable {
    let mobile: String
    let otp: String
}

struct VerifyOTPResponse: Codable, Equatable, Sendable {
    let success: Bool
    let message: String?
    let token: String
    let user: User
}

struct ProfileResponse: Codable, Equatable, Sendable {
    let success: Bool
    let user: User
}

struct UpdateProfileRequest: Codable, Equatable, Sendable {
    let fullName: String?
}

struct WalletResponse: Codable, Equatable, Sendable {
    let success: Bool
    let walletBalance: Int
    let transactions: [Transaction]
}

struct Transaction: Codable, Equatable, Hashable, Identifiable, Sendable {
    let id: String
    let amount: Int
    let type: String
    let description: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case amount
        case type
        case description
        case createdAt
    }
}
