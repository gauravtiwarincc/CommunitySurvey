import Foundation
import Observation

@MainActor
@Observable
final class OTPVerificationViewModel {
    let mobileNumber: String
    let countryCode: String

    var digits = Array(repeating: "", count: 6)
    var resendSecondsRemaining = 60
    var state: LoadableState<AuthSession> = .idle
    var errorMessage: String?
    var debugOTP: String?

    private var transactionID: String
    private let validationManager: ValidationManager
    private let authService: AuthServiceProtocol
    private let sessionManager: SessionManager
    private let themeManager: ThemeManager?
    private let surveyStore: SurveyStateStore?
    private let router: AppRouter
    private var timerTask: Task<Void, Never>?

    init(
        mobileNumber: String,
        countryCode: String,
        transactionID: String? = nil,
        debugOTP: String? = nil,
        validationManager: ValidationManager,
        authService: AuthServiceProtocol,
        sessionManager: SessionManager,
        themeManager: ThemeManager? = nil,
        surveyStore: SurveyStateStore? = nil,
        router: AppRouter
    ) {
        self.mobileNumber = mobileNumber
        self.countryCode = countryCode
        self.transactionID = transactionID ?? UUID().uuidString
        self.debugOTP = debugOTP
        self.validationManager = validationManager
        self.authService = authService
        self.sessionManager = sessionManager
        self.themeManager = themeManager
        self.surveyStore = surveyStore
        self.router = router
        startResendTimer()
    }

    var otp: String { digits.joined() }
    var canVerify: Bool { otp.count == 6 && !state.isLoading }
    var canResend: Bool { resendSecondsRemaining == 0 && !state.isLoading }

    func updateDigit(_ value: String, at index: Int) {
        guard digits.indices.contains(index) else { return }
        digits[index] = String(value.filter(\.isNumber).prefix(1))
        errorMessage = nil
    }

    func applyAutoFill(_ value: String) {
        let numbers = Array(value.filter(\.isNumber).prefix(6)).map(String.init)
        for index in digits.indices {
            digits[index] = index < numbers.count ? numbers[index] : ""
        }
    }

    func fillDebugOTP() {
        guard let debugOTP else { return }
        applyAutoFill(debugOTP)
    }

    func verify() async {
        switch validationManager.validateOTP(otp) {
        case .failure(let error):
            errorMessage = error.localizedDescription
        case .success(let normalizedOTP):
            state = .loading
            do {
                let session = try await authService.verifyOTP(transactionID: transactionID, otp: normalizedOTP, mobileNumber: mobileNumber, countryCode: countryCode)
                sessionManager.completeLogin(session: session)
                themeManager?.apply(organization: session.user.organization)
                surveyStore?.reset()
                await surveyStore?.refresh()
                state = .success(session)
                router.resetToRoot()
            } catch {
                let appError = error as? AppError ?? .unknown(error.localizedDescription)
                state = .failure(appError)
                errorMessage = appError.localizedDescription
            }
        }
    }

    func resend() async {
        guard canResend else { return }
        errorMessage = nil
        do {
            let response = try await authService.requestOTP(mobileNumber: mobileNumber, countryCode: countryCode)
            transactionID = response.transactionID
            debugOTP = response.otp
            fillDebugOTP()
            resendSecondsRemaining = 60
            startResendTimer()
        } catch {
            errorMessage = (error as? AppError ?? .unknown(error.localizedDescription)).localizedDescription
        }
    }

    private func startResendTimer() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, self.resendSecondsRemaining > 0 else { break }
                self.resendSecondsRemaining -= 1
            }
        }
    }
}
