import Foundation
import Observation

@MainActor
@Observable
final class AadhaarViewModel {
    var aadhaarNumber = ""
    var state: LoadableState<AadhaarVerificationResult> = .idle
    var errorMessage: String?

    private let validationManager: ValidationManager
    private let aadhaarService: AadhaarServiceProtocol
    private let router: AppRouter

    init(validationManager: ValidationManager, aadhaarService: AadhaarServiceProtocol, router: AppRouter) {
        self.validationManager = validationManager
        self.aadhaarService = aadhaarService
        self.router = router
    }

    var maskedAadhaar: String {
        validationManager.maskedAadhaar(aadhaarNumber)
    }

    var canVerify: Bool {
        aadhaarNumber.filter(\.isNumber).count == 12 && !state.isLoading
    }

    func verify() async {
        errorMessage = nil
        switch validationManager.validateAadhaar(aadhaarNumber) {
        case .failure(let error):
            errorMessage = error.localizedDescription
        case .success(let normalized):
            state = .loading
            do {
                let result = try await aadhaarService.verify(aadhaarNumber: normalized)
                state = .success(result)
                router.navigate(to: .verificationStatus(result))
            } catch {
                let appError = error as? AppError ?? .unknown(error.localizedDescription)
                state = .failure(appError)
                errorMessage = appError.localizedDescription
            }
        }
    }
}
