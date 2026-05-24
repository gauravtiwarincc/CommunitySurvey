import SwiftUI

struct RegistrationView: View {
    @State private var viewModel: RegistrationViewModel

    init(viewModel: RegistrationViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private let genders = Gender.allCases.map(\.rawValue)
    private let education = ["High School", "Graduate", "Post Graduate", "Professional", "Other"]
    private let categories = ["General", "OBC", "SC", "ST", "Prefer not to say"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                PremiumCard {
                    VStack(spacing: 14) {
                        FloatingTextField(title: "Full Name", text: $viewModel.form.fullName)
                        FloatingTextField(title: "Father's Name", text: $viewModel.form.fathersName)
                        DropdownField(title: "Gender", selection: $viewModel.form.gender, options: genders)
                        DatePicker("Date of Birth", selection: $viewModel.form.dateOfBirth, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding(14)
                            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        FloatingTextField(title: "Mobile Number", text: mobileBinding, keyboardType: .numberPad)
                        FloatingTextField(title: "Aadhaar Number", text: aadhaarBinding, keyboardType: .numberPad, isSecure: true)
                        if !viewModel.form.aadhaarNumber.isEmpty {
                            Text(viewModel.maskedAadhaar)
                                .font(.footnote.monospacedDigit())
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        GradientButton(title: viewModel.isSendingAadhaarOTP ? "Sending Aadhaar OTP" : "Verify Aadhaar OTP", systemImage: "shield.lefthalf.filled") {
                            Task { await viewModel.sendAadhaarOTP() }
                        }
                    }
                }
                PremiumCard {
                    VStack(spacing: 14) {
                        FloatingTextField(title: "Address", text: $viewModel.form.address, axis: .vertical)
                        FloatingTextField(title: "State", text: $viewModel.form.state)
                        FloatingTextField(title: "District", text: $viewModel.form.district)
                        FloatingTextField(title: "Pincode", text: pincodeBinding, keyboardType: .numberPad)
                        DropdownField(title: "Education", selection: $viewModel.form.education, options: education)
                        FloatingTextField(title: "Occupation", text: $viewModel.form.occupation)
                        DropdownField(title: "Social Category", selection: $viewModel.form.socialCategory, options: categories)
                    }
                }
                consentCard
                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(message: errorMessage)
                }
                GradientButton(title: "Register & Continue", systemImage: "arrow.right.circle.fill", isEnabled: viewModel.canRegister) {
                    Task { await viewModel.register() }
                }
                .padding(.bottom, 24)
            }
            .padding(20)
        }
        .background(AppTheme.softGradient.ignoresSafeArea())
        .navigationTitle("Register")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Verified Opinion Network")
                .font(.system(size: 30, weight: .bold, design: .rounded))
            Text("Create your verified public opinion profile and start earning rewards for surveys.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var consentCard: some View {
        PremiumCard {
            Toggle(isOn: $viewModel.form.hasConsented) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Consent & Privacy")
                        .font(.headline)
                    Text("I consent to Aadhaar OTP verification and secure processing of my survey profile.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .toggleStyle(.switch)
        }
    }

    private var mobileBinding: Binding<String> {
        Binding(get: { viewModel.form.mobileNumber }, set: { viewModel.form.mobileNumber = String($0.filter(\.isNumber).prefix(10)) })
    }

    private var aadhaarBinding: Binding<String> {
        Binding(get: { viewModel.form.aadhaarNumber }, set: { viewModel.form.aadhaarNumber = String($0.filter(\.isNumber).prefix(12)) })
    }

    private var pincodeBinding: Binding<String> {
        Binding(get: { viewModel.form.pincode }, set: { viewModel.form.pincode = String($0.filter(\.isNumber).prefix(6)) })
    }
}

#Preview {
    NavigationStack {
        let container = DependencyContainer.live()
        RegistrationView(viewModel: RegistrationViewModel(validationManager: container.validationManager, authService: container.authService, router: container.router))
    }
}
