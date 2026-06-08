import Foundation

struct OrganizationSummary: Codable, Equatable, Hashable, Sendable, Identifiable {
    let id: String
    let organizationName: String
    let organizationType: String?
    let primaryColor: String
    let secondaryColor: String
    let accentColor: String
    let logoUrl: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case organizationName
        case organizationType
        case primaryColor
        case secondaryColor
        case accentColor
        case logoUrl
    }
}

struct User: Codable, Equatable, Hashable, Sendable, Identifiable {
    let id: String
    var fullName: String
    let mobile: String?
    let aadhaar: String?
    let role: UserRole
    let organization: OrganizationSummary?
    let organizationType: String?
    let state: String?
    let district: String?
    let city: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fullName
        case mobile
        case aadhaar
        case role
        case organization = "organizationId"
        case organizationType
        case state
        case district
        case city
    }

    init(id: String, fullName: String, mobile: String?, aadhaar: String?, role: UserRole = .user, organization: OrganizationSummary? = nil, organizationType: String? = nil, state: String? = nil, district: String? = nil, city: String? = nil) {
        self.id = id
        self.fullName = fullName
        self.mobile = mobile
        self.aadhaar = aadhaar
        self.role = role
        self.organization = organization
        self.organizationType = organizationType
        self.state = state
        self.district = district
        self.city = city
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        fullName = try container.decodeIfPresent(String.self, forKey: .fullName) ?? ""
        mobile = try container.decodeIfPresent(String.self, forKey: .mobile)
        aadhaar = try container.decodeIfPresent(String.self, forKey: .aadhaar)
        role = try container.decodeIfPresent(UserRole.self, forKey: .role) ?? .user
        organization = try container.decodeIfPresent(OrganizationSummary.self, forKey: .organization)
        organizationType = try container.decodeIfPresent(String.self, forKey: .organizationType)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        district = try container.decodeIfPresent(String.self, forKey: .district)
        city = try container.decodeIfPresent(String.self, forKey: .city)
    }
}

struct RegisterUserRequest: Codable, Equatable, Sendable {
    let fullName: String
    let mobile: String
    let aadhaar: String
    let role: UserRole
    let organizationId: String?
    let organizationType: String?
    let state: String?
    let district: String?
    let city: String?
}

struct RegisterUserResponse: Codable, Equatable, Sendable {
    let success: Bool
    let token: String
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

struct OrganizationTypesResponse: Codable, Equatable, Sendable {
    let success: Bool
    let types: [String]
}

struct OrganizationsResponse: Codable, Equatable, Sendable {
    let success: Bool
    let organizations: [OrganizationSummary]
}

struct LocationListResponse: Codable, Equatable, Sendable {
    let success: Bool
    let states: [String]?
    let districts: [String]?
    let cities: [String]?

    var values: [String] { states ?? districts ?? cities ?? [] }
}
