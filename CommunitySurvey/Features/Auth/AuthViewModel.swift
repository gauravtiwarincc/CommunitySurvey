import Foundation
import Observation

enum RegistrationField: Hashable {
    case fullName
    case fathersName
    case gender
    case mobile
    case aadhaar
    case address
    case state
    case district
    case pincode
    case education
    case occupation
    case socialCategory
    case consent
}

@MainActor
@Observable
final class AuthViewModel {
    var fullName = ""
    var fathersName = ""
    var gender = ""
    var dateOfBirth = Calendar.current.date(byAdding: .year, value: -21, to: Date()) ?? Date()
    var mobile = ""
    var aadhaar = ""
    var address = ""
    var state = ""
    var district = ""
    var pincode = ""
    var education = ""
    var occupation = ""
    var socialCategory = ""
    var hasAadhaarConsent = false
    var hasPrivacyConsent = false
    var hasTermsConsent = false
    var isAadhaarVerified = false
    var hasAttemptedSubmit = false
    var currentUser: User?
    var isLoading = false
    var isVerifyingAadhaar = false
    var errorMessage: String?
    var successMessage: String?

    private let authService: AuthServiceProtocol
    private let router: AppRouter

    init(authService: AuthServiceProtocol, router: AppRouter) {
        self.authService = authService
        self.router = router
    }

    var isAuthenticated: Bool { authService.isAuthenticated() }
    var canLogin: Bool { mobileDigits.count == 10 && !isLoading }
    var canRegister: Bool { validationErrors().isEmpty && !isLoading }

    private var mobileDigits: String { mobile.filter(\.isNumber) }
    private var aadhaarDigits: String { aadhaar.filter(\.isNumber) }
    private var pincodeDigits: String { pincode.filter(\.isNumber) }

    func openRegister() {
        router.navigate(to: .registration)
    }

    func openLogin() {
        router.resetToRoot()
    }

    func inlineError(for field: RegistrationField) -> String? {
        guard hasAttemptedSubmit else { return nil }
        return validationErrors()[field]
    }

    func verifyAadhaarOTP() async {
        errorMessage = nil
        successMessage = nil
        guard aadhaarDigits.count == 12 else {
            hasAttemptedSubmit = true
            errorMessage = "Enter a valid 12-digit Aadhaar number before OTP verification."
            return
        }
        isVerifyingAadhaar = true
        try? await Task.sleep(for: .milliseconds(650))
        isAadhaarVerified = true
        isVerifyingAadhaar = false
        successMessage = "Aadhaar OTP verified successfully."
    }

    func login() async {
        errorMessage = nil
        successMessage = nil
        isLoading = true
        do {
            currentUser = try await authService.login(mobile: mobileDigits)
            router.replaceStack(with: .surveyList)
        } catch {
            errorMessage = userFacingMessage(for: error)
        }
        isLoading = false
    }

    func register() async {
        hasAttemptedSubmit = true
        errorMessage = nil
        successMessage = nil
        let errors = validationErrors()
        guard errors.isEmpty else { return }

        isLoading = true
        do {
            _ = try await authService.register(fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines), mobile: mobileDigits, aadhaar: aadhaarDigits)
            successMessage = "Registration successful. Please login with your mobile number."
            try? await Task.sleep(for: .milliseconds(800))
            router.resetToRoot()
        } catch {
            errorMessage = userFacingMessage(for: error)
        }
        isLoading = false
    }

    func logout() async {
        await authService.logout()
        currentUser = nil
        router.resetToRoot()
    }

    private func validationErrors() -> [RegistrationField: String] {
        var errors: [RegistrationField: String] = [:]
        if fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors[.fullName] = "Full name is required." }
        if fathersName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors[.fathersName] = "Father's name is required." }
        if gender.isEmpty { errors[.gender] = "Select gender." }
        if mobileDigits.count != 10 { errors[.mobile] = "Mobile number must be 10 digits." }
        if aadhaarDigits.count != 12 { errors[.aadhaar] = "Aadhaar number must be 12 digits." }
        if address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors[.address] = "Full address is required." }
        if state.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors[.state] = "State is required." }
        if district.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors[.district] = "District is required." }
        if pincodeDigits.count != 6 { errors[.pincode] = "Pincode must be 6 digits." }
        if education.isEmpty { errors[.education] = "Select education." }
        if occupation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors[.occupation] = "Occupation is required." }
        if socialCategory.isEmpty { errors[.socialCategory] = "Select social category." }
        if !hasAadhaarConsent || !hasPrivacyConsent || !hasTermsConsent { errors[.consent] = "All consent items are required." }
        return errors
    }

    private func userFacingMessage(for error: Error) -> String {
        if let apiError = error as? APIError { return apiError.localizedDescription }
        return error.localizedDescription
    }
}
