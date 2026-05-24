import SwiftUI

struct RegisterView: View {
    @State private var viewModel: AuthViewModel
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case fullName, fathersName, mobile, aadhaar, address, state, district, pincode, occupation
    }

    private let genders = ["Male", "Female", "Other"]
    private let educationOptions = ["10th Pass", "12th Pass", "Graduate", "Post Graduate", "Diploma", "PhD", "Other"]
    private let socialCategories = ["General", "OBC", "SC", "ST", "EWS", "Other"]

    init(viewModel: AuthViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                if let successMessage = viewModel.successMessage {
                    successBanner(successMessage)
                }
                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(message: errorMessage)
                }
                identitySection
                addressSection
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
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Create verified account")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)
            Text("Register once to participate in verified public opinion surveys and earn rewards.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 6)
    }

    private var identitySection: some View {
        PremiumCard(padding: 16) {
            VStack(spacing: 12) {
                field(title: "Full Name", text: $viewModel.fullName, error: viewModel.inlineError(for: .fullName), focus: .fullName)
                field(title: "Father's Name", text: $viewModel.fathersName, error: viewModel.inlineError(for: .fathersName), focus: .fathersName)
                dropdown(title: "Gender", selection: $viewModel.gender, options: genders, error: viewModel.inlineError(for: .gender))
                DatePicker("Date of Birth", selection: $viewModel.dateOfBirth, displayedComponents: .date)
                    .font(.subheadline.weight(.semibold))
                    .padding(14)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                mobileField
                field(title: "Aadhaar Number", text: aadhaarBinding, error: viewModel.inlineError(for: .aadhaar), keyboardType: .numberPad, isSecure: true, focus: .aadhaar)
                HStack(spacing: 10) {
                    GradientButton(title: viewModel.isAadhaarVerified ? "Aadhaar Verified" : "Verify with Aadhaar OTP", systemImage: viewModel.isAadhaarVerified ? "checkmark.seal.fill" : "shield.lefthalf.filled", isEnabled: !viewModel.isVerifyingAadhaar) {
                        Task { await viewModel.verifyAadhaarOTP() }
                    }
                }
                if viewModel.isVerifyingAadhaar {
                    ProgressView("Sending OTP")
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var addressSection: some View {
        PremiumCard(padding: 16) {
            VStack(spacing: 12) {
                addressEditor
                field(title: "State", text: $viewModel.state, error: viewModel.inlineError(for: .state), focus: .state)
                field(title: "District", text: $viewModel.district, error: viewModel.inlineError(for: .district), focus: .district)
                field(title: "Pincode", text: pincodeBinding, error: viewModel.inlineError(for: .pincode), keyboardType: .numberPad, focus: .pincode)
                dropdown(title: "Education", selection: $viewModel.education, options: educationOptions, error: viewModel.inlineError(for: .education))
                field(title: "Occupation", text: $viewModel.occupation, error: viewModel.inlineError(for: .occupation), focus: .occupation)
                dropdown(title: "Social Category", selection: $viewModel.socialCategory, options: socialCategories, error: viewModel.inlineError(for: .socialCategory))
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

    private var addressEditor: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.address)
                    .frame(minHeight: 96)
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(focusedField == .address ? AppTheme.saffron : Color.secondary.opacity(0.16), lineWidth: 1.2)
                    )
                    .focused($focusedField, equals: .address)
                if viewModel.address.isEmpty {
                    Text("Full Address")
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                        .allowsHitTesting(false)
                }
            }
            inlineError(viewModel.inlineError(for: .address))
        }
    }

    private var consentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                Label("Consent & Privacy", systemImage: "lock.shield.fill")
                    .font(.headline)
                    .foregroundStyle(AppTheme.deepSaffron)
                consentToggle("I consent to Aadhaar OTP verification.", isOn: $viewModel.hasAadhaarConsent)
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

    private func dropdown(title: String, selection: Binding<String>, options: [String], error: String?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            DropdownField(title: title, selection: selection, options: options)
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

    private var mobileBinding: Binding<String> {
        Binding(get: { viewModel.mobile }, set: { viewModel.mobile = String($0.filter(\.isNumber).prefix(10)) })
    }

    private var aadhaarBinding: Binding<String> {
        Binding(get: { viewModel.aadhaar }, set: { viewModel.aadhaar = String($0.filter(\.isNumber).prefix(12)) })
    }

    private var pincodeBinding: Binding<String> {
        Binding(get: { viewModel.pincode }, set: { viewModel.pincode = String($0.filter(\.isNumber).prefix(6)) })
    }
}
