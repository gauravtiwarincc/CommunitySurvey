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

typealias SurveyItem = Survey
typealias Question = SurveyQuestion
typealias Option = SurveyOption
typealias SurveyDashboardResponse = DashboardSurveyResponse

struct Survey: Codable, Equatable, Hashable, Identifiable, Sendable {
    let id: String
    let title: String
    let description: String?
    let rewardPoints: Int
    let isActive: Bool
    var isCompleted: Bool
    let organizationId: String?
    let questions: [SurveyQuestion]

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case rewardPoints
        case isActive
        case isCompleted
        case organizationId
        case questions
    }

    init(
        id: String,
        title: String,
        description: String? = nil,
        rewardPoints: Int = 0,
        isActive: Bool = true,
        isCompleted: Bool = false,
        organizationId: String? = nil,
        questions: [SurveyQuestion] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.rewardPoints = rewardPoints
        self.isActive = isActive
        self.isCompleted = isCompleted
        self.organizationId = organizationId
        self.questions = questions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        rewardPoints = try container.decodeIfPresent(Int.self, forKey: .rewardPoints) ?? 0
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        organizationId = try container.decodeIfPresent(String.self, forKey: .organizationId)
        questions = try container.decodeIfPresent([SurveyQuestion].self, forKey: .questions) ?? []
    }

    var reward: Int { rewardPoints }
    var category: String? { "Survey" }
    var estimatedMinutes: Int? { questions.isEmpty ? nil : max(1, questions.count) }
    var progress: Double? { isCompleted ? 1 : 0 }
}

struct SurveyDetail: Codable, Equatable, Hashable, Identifiable, Sendable {
    let id: String
    let title: String
    let description: String?
    let rewardPoints: Int
    let questions: [SurveyQuestion]

    init(id: String, title: String, description: String?, rewardPoints: Int = 0, questions: [SurveyQuestion]) {
        self.id = id
        self.title = title
        self.description = description
        self.rewardPoints = rewardPoints
        self.questions = questions
    }

    init(survey: Survey) {
        self.init(id: survey.id, title: survey.title, description: survey.description, rewardPoints: survey.rewardPoints, questions: survey.questions)
    }

    var reward: Int { rewardPoints }
}

struct SurveyQuestion: Codable, Equatable, Hashable, Identifiable, Sendable {
    let id: String
    let question: String
    let options: [SurveyOption]

    enum CodingKeys: String, CodingKey {
        case id = "questionId"
        case legacyID = "_id"
        case question
        case text
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? container.decode(String.self, forKey: .legacyID)
        question = try container.decodeIfPresent(String.self, forKey: .text) ?? container.decodeIfPresent(String.self, forKey: .question) ?? ""
        options = try container.decodeIfPresent([SurveyOption].self, forKey: .options) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(question, forKey: .text)
        try container.encode(options, forKey: .options)
    }

    var text: String { question }
}

struct SurveyOption: Codable, Equatable, Hashable, Identifiable, Sendable {
    let id: String
    let title: String

    enum CodingKeys: String, CodingKey {
        case id = "optionId"
        case legacyID = "_id"
        case title
        case text
    }

    init(id: String, title: String) {
        self.id = id
        self.title = title
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? container.decode(String.self, forKey: .legacyID)
        title = try container.decodeIfPresent(String.self, forKey: .text) ?? container.decodeIfPresent(String.self, forKey: .title) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .text)
    }
}

struct DashboardStats: Codable, Equatable, Sendable {
    var availableCount: Int
    var completedCount: Int
    var rewardPoints: Int
    var walletBalance: Int
}

typealias StatsSummary = DashboardStats

struct DashboardSurveyResponse: Codable, Equatable, Sendable {
    let success: Bool
    var availableSurveys: [Survey]
    var completedSurveys: [Survey]
    var organizationSurveys: [Survey]?
    var completedOrganizationSurveys: [Survey]?
    var stats: DashboardStats?

    enum CodingKeys: String, CodingKey {
        case success
        case availableSurveys
        case completedSurveys
        case organizationSurveys
        case completedOrganizationSurveys
        case stats
        case rewardPoints
        case walletBalance
    }

    init(
        success: Bool,
        availableSurveys: [Survey],
        completedSurveys: [Survey],
        organizationSurveys: [Survey]? = nil,
        completedOrganizationSurveys: [Survey]? = nil,
        stats: DashboardStats? = nil
    ) {
        self.success = success
        self.availableSurveys = availableSurveys.map { var copy = $0; copy.isCompleted = false; return copy }
        self.completedSurveys = completedSurveys.map { var copy = $0; copy.isCompleted = true; return copy }
        self.organizationSurveys = organizationSurveys?.map { var copy = $0; copy.isCompleted = false; return copy }
        self.completedOrganizationSurveys = completedOrganizationSurveys?.map { var copy = $0; copy.isCompleted = true; return copy }
        self.stats = stats
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        let available = try container.decodeIfPresent([Survey].self, forKey: .availableSurveys) ?? []
        let completed = try container.decodeIfPresent([Survey].self, forKey: .completedSurveys) ?? []
        let orgSurveys = try container.decodeIfPresent([Survey].self, forKey: .organizationSurveys)
        let completedOrg = try container.decodeIfPresent([Survey].self, forKey: .completedOrganizationSurveys)
        
        self.availableSurveys = available.map { var copy = $0; copy.isCompleted = false; return copy }
        self.completedSurveys = completed.map { var copy = $0; copy.isCompleted = true; return copy }
        self.organizationSurveys = orgSurveys?.map { var copy = $0; copy.isCompleted = false; return copy }
        self.completedOrganizationSurveys = completedOrg?.map { var copy = $0; copy.isCompleted = true; return copy }

        if let statsVal = try container.decodeIfPresent(DashboardStats.self, forKey: .stats) {
            self.stats = statsVal
        } else {
            let rewardPoints = try container.decodeIfPresent(Int.self, forKey: .rewardPoints) ?? 0
            let walletBalance = try container.decodeIfPresent(Int.self, forKey: .walletBalance) ?? 0
            self.stats = DashboardStats(
                availableCount: self.availableSurveys.count + (self.organizationSurveys?.count ?? 0),
                completedCount: self.completedSurveys.count + (self.completedOrganizationSurveys?.count ?? 0),
                rewardPoints: rewardPoints,
                walletBalance: walletBalance
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encode(availableSurveys, forKey: .availableSurveys)
        try container.encode(completedSurveys, forKey: .completedSurveys)
        try container.encode(organizationSurveys, forKey: .organizationSurveys)
        try container.encode(completedOrganizationSurveys, forKey: .completedOrganizationSurveys)
        if let stats {
            try container.encode(stats, forKey: .stats)
        }
    }

    var allSurveys: [Survey] {
        availableSurveys + completedSurveys + (organizationSurveys ?? []) + (completedOrganizationSurveys ?? [])
    }
}

struct SurveyListResponse: Codable, Equatable, Sendable {
    let success: Bool
    let surveys: [Survey]
}

struct SurveyDetailResponse: Codable, Equatable, Sendable {
    let success: Bool
    let survey: SurveyDetail
}

struct SurveyAnswer: Codable, Equatable, Sendable {
    let questionID: String
    let optionID: String
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
    let message: String?
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
