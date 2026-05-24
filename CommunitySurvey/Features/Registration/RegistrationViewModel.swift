import Foundation
import Observation

@MainActor
@Observable
final class RegistrationViewModel {
    var form = RegistrationForm()
    var errorMessage: String?
    var isSendingAadhaarOTP = false

    private let validationManager: ValidationManager
    private let authService: AuthServiceProtocol
    private let router: AppRouter

    init(validationManager: ValidationManager, authService: AuthServiceProtocol, router: AppRouter) {
        self.validationManager = validationManager
        self.authService = authService
        self.router = router
    }

    var maskedAadhaar: String { validationManager.maskedAadhaar(form.aadhaarNumber) }

    var canRegister: Bool {
        !form.fullName.isEmpty && !form.fathersName.isEmpty && !form.gender.isEmpty && !form.address.isEmpty && !form.state.isEmpty && !form.district.isEmpty && form.hasConsented
    }

    func sendAadhaarOTP() async {
        errorMessage = nil
        guard case .success = validationManager.validateAadhaar(form.aadhaarNumber) else {
            errorMessage = "Enter a valid Aadhaar number before requesting OTP."
            return
        }
        isSendingAadhaarOTP = true
        try? await Task.sleep(for: .milliseconds(500))
        isSendingAadhaarOTP = false
    }

    func register() async {
        errorMessage = nil
        guard canRegister else {
            errorMessage = "Complete all required fields and consent to continue."
            return
        }
        switch validationManager.validateMobile(form.mobileNumber) {
        case .failure(let error):
            errorMessage = error.localizedDescription
        case .success(let mobile):
            guard case .success = validationManager.validateAadhaar(form.aadhaarNumber) else {
                errorMessage = "Enter a valid Aadhaar number."
                return
            }
            do {
                _ = try await authService.requestOTP(mobileNumber: mobile, countryCode: "+91")
                router.navigate(to: .otp(mobileNumber: mobile, countryCode: "+91"))
            } catch {
                errorMessage = (error as? AppError ?? .unknown(error.localizedDescription)).localizedDescription
            }
        }
    }
}
