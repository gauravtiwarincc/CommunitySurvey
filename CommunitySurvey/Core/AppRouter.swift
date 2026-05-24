import Foundation
import Observation

enum AppRoute: Hashable {
    case registration
    case login
    case otp(mobileNumber: String, countryCode: String)
    case aadhaar
    case verificationStatus(AadhaarVerificationResult)
    case dashboard
    case survey(Survey)
    case rewards
    case profile
    case surveyList
    case surveyDetail(id: String)
    case wallet
}

@MainActor
@Observable
final class AppRouter {
    var path: [AppRoute] = []

    func resetToRoot() {
        path.removeAll()
    }

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func replaceStack(with route: AppRoute) {
        path = [route]
    }
}
