import Foundation
import Observation

@MainActor
@Observable
final class LoginViewModel {
    var mobileNumber = ""
    var selectedCountryCode = "+91"
    var state: LoadableState<OTPResponse> = .idle
    var errorMessage: String?

    private let validationManager: ValidationManager
    private let authService: AuthServiceProtocol
    private let router: AppRouter

    init(validationManager: ValidationManager, authService: AuthServiceProtocol, router: AppRouter) {
        self.validationManager = validationManager
        self.authService = authService
        self.router = router
    }

    var canContinue: Bool {
        mobileNumber.filter(\.isNumber).count == 10 && !state.isLoading
    }

    func continueTapped() async {
        errorMessage = nil
        switch validationManager.validateMobile(mobileNumber) {
        case .failure(let error):
            errorMessage = error.localizedDescription
        case .success(let normalizedMobile):
            state = .loading
            do {
                let response = try await authService.requestOTP(mobileNumber: normalizedMobile, countryCode: selectedCountryCode)
                state = .success(response)
                router.navigate(to: .otp(mobileNumber: normalizedMobile, countryCode: selectedCountryCode, transactionID: response.transactionID, debugOTP: response.otp))
            } catch {
                let appError = error as? AppError ?? .unknown(error.localizedDescription)
                state = .failure(appError)
                errorMessage = appError.localizedDescription
            }
        }
    }
}
