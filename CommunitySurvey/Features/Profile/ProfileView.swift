import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                PremiumCard {
                    VStack(spacing: 14) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(AppTheme.brandGradient)
                        Text(viewModel.user?.fullName ?? "Profile")
                            .font(.title2.bold())
                        Label("JWT Authenticated", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(AppTheme.indiaGreen)
                    }
                    .frame(maxWidth: .infinity)
                }
                PremiumCard {
                    VStack(spacing: 14) {
                        FloatingTextField(title: "Full Name", text: $viewModel.editableFullName)
                        detailRow("Mobile", viewModel.user?.mobile ?? "-")
                        detailRow("Aadhaar", viewModel.user?.aadhaar ?? "Stored securely on server")
                        GradientButton(title: "Save Profile", systemImage: "checkmark.circle.fill") {
                            Task { await viewModel.save() }
                        }
                    }
                }
                if let errorMessage = viewModel.errorMessage { ErrorBanner(message: errorMessage) }
                Button(role: .destructive) {
                    Task { await viewModel.logout() }
                } label: {
                    Text("Logout")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(20)
        }
        .background(AppTheme.softGradient.ignoresSafeArea())
        .navigationTitle("Profile")
        .task { await viewModel.load() }
        .loadingOverlay(viewModel.isLoading, message: "Loading profile")
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline.weight(.semibold))
        }
    }
}
