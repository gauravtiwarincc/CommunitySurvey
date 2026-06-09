import Foundation
import Observation
import SwiftUI

protocol OrganizationConfigProviding: Sendable {
    func loadOrganizationConfig() async throws -> OrganizationConfig
}

struct LocalOrganizationConfigProvider: OrganizationConfigProviding {
    func loadOrganizationConfig() async throws -> OrganizationConfig {
        guard let url = Bundle.main.url(forResource: "OrganizationConfig", withExtension: "json") else {
            return .fallback
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(OrganizationConfig.self, from: data)
    }
}

@MainActor
@Observable
final class ThemeManager {
    static let shared = ThemeManager(configProvider: LocalOrganizationConfigProvider())

    private let configProvider: OrganizationConfigProviding
    private(set) var config: OrganizationConfig = .fallback
    var isLoading = false
    var errorMessage: String?

    init(configProvider: OrganizationConfigProviding) {
        self.configProvider = configProvider
    }

    var organizationName: String { config.organizationName }
    var welcomeMessage: String { config.welcomeMessage ?? "" }
    var logoURL: URL? { config.logoUrl.flatMap(URL.init(string:)) }
    var primary: Color { Color(hex: config.primaryColor) }
    var secondary: Color { Color(hex: config.secondaryColor) }
    var accent: Color { Color(hex: config.accentColor) }
    var gradientStart: Color { Color(hex: config.primaryColor) }
    var gradientEnd: Color { Color(hex: config.secondaryColor) }

    var brandGradient: LinearGradient {
        LinearGradient(colors: [gradientStart, gradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var softGradient: LinearGradient {
        LinearGradient(colors: [gradientStart.opacity(0.20), gradientEnd.opacity(0.16), Color(.systemBackground)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            config = try await configProvider.loadOrganizationConfig()
        } catch {
            config = .fallback
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func loadConfig(code: String?, using service: OrganizationServiceProtocol) async throws {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        do {
            config = try await service.fetchConfig(code: code)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    func apply(organization: OrganizationConfig?) {
        guard let organization else { return }
        config = organization
    }

    func reset() {
        config = .fallback
        errorMessage = nil
        isLoading = false
    }
}

private struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager.shared
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}
