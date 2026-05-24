import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {
    var user: User?
    var editableFullName = ""
    var isLoading = false
    var errorMessage: String?

    private let profileService: ProfileServiceProtocol
    private let authService: AuthServiceProtocol
    private let surveyStore: SurveyStateStore
    private let router: AppRouter

    init(profileService: ProfileServiceProtocol, authService: AuthServiceProtocol, surveyStore: SurveyStateStore, router: AppRouter) {
        self.profileService = profileService
        self.authService = authService
        self.surveyStore = surveyStore
        self.router = router
    }

    func load() async {
        isLoading = true
        do {
            user = try await profileService.getProfile()
            editableFullName = user?.fullName ?? ""
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func save() async {
        isLoading = true
        do {
            user = try await profileService.updateProfile(fullName: editableFullName)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func logout() async {
        await authService.logout()
        surveyStore.reset()
        router.resetToRoot()
    }
}
