import Foundation

enum Gender: String, CaseIterable, Codable, Sendable {
    case female = "Female"
    case male = "Male"
    case other = "Other"
    case preferNotToSay = "Prefer not to say"
}

struct RegistrationForm: Codable, Equatable, Sendable {
    var fullName = ""
    var fathersName = ""
    var gender = ""
    var dateOfBirth = Calendar.current.date(byAdding: .year, value: -21, to: Date()) ?? Date()
    var mobileNumber = ""
    var aadhaarNumber = ""
    var address = ""
    var state = ""
    var district = ""
    var pincode = ""
    var education = ""
    var occupation = ""
    var socialCategory = ""
    var hasConsented = false
}

struct VONUserProfile: Codable, Equatable, Hashable, Sendable {
    let id: String
    var fullName: String
    var mobileNumber: String
    var maskedAadhaar: String
    var state: String
    var district: String
    var isAadhaarVerified: Bool
    var walletBalance: Decimal
    var rewardPoints: Int
}

struct Survey: Codable, Equatable, Hashable, Identifiable, Sendable {
    let id: String
    let title: String
    let description: String?
    let rewardPoints: Int
    var isCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case rewardPoints
        case isCompleted
    }

    init(id: String, title: String, description: String? = nil, rewardPoints: Int, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.rewardPoints = rewardPoints
        self.isCompleted = isCompleted
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        rewardPoints = try container.decodeIfPresent(Int.self, forKey: .rewardPoints) ?? 0
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
    }

    var reward: Int { rewardPoints }
    var category: String? { "Survey" }
    var estimatedMinutes: Int? { nil }
    var progress: Double? { isCompleted ? 1 : 0 }
    var questions: [SurveyQuestion]? { nil }
}

struct SurveyDetail: Codable, Equatable, Hashable, Identifiable, Sendable {
    let id: String
    let title: String
    let description: String?
    let rewardPoints: Int
    let questions: [SurveyQuestion]

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case rewardPoints
        case questions
    }

    var reward: Int { rewardPoints }
}

struct SurveyQuestion: Codable, Equatable, Hashable, Identifiable, Sendable {
    let id: String
    let question: String
    let options: [SurveyOption]

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case question
        case options
    }

    init(id: String, question: String, options: [SurveyOption]) {
        self.id = id
        self.question = question
        self.options = options
    }

    init(id: String, text: String, options: [SurveyOption]) {
        self.init(id: id, question: text, options: options)
    }

    var text: String { question }
}

struct SurveyOption: Codable, Equatable, Hashable, Identifiable, Sendable {
    let id: String
    let title: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
    }
}

struct DashboardStats: Codable, Equatable, Sendable {
    var availableCount: Int
    var completedCount: Int
    var rewardPoints: Int
    var walletBalance: Int
}

struct DashboardSurveyResponse: Codable, Equatable, Sendable {
    let success: Bool
    var availableSurveys: [Survey]
    var completedSurveys: [Survey]
    var stats: DashboardStats

    enum CodingKeys: String, CodingKey {
        case success
        case availableSurveys
        case completedSurveys
        case stats
    }

    init(success: Bool, availableSurveys: [Survey], completedSurveys: [Survey], stats: DashboardStats) {
        self.success = success
        self.availableSurveys = availableSurveys.map { survey in
            var copy = survey
            copy.isCompleted = false
            return copy
        }
        self.completedSurveys = completedSurveys.map { survey in
            var copy = survey
            copy.isCompleted = true
            return copy
        }
        self.stats = stats
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        let available = try container.decodeIfPresent([Survey].self, forKey: .availableSurveys) ?? []
        let completed = try container.decodeIfPresent([Survey].self, forKey: .completedSurveys) ?? []
        stats = try container.decodeIfPresent(DashboardStats.self, forKey: .stats) ?? DashboardStats(
            availableCount: available.count,
            completedCount: completed.count,
            rewardPoints: completed.reduce(0) { $0 + $1.rewardPoints },
            walletBalance: completed.reduce(0) { $0 + $1.rewardPoints }
        )
        availableSurveys = available.map { survey in
            var copy = survey
            copy.isCompleted = false
            return copy
        }
        completedSurveys = completed.map { survey in
            var copy = survey
            copy.isCompleted = true
            return copy
        }
    }

    var allSurveys: [Survey] { availableSurveys + completedSurveys }
}

struct SurveyAnswer: Codable, Equatable, Sendable {
    let questionID: String
    let optionID: String
}

struct SurveyListResponse: Codable, Equatable, Sendable {
    let success: Bool
    let surveys: [Survey]
}

struct SurveyDetailResponse: Codable, Equatable, Sendable {
    let success: Bool
    let survey: SurveyDetail
}

struct SurveySubmissionAnswer: Codable, Equatable, Sendable {
    let questionId: String
    let selectedOption: String
}

struct SubmitSurveyRequest: Codable, Equatable, Sendable {
    let surveyId: String
    let answers: [SurveySubmissionAnswer]
}

struct APIResponse: Codable, Equatable, Sendable {
    let success: Bool
    let message: String
}

struct SurveySubmitResponse: Codable, Equatable, Sendable {
    let success: Bool
    let message: String
    let rewardEarned: Int
}

struct RewardTransaction: Codable, Equatable, Identifiable, Hashable, Sendable {
    enum Kind: String, Codable, Sendable {
        case survey = "Survey"
        case referral = "Referral"
        case withdrawal = "Withdrawal"
    }

    let id: String
    let title: String
    let kind: Kind
    let amount: Decimal
    let date: Date
}
