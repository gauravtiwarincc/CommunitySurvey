import Foundation

enum UserRole: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case user
    case admin
    case superAdmin = "super_admin"
}

struct AdminUser: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let fullName: String
    let mobile: String
    let registrationDate: Date?
    let statistics: UserStatistics
    let surveyProgress: SurveyProgress?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fullName
        case mobile
        case registrationDate
        case statistics
        case surveyProgress
    }
}

struct UserStatistics: Codable, Equatable, Sendable {
    let completedSurveys: Int
    let pendingSurveys: Int
    let rewardPoints: Int
    let walletBalance: Int
}

struct SurveyProgress: Codable, Equatable, Sendable {
    let completedSurveys: [Survey]
    let pendingSurveys: [Survey]
}

struct AdminDashboard: Codable, Equatable, Sendable {
    let totalUsers: Int
    let totalSurveys: Int
    let completedSurveys: Int
    let pendingSurveys: Int
    let totalRewardPointsDistributed: Int
    let completionPercentage: Double
}

struct SurveyAnalytics: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let title: String
    let completionCount: Int
    let pendingCount: Int
    let rewardPointsDistributed: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case completionCount
        case pendingCount
        case rewardPointsDistributed
    }
}

struct AdminUsersResponse: Codable, Equatable, Sendable {
    let success: Bool
    let users: [AdminUserItem]
    let pagination: PaginationInfo
}

struct AdminUserItem: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let fullName: String
    let mobile: String
    let aadhaar: String
    let role: String
    let walletBalance: Int
    let rewardPoints: Int
    let completedSurveysCount: Int
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fullName, mobile, aadhaar, role, walletBalance, rewardPoints, completedSurveysCount, createdAt
    }
}

struct PaginationInfo: Codable, Equatable, Sendable {
    let totalUsers: Int
    let totalPages: Int
    let currentPage: Int
    let limit: Int
}

struct AdminUserDetailResponse: Codable, Equatable, Sendable {
    let success: Bool
    let user: UserProfileInfo
    let completedSurveys: [CompletedSurveyItem]
    let pendingSurveys: [PendingSurveyItem]
}

struct UserProfileInfo: Codable, Equatable, Sendable {
    let id: String
    let fullName: String
    let mobile: String
    let aadhaar: String
    let role: String
    let walletBalance: Int
    let rewardPoints: Int
    let state: String?
    let district: String?
    let city: String?
    let createdAt: String
    var isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fullName, mobile, aadhaar, role, walletBalance, rewardPoints, state, district, city, createdAt, isActive
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.fullName = try container.decode(String.self, forKey: .fullName)
        self.mobile = try container.decode(String.self, forKey: .mobile)
        self.aadhaar = try container.decode(String.self, forKey: .aadhaar)
        self.role = try container.decode(String.self, forKey: .role)
        self.walletBalance = try container.decode(Int.self, forKey: .walletBalance)
        self.rewardPoints = try container.decode(Int.self, forKey: .rewardPoints)
        self.state = try container.decodeIfPresent(String.self, forKey: .state)
        self.district = try container.decodeIfPresent(String.self, forKey: .district)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
    }
}

struct CompletedSurveyItem: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    let surveyId: String
    let title: String
    let rewardPoints: Int
    let completedAt: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.surveyId = try container.decode(String.self, forKey: .surveyId)
        self.title = try container.decode(String.self, forKey: .title)
        self.rewardPoints = try container.decode(Int.self, forKey: .rewardPoints)
        self.completedAt = try container.decode(String.self, forKey: .completedAt)
        self.id = UUID()
    }
    
    init(surveyId: String, title: String, rewardPoints: Int, completedAt: String) {
        self.id = UUID()
        self.surveyId = surveyId
        self.title = title
        self.rewardPoints = rewardPoints
        self.completedAt = completedAt
    }
    
    private enum CodingKeys: String, CodingKey {
        case surveyId, title, rewardPoints, completedAt
    }
}

struct PendingSurveyItem: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    let surveyId: String
    let title: String
    let rewardPoints: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.surveyId = try container.decode(String.self, forKey: .surveyId)
        self.title = try container.decode(String.self, forKey: .title)
        self.rewardPoints = try container.decode(Int.self, forKey: .rewardPoints)
        self.id = UUID()
    }
    
    init(surveyId: String, title: String, rewardPoints: Int) {
        self.id = UUID()
        self.surveyId = surveyId
        self.title = title
        self.rewardPoints = rewardPoints
    }
    
    private enum CodingKeys: String, CodingKey {
        case surveyId, title, rewardPoints
    }
}

struct AdminStats: Codable, Equatable, Sendable {
    let totalMembers: Int
    let totalCompleted: Int
    let totalPending: Int
    let totalPointsPaid: Int
}

struct AdminMember: Codable, Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let fullName: String
    let mobile: String
    let walletBalance: Int
    let rewardPoints: Int
    let completedCount: Int
    let pendingCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fullName, mobile, walletBalance, rewardPoints, completedCount, pendingCount
    }
}

struct AdminSurvey: Codable, Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let title: String
    let rewardPoints: Int
    let isGlobal: Bool
    let completionCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, rewardPoints, isGlobal, completionCount
    }
}

struct AdminDashboardResponse: Codable, Equatable, Sendable {
    let success: Bool
    let stats: AdminStats
    let members: [AdminMember]
    let surveys: [AdminSurvey]
}

struct AdminSurveyAnalyticsResponse: Codable, Equatable, Sendable {
    let success: Bool
    let analytics: [SurveyAnalytics]
}

struct CreateSurveyRequest: Codable, Equatable, Sendable {
    let title: String
    let description: String
    let rewardPoints: Int
    let questions: [CreateQuestionItem]
}

struct CreateQuestionItem: Codable, Equatable, Sendable {
    let question: String
    let options: [CreateOptionItem]
}

struct CreateOptionItem: Codable, Equatable, Sendable {
    let title: String
}

struct CreateSurveyQuestion: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var question: String
    var options: [CreateSurveyOption]
}

struct CreateSurveyOption: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var title: String
}

struct UpdateThemeRequest: Codable, Equatable, Sendable {
    let organizationName: String
    let primaryColor: String
    let secondaryColor: String
    let accentColor: String
    let logoUrl: String?
    let welcomeMessage: String?
    let supportEmail: String?
}

struct UpdateThemeResponse: Codable, Equatable, Sendable {
    let success: Bool
    let organization: OrganizationConfig
}

struct UpdateUserStatusRequest: Codable, Equatable, Sendable {
    let isActive: Bool
}

struct UpdateUserStatusResponse: Codable, Equatable, Sendable {
    let success: Bool
    let user: UserProfileInfo
}

