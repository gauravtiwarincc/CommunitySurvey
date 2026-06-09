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
    let organizationId: OrganizationConfig?
    let organizationType: String?
    let state: String?
    let district: String?
    let city: String?
    let fathersName: String?
    let gender: String?
    let address: String?
    let pincode: String?
    let education: String?
    let occupation: String?
    let socialCategory: String?
    let walletBalance: Int?
    let rewardPoints: Int?
    let isActive: Bool

    var organization: OrganizationConfig? { organizationId }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fullName
        case mobile
        case aadhaar
        case role
        case organizationId
        case organizationType
        case state
        case district
        case city
        case fathersName
        case gender
        case address
        case pincode
        case education
        case occupation
        case socialCategory
        case walletBalance
        case rewardPoints
        case isActive
    }

    init(
        id: String,
        fullName: String,
        mobile: String?,
        aadhaar: String?,
        role: UserRole = .user,
        organizationId: OrganizationConfig? = nil,
        organizationType: String? = nil,
        state: String? = nil,
        district: String? = nil,
        city: String? = nil,
        fathersName: String? = nil,
        gender: String? = nil,
        address: String? = nil,
        pincode: String? = nil,
        education: String? = nil,
        occupation: String? = nil,
        socialCategory: String? = nil,
        walletBalance: Int? = nil,
        rewardPoints: Int? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.fullName = fullName
        self.mobile = mobile
        self.aadhaar = aadhaar
        self.role = role
        self.organizationId = organizationId
        self.organizationType = organizationType
        self.state = state
        self.district = district
        self.city = city
        self.fathersName = fathersName
        self.gender = gender
        self.address = address
        self.pincode = pincode
        self.education = education
        self.occupation = occupation
        self.socialCategory = socialCategory
        self.walletBalance = walletBalance
        self.rewardPoints = rewardPoints
        self.isActive = isActive
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        fullName = try container.decodeIfPresent(String.self, forKey: .fullName) ?? ""
        mobile = try container.decodeIfPresent(String.self, forKey: .mobile)
        aadhaar = try container.decodeIfPresent(String.self, forKey: .aadhaar)
        role = try container.decodeIfPresent(UserRole.self, forKey: .role) ?? .user
        organizationId = try container.decodeIfPresent(OrganizationConfig.self, forKey: .organizationId)
        organizationType = try container.decodeIfPresent(String.self, forKey: .organizationType)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        district = try container.decodeIfPresent(String.self, forKey: .district)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        fathersName = try container.decodeIfPresent(String.self, forKey: .fathersName)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        pincode = try container.decodeIfPresent(String.self, forKey: .pincode)
        education = try container.decodeIfPresent(String.self, forKey: .education)
        occupation = try container.decodeIfPresent(String.self, forKey: .occupation)
        socialCategory = try container.decodeIfPresent(String.self, forKey: .socialCategory)
        walletBalance = try container.decodeIfPresent(Int.self, forKey: .walletBalance)
        rewardPoints = try container.decodeIfPresent(Int.self, forKey: .rewardPoints)
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
    }
}

struct RegisterUserRequest: Codable, Equatable, Sendable {
    let fullName: String
    let fathersName: String
    let gender: String
    let mobile: String
    let aadhaar: String
    let address: String
    let role: UserRole
    let organizationId: String?
    let organizationName: String?
    let organizationType: String?
    let organizationCode: String?
    let state: String
    let district: String
    let pincode: String
    let education: String
    let occupation: String
    let socialCategory: String
    let city: String
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

struct LocationItem: Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let name: String
}

extension LocationItem: Decodable {
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, name
    }
}

extension LocationItem: Encodable {
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
}

struct LocationResponse<T: Codable>: Sendable where T: Sendable {
    let success: Bool
    let data: [T]
}

extension LocationResponse: Decodable {
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        data = try container.decode([T].self, forKey: .data)
    }
    
    private enum CodingKeys: String, CodingKey {
        case success, data
    }
}

extension LocationResponse: Encodable {
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encode(data, forKey: .data)
    }
}
