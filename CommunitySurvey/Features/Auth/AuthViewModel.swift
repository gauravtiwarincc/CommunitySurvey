import Foundation
import Observation

enum RegistrationField: Hashable {
    case fullName
    case mobile
    case aadhaar
    case role
    case organizationType
    case state
    case district
    case city
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
    var state = "" {
        didSet {
            guard oldValue != state else { return }
            district = ""
            city = ""
            districts = []
            cities = []
        }
    }
    var district = "" {
        didSet {
            guard oldValue != district else { return }
            city = ""
            cities = []
        }
    }
    var city = ""
    var pincode = ""
    var education = ""
    var occupation = ""
    var socialCategory = ""
    var selectedRole: UserRole = .user
    var organizationTypes: [String] = []
    var selectedOrganizationType = ""
    var organizations: [OrganizationSummary] = []
    var selectedOrganizationID = ""
    var states: [String] = []
    var districts: [String] = []
    var cities: [String] = []
    var hasAadhaarConsent = false
    var hasPrivacyConsent = false
    var hasTermsConsent = false
    var isAadhaarVerified = false
    var hasAttemptedSubmit = false
    var currentUser: User?
    var isLoading = false
    var isLoadingOrganizations = false
    var isLoadingLocations = false
    var isVerifyingAadhaar = false
    var errorMessage: String?
    var successMessage: String?

    private let authService: AuthServiceProtocol
    private let organizationService: OrganizationServiceProtocol
    private let locationService: LocationServiceProtocol
    private let sessionManager: SessionManager
    private let themeManager: ThemeManager
    private let surveyStore: SurveyStateStore
    private let router: AppRouter

    init(
        authService: AuthServiceProtocol,
        organizationService: OrganizationServiceProtocol,
        locationService: LocationServiceProtocol,
        sessionManager: SessionManager,
        themeManager: ThemeManager,
        surveyStore: SurveyStateStore,
        router: AppRouter
    ) {
        self.authService = authService
        self.organizationService = organizationService
        self.locationService = locationService
        self.sessionManager = sessionManager
        self.themeManager = themeManager
        self.surveyStore = surveyStore
        self.router = router
    }

    var isAuthenticated: Bool { authService.isAuthenticated() }
    var canLogin: Bool { mobileDigits.count == 10 && !isLoading }
    var canRegister: Bool { validationErrors().isEmpty && !isLoading }
    var isAdminRegistration: Bool { selectedRole == .admin }
    var selectableRoles: [UserRole] { [.user, .admin] }
    var roleNames: [String] { selectableRoles.map(\.rawValue) }
    var selectedRoleName: String {
        get { selectedRole.rawValue }
        set { selectedRole = UserRole(rawValue: newValue) ?? .user }
    }
    var organizationNames: [String] { organizations.map(\.organizationName) }
    var selectedOrganizationName: String {
        get { organizations.first(where: { $0.id == selectedOrganizationID })?.organizationName ?? "" }
        set { selectedOrganizationID = organizations.first(where: { $0.organizationName == newValue })?.id ?? "" }
    }

    private var mobileDigits: String { mobile.filter(\.isNumber) }
    private var aadhaarDigits: String { aadhaar.filter(\.isNumber) }

    func loadInitialRegistrationData() async {
        async let types: Void = loadOrganizationTypes()
        async let states: Void = loadStates()
        _ = await (types, states)
    }

    func loadOrganizationTypes() async {
        guard organizationTypes.isEmpty else { return }
        isLoadingOrganizations = true
        defer { isLoadingOrganizations = false }
        do {
            organizationTypes = try await organizationService.fetchOrganizationTypes()
        } catch {
            errorMessage = userFacingMessage(for: error)
        }
    }

    func loadOrganizationsForSelectedType() async {
        guard !selectedOrganizationType.isEmpty else { return }
        isLoadingOrganizations = true
        defer { isLoadingOrganizations = false }
        do {
            organizations = try await organizationService.fetchOrganizations(type: selectedOrganizationType)
        } catch {
            errorMessage = userFacingMessage(for: error)
        }
    }

    func loadStates() async {
        guard states.isEmpty else { return }
        isLoadingLocations = true
        defer { isLoadingLocations = false }
        do {
            states = try await locationService.fetchStates()
        } catch {
            errorMessage = userFacingMessage(for: error)
        }
    }

    func loadDistrictsForSelectedState() async {
        guard !state.isEmpty else { return }
        isLoadingLocations = true
        defer { isLoadingLocations = false }
        do {
            districts = try await locationService.fetchDistricts(state: state)
        } catch {
            errorMessage = userFacingMessage(for: error)
        }
    }

    func loadCitiesForSelectedDistrict() async {
        guard !district.isEmpty else { return }
        isLoadingLocations = true
        defer { isLoadingLocations = false }
        do {
            cities = try await locationService.fetchCities(district: district)
        } catch {
            errorMessage = userFacingMessage(for: error)
        }
    }

    func openRegister() { router.navigate(to: .registration) }
    func openLogin() { router.resetToRoot() }

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
        guard canLogin else {
            errorMessage = "Enter a valid 10-digit mobile number."
            return
        }
        isLoading = true
        do {
            let response = try await authService.requestOTP(mobileNumber: mobileDigits, countryCode: "+91")
            router.navigate(to: .otp(mobileNumber: mobileDigits, countryCode: "+91", transactionID: response.transactionID, debugOTP: response.otp))
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
            let session = try await authService.register(
                fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
                mobile: mobileDigits,
                aadhaar: aadhaarDigits,
                role: selectedRole,
                organizationId: selectedOrganizationID.isEmpty ? nil : selectedOrganizationID,
                organizationType: isAdminRegistration ? selectedOrganizationType : nil,
                state: isAdminRegistration ? state : nil,
                district: isAdminRegistration ? district : nil,
                city: isAdminRegistration ? city : nil
            )
            sessionManager.completeLogin(session: session)
            themeManager.apply(organization: session.user.organization)
            surveyStore.reset()
            await surveyStore.refresh()
            router.resetToRoot()
        } catch {
            errorMessage = userFacingMessage(for: error)
        }
        isLoading = false
    }

    func logout() {
        sessionManager.logout()
        surveyStore.reset()
        themeManager.reset()
        currentUser = nil
        router.resetToRoot()
    }

    private func validationErrors() -> [RegistrationField: String] {
        var errors: [RegistrationField: String] = [:]
        if fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors[.fullName] = "Full name is required." }
        if mobileDigits.count != 10 { errors[.mobile] = "Mobile number must be 10 digits." }
        if aadhaarDigits.count != 12 { errors[.aadhaar] = "Aadhaar number must be 12 digits." }
        if !hasAadhaarConsent || !hasPrivacyConsent || !hasTermsConsent { errors[.consent] = "All consent items are required." }
        if isAdminRegistration {
            if selectedOrganizationType.isEmpty { errors[.organizationType] = "Select organization type." }
            if state.isEmpty { errors[.state] = "Select state." }
            if district.isEmpty { errors[.district] = "Select district." }
            if city.isEmpty { errors[.city] = "Select city." }
        }
        return errors
    }

    private func userFacingMessage(for error: Error) -> String {
        if let apiError = error as? APIError { return apiError.localizedDescription }
        return error.localizedDescription
    }
}
