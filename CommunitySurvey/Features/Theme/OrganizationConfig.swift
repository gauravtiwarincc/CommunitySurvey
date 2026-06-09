import Foundation

struct OrganizationConfig: Codable, Equatable, Hashable, Sendable, Identifiable {
    let id: String
    let organizationName: String
    let organizationCode: String
    let logoUrl: String?
    let primaryColor: String // Hex string e.g. "#FF6B00"
    let secondaryColor: String // Hex string e.g. "#008A2E"
    let accentColor: String // Hex string e.g. "#0055FF"
    let welcomeMessage: String?
    let supportEmail: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case organizationName
        case organizationCode
        case logoUrl
        case primaryColor
        case secondaryColor
        case accentColor
        case welcomeMessage
        case supportEmail
    }

    init(
        id: String,
        organizationName: String,
        organizationCode: String,
        logoUrl: String?,
        primaryColor: String,
        secondaryColor: String,
        accentColor: String,
        welcomeMessage: String?,
        supportEmail: String?
    ) {
        self.id = id
        self.organizationName = organizationName
        self.organizationCode = organizationCode
        self.logoUrl = logoUrl
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.accentColor = accentColor
        self.welcomeMessage = welcomeMessage
        self.supportEmail = supportEmail
    }

    init(organization: OrganizationSummary) {
        self.init(
            id: organization.id,
            organizationName: organization.organizationName,
            organizationCode: "",
            logoUrl: organization.logoUrl,
            primaryColor: organization.primaryColor,
            secondaryColor: organization.secondaryColor,
            accentColor: organization.accentColor,
            welcomeMessage: organization.organizationName,
            supportEmail: nil
        )
    }

    static let fallback = OrganizationConfig(
        id: "",
        organizationName: "Verified Opinion Network",
        organizationCode: "VON",
        logoUrl: nil,
        primaryColor: "#FF6B00",
        secondaryColor: "#008A2E",
        accentColor: "#0055FF",
        welcomeMessage: "भारत का Verified Public Opinion Platform",
        supportEmail: "support@von.org"
    )
}

struct OrganizationTheme: Codable, Equatable, Sendable {
    let primaryColor: String
    let secondaryColor: String
    let accentColor: String
    let gradientStartColor: String
    let gradientEndColor: String
}

struct OrganizationConfigResponse: Codable, Equatable, Sendable {
    let success: Bool
    let organization: OrganizationConfig
}
