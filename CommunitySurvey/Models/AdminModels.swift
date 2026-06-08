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
    let users: [AdminUser]
    let totalCount: Int?
}

struct AdminUserDetailResponse: Codable, Equatable, Sendable {
    let success: Bool
    let user: AdminUser
}

struct AdminDashboardResponse: Codable, Equatable, Sendable {
    let success: Bool
    let dashboard: AdminDashboard
}

struct AdminSurveyAnalyticsResponse: Codable, Equatable, Sendable {
    let success: Bool
    let analytics: [SurveyAnalytics]
}

struct CreateSurveyRequest: Codable, Equatable, Sendable {
    let title: String
    let description: String
    let rewardPoints: Int
    let questions: [CreateSurveyQuestion]
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
