import SwiftUI

struct RegisterView: View {
    @State private var viewModel: AuthViewModel
    @Environment(\.themeManager) private var themeManager
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case fullName, fathersName, mobile, aadhaar, organizationName, address, pincode
    }

    init(viewModel: AuthViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                if let successMessage = viewModel.successMessage { successBanner(successMessage) }
                if let errorMessage = viewModel.errorMessage { ErrorBanner(message: errorMessage) }
                identitySection
                locationSection
                demographicsSection
                if viewModel.isAdminRegistration {
                    adminOnboardingSection
                }
                consentSection
                GradientButton(title: "Register & Continue", systemImage: "arrow.right.circle.fill", isEnabled: viewModel.canRegister) {
                    Task { await viewModel.register() }
                }
                .padding(.top, 4)
            }
            .padding(16)
            .padding(.bottom, 28)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppTheme.softGradient.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Login") { viewModel.openLogin() }
            }
        }
        .loadingOverlay(viewModel.isLoading, message: "Creating account")
        .navigationTitle("Register")
        .task { await viewModel.loadInitialRegistrationData() }
        .onChange(of: viewModel.selectedOrganizationType) { _, _ in
            Task { await viewModel.loadOrganizationsForSelectedType() }
        }
        .onChange(of: viewModel.selectedStateItem) { _, _ in
            Task { await viewModel.loadDistrictsForSelectedState() }
        }
        .onChange(of: viewModel.selectedDistrictItem) { _, _ in
            Task { await viewModel.loadCitiesForSelectedDistrict() }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Check if there is a custom organization connected
            if let config = viewModel.themeConfig,
               !config.organizationCode.isEmpty,
               config.organizationCode != "VON" {
                
                // Welcome/Greeting card
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        if let logoUrl = config.logoUrl, !logoUrl.isEmpty, let url = URL(string: logoUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 38)
                            } placeholder: {
                                Image(systemName: "building.2.crop.left.fill")
                                    .font(.title3)
                                    .foregroundStyle(themeManager.primary)
                            }
                        } else {
                            Image(systemName: "building.2.crop.left.fill")
                                .font(.title3)
                                .foregroundStyle(themeManager.primary)
                        }
                        
                        Text(config.organizationName)
                            .font(.headline.bold())
                            .foregroundStyle(.primary)
                    }
                    
                    if let welcome = config.welcomeMessage, !welcome.isEmpty {
                        Text(welcome)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Welcome to \(config.organizationName) Group Onboarding!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 6) {
                        Text("Connected via Code:")
                            .font(.caption2.bold())
                            .foregroundStyle(.secondary)
                        Text(config.organizationCode)
                            .font(.system(.caption2, design: .monospaced))
                            .bold()
                            .foregroundStyle(themeManager.primary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(themeManager.primary.opacity(0.12), in: RoundedRectangle(cornerRadius: 4))
                    }
                    .padding(.top, 2)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
                .padding(.bottom, 6)
            }
            
            Text("Create account")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)
            Text(viewModel.isAdminRegistration ? "Register your organization owner account." : "Register as a survey participant.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 6)
    }

    private var identitySection: some View {
        PremiumCard(padding: 16) {
            VStack(spacing: 12) {
                dropdown(title: "Role", selection: $viewModel.selectedRoleName, options: viewModel.roleNames, error: viewModel.inlineError(for: .role))
                field(title: "Full Name", text: $viewModel.fullName, error: viewModel.inlineError(for: .fullName), focus: .fullName)
                field(title: "Father's Name", text: $viewModel.fathersName, error: viewModel.inlineError(for: .fathersName), focus: .fathersName)
                dropdown(title: "Gender", selection: $viewModel.gender, options: ["Male", "Female", "Other", "Prefer not to say"], error: viewModel.inlineError(for: .gender))
                mobileField
                field(title: "Aadhaar Number", text: aadhaarBinding, error: viewModel.inlineError(for: .aadhaar), keyboardType: .numberPad, isSecure: true, focus: .aadhaar)
            }
        }
    }

    private var locationSection: some View {
        PremiumCard(padding: 16) {
            VStack(spacing: 12) {
                dropdown(title: "State", selection: stateSelectionBinding, options: viewModel.statesList.map(\.name), error: viewModel.inlineError(for: .state), searchable: true)
                
                dropdown(title: "District", selection: districtSelectionBinding, options: viewModel.districtsList.map(\.name), error: viewModel.inlineError(for: .district), searchable: true)
                    .disabled(viewModel.selectedStateItem == nil)
                    .opacity(viewModel.selectedStateItem == nil ? 0.6 : 1.0)
                
                dropdown(title: "City", selection: citySelectionBinding, options: viewModel.citiesList.map(\.name), error: viewModel.inlineError(for: .city), searchable: true)
                    .disabled(viewModel.selectedDistrictItem == nil)
                    .opacity(viewModel.selectedDistrictItem == nil ? 0.6 : 1.0)
                
                field(title: "Pincode", text: pincodeBinding, error: viewModel.inlineError(for: .pincode), keyboardType: .numberPad, focus: .pincode)
                field(title: "Address", text: $viewModel.address, error: viewModel.inlineError(for: .address), focus: .address)
                
                if viewModel.isLoadingLocations {
                    ProgressView("Loading locations...")
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var demographicsSection: some View {
        PremiumCard(padding: 16) {
            VStack(spacing: 12) {
                dropdown(title: "Education", selection: $viewModel.education, options: ["Below 10th", "10th Pass", "12th Pass", "Graduate", "Post Graduate", "Doctorate", "Other"], error: viewModel.inlineError(for: .education))
                dropdown(title: "Occupation", selection: $viewModel.occupation, options: ["Self Employed", "Salaried", "Business Owner", "Student", "Retired", "Homemaker", "Unemployed", "Agriculture", "Other"], error: viewModel.inlineError(for: .occupation))
                dropdown(title: "Social Category", selection: $viewModel.socialCategory, options: ["General", "OBC", "SC", "ST", "Other"], error: viewModel.inlineError(for: .socialCategory))
            }
        }
    }

    private var adminOnboardingSection: some View {
        PremiumCard(padding: 16) {
            VStack(spacing: 12) {
                field(title: "Organization Name", text: $viewModel.organizationName, error: viewModel.inlineError(for: .organizationName), focus: .organizationName)
                dropdown(title: "Organization Type", selection: $viewModel.selectedOrganizationType, options: viewModel.organizationTypes, error: viewModel.inlineError(for: .organizationType), searchable: true)
            }
        }
    }

    private var mobileField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Text("+91")
                    .font(.headline.monospacedDigit())
                    .frame(width: 58, height: 56)
                    .background(AppTheme.saffron.opacity(0.14), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .foregroundStyle(AppTheme.deepSaffron)
                FloatingTextField(title: "Mobile Number", text: mobileBinding, keyboardType: .numberPad)
                    .focused($focusedField, equals: .mobile)
            }
            inlineError(viewModel.inlineError(for: .mobile))
        }
    }

    private var consentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                Label("Consent & Privacy", systemImage: "lock.shield.fill")
                    .font(.headline)
                    .foregroundStyle(AppTheme.deepSaffron)
                consentToggle("I consent to Aadhaar verification.", isOn: $viewModel.hasAadhaarConsent)
                consentToggle("I agree to secure processing of my profile and survey data.", isOn: $viewModel.hasPrivacyConsent)
                consentToggle("I accept the terms and conditions.", isOn: $viewModel.hasTermsConsent)
            }
            .padding(14)
            .background(AppTheme.saffron.opacity(0.13), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.saffron.opacity(0.22), lineWidth: 1)
            )
            inlineError(viewModel.inlineError(for: .consent))
        }
    }

    private func field(title: String, text: Binding<String>, error: String?, keyboardType: UIKeyboardType = .default, isSecure: Bool = false, focus: Field) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            FloatingTextField(title: title, text: text, keyboardType: keyboardType, isSecure: isSecure)
                .focused($focusedField, equals: focus)
            inlineError(error)
        }
    }

    private func dropdown(title: String, selection: Binding<String>, options: [String], error: String?, searchable: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if searchable {
                SearchableDropdownField(title: title, selection: selection, options: options)
            } else {
                DropdownField(title: title, selection: selection, options: options)
            }
            inlineError(error)
        }
    }

    private func consentToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.primary)
        }
        .toggleStyle(.switch)
    }

    @ViewBuilder
    private func inlineError(_ message: String?) -> some View {
        if let message {
            Text(message)
                .font(.caption)
                .foregroundStyle(.red)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func successBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppTheme.indiaGreen)
            Text(message)
                .font(.subheadline)
            Spacer()
        }
        .padding(12)
        .background(AppTheme.indiaGreen.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var organizationSelectionBinding: Binding<String> {
        Binding(get: { viewModel.selectedOrganizationName }, set: { viewModel.selectedOrganizationName = $0 })
    }

    private var mobileBinding: Binding<String> {
        Binding(get: { viewModel.mobile }, set: { viewModel.mobile = String($0.filter(\.isNumber).prefix(10)) })
    }

    private var aadhaarBinding: Binding<String> {
        Binding(get: { viewModel.aadhaar }, set: { viewModel.aadhaar = String($0.filter(\.isNumber).prefix(12)) })
    }

    private var pincodeBinding: Binding<String> {
        Binding(get: { viewModel.pincode }, set: { viewModel.pincode = String($0.filter(\.isNumber).prefix(6)) })
    }

    private var stateSelectionBinding: Binding<String> {
        Binding(
            get: { viewModel.selectedStateItem?.name ?? "" },
            set: { name in
                viewModel.selectedStateItem = viewModel.statesList.first(where: { $0.name == name })
            }
        )
    }

    private var districtSelectionBinding: Binding<String> {
        Binding(
            get: { viewModel.selectedDistrictItem?.name ?? "" },
            set: { name in
                viewModel.selectedDistrictItem = viewModel.districtsList.first(where: { $0.name == name })
            }
        )
    }

    private var citySelectionBinding: Binding<String> {
        Binding(
            get: { viewModel.selectedCityItem?.name ?? "" },
            set: { name in
                viewModel.selectedCityItem = viewModel.citiesList.first(where: { $0.name == name })
            }
        )
    }
}
