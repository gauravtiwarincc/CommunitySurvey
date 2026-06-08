import SwiftUI

struct RegisterView: View {
    @State private var viewModel: AuthViewModel
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case fullName, mobile, aadhaar
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
        .onChange(of: viewModel.state) { _, _ in
            Task { await viewModel.loadDistrictsForSelectedState() }
        }
        .onChange(of: viewModel.district) { _, _ in
            Task { await viewModel.loadCitiesForSelectedDistrict() }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                mobileField
                field(title: "Aadhaar Number", text: aadhaarBinding, error: viewModel.inlineError(for: .aadhaar), keyboardType: .numberPad, isSecure: true, focus: .aadhaar)
            }
        }
    }

    private var adminOnboardingSection: some View {
        PremiumCard(padding: 16) {
            VStack(spacing: 12) {
                dropdown(title: "Organization Type", selection: $viewModel.selectedOrganizationType, options: viewModel.organizationTypes, error: viewModel.inlineError(for: .organizationType), searchable: true)
                if !viewModel.organizationNames.isEmpty {
                    dropdown(title: "Existing Organization", selection: organizationSelectionBinding, options: viewModel.organizationNames, error: nil, searchable: true)
                }
                dropdown(title: "State", selection: $viewModel.state, options: viewModel.states, error: viewModel.inlineError(for: .state), searchable: true)
                dropdown(title: "District", selection: $viewModel.district, options: viewModel.districts, error: viewModel.inlineError(for: .district), searchable: true)
                dropdown(title: "City", selection: $viewModel.city, options: viewModel.cities, error: viewModel.inlineError(for: .city), searchable: true)
                if viewModel.isLoadingOrganizations || viewModel.isLoadingLocations {
                    ProgressView("Loading")
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
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
}
