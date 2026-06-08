import Foundation

struct OrganizationConfig: Codable, Equatable, Sendable, Identifiable {
    let id: String
    let organizationName: String
    let logoURL: URL?
    let primaryColor: String
    let secondaryColor: String
    let accentColor: String
    let gradientStartColor: String
    let gradientEndColor: String
    let appIconURL: URL?
    let supportEmail: String
    let website: URL?
    let welcomeMessage: String

    enum CodingKeys: String, CodingKey {
        case id = "organizationId"
        case organizationName
        case logoURL
        case primaryColor
        case secondaryColor
        case accentColor
        case gradientStartColor
        case gradientEndColor
        case appIconURL
        case supportEmail
        case website
        case welcomeMessage
    }

    init(
        id: String,
        organizationName: String,
        logoURL: URL?,
        primaryColor: String,
        secondaryColor: String,
        accentColor: String,
        gradientStartColor: String,
        gradientEndColor: String,
        appIconURL: URL?,
        supportEmail: String,
        website: URL?,
        welcomeMessage: String
    ) {
        self.id = id
        self.organizationName = organizationName
        self.logoURL = logoURL
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.accentColor = accentColor
        self.gradientStartColor = gradientStartColor
        self.gradientEndColor = gradientEndColor
        self.appIconURL = appIconURL
        self.supportEmail = supportEmail
        self.website = website
        self.welcomeMessage = welcomeMessage
    }

    init(organization: OrganizationSummary) {
        self.init(
            id: organization.id,
            organizationName: organization.organizationName,
            logoURL: organization.logoUrl.flatMap(URL.init(string:)),
            primaryColor: organization.primaryColor,
            secondaryColor: organization.secondaryColor,
            accentColor: organization.accentColor,
            gradientStartColor: organization.primaryColor,
            gradientEndColor: organization.secondaryColor,
            appIconURL: nil,
            supportEmail: "",
            website: nil,
            welcomeMessage: organization.organizationName
        )
    }

    static let fallback = OrganizationConfig(
        id: "",
        organizationName: "Verified Opinion Network",
        logoURL: nil,
        primaryColor: "#FF6B00",
        secondaryColor: "#008A2E",
        accentColor: "#0055FF",
        gradientStartColor: "#FF6B00",
        gradientEndColor: "#008A2E",
        appIconURL: nil,
        supportEmail: "",
        website: nil,
        welcomeMessage: "भारत का Verified Public Opinion Platform"
    )
}

struct OrganizationTheme: Codable, Equatable, Sendable {
    let primaryColor: String
    let secondaryColor: String
    let accentColor: String
    let gradientStartColor: String
    let gradientEndColor: String
}
