import SwiftUI
import Observation

@MainActor
@Observable
final class AdminThemeCustomizationViewModel {
    private let adminService: AdminServiceProtocol
    private let themeManager: ThemeManager
    private let sessionManager: SessionManager

    var organizationName: String = ""
    var primaryColor: Color = .blue
    var secondaryColor: Color = .green
    var accentColor: Color = .orange
    var welcomeMessage: String = ""
    var supportEmail: String = ""
    var logoUrl: String = ""

    var isLoading = false
    var errorMessage: String?
    var saveSuccess = false

    init(adminService: AdminServiceProtocol, themeManager: ThemeManager, sessionManager: SessionManager) {
        self.adminService = adminService
        self.themeManager = themeManager
        self.sessionManager = sessionManager
        loadCurrentBranding()
    }

    func loadCurrentBranding() {
        let config = themeManager.config
        organizationName = config.organizationName
        primaryColor = Color(hex: config.primaryColor)
        secondaryColor = Color(hex: config.secondaryColor)
        accentColor = Color(hex: config.accentColor)
        welcomeMessage = config.welcomeMessage ?? ""
        supportEmail = config.supportEmail ?? ""
        logoUrl = config.logoUrl ?? ""
    }

    func saveTheme() async {
        isLoading = true
        errorMessage = nil
        saveSuccess = false

        let request = UpdateThemeRequest(
            organizationName: organizationName.trimmingCharacters(in: .whitespacesAndNewlines),
            primaryColor: hexString(from: primaryColor),
            secondaryColor: hexString(from: secondaryColor),
            accentColor: hexString(from: accentColor),
            logoUrl: logoUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : logoUrl,
            welcomeMessage: welcomeMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : welcomeMessage,
            supportEmail: supportEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : supportEmail
        )

        do {
            let response = try await adminService.updateTheme(request: request)
            if response.success {
                themeManager.apply(organization: response.organization)
                
                if let currentUser = sessionManager.currentUser {
                    let updatedUser = AuthenticatedUser(
                        id: currentUser.id,
                        mobileNumber: currentUser.mobileNumber,
                        countryCode: currentUser.countryCode,
                        role: currentUser.role,
                        organization: response.organization
                    )
                    sessionManager.updateUser(user: updatedUser)
                }
                saveSuccess = true
            } else {
                errorMessage = "Failed to update branding settings."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func hexString(from color: Color) -> String {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return "#000000"
        }
        
        let r = Int(round(red * 255))
        let g = Int(round(green * 255))
        let b = Int(round(blue * 255))
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
