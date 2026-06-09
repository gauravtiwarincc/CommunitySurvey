import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var isShowingJoinSheet = false
    @State private var joinCode = ""
    @State private var isJoining = false
    @State private var joinError: String?
    @State private var joinSuccess = false

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
                
                if viewModel.user?.role == .user {
                    PremiumCard {
                        VStack(spacing: 14) {
                            if let org = viewModel.user?.organizationId {
                                Text("Group Organization")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                detailRow("Name", org.organizationName)
                                detailRow("Code", org.organizationCode)
                            } else {
                                Text("You are not connected to any group organization.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                GradientButton(title: "Join Group", systemImage: "link.circle.fill") {
                                    isShowingJoinSheet = true
                                }
                            }
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
        .sheet(isPresented: $isShowingJoinSheet) {
            joinGroupSheet
        }
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline.weight(.semibold))
        }
    }

    @ViewBuilder
    private var joinGroupSheet: some View {
        NavigationStack {
            ZStack {
                AppTheme.softGradient.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Enter Organization Code")
                        .font(.title2.bold())
                        .padding(.top, 24)
                    
                    Text("Enter the unique code provided by your organization to connect with your group and load custom branding.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    FloatingTextField(title: "Organization Code (e.g. VON)", text: $joinCode)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .padding(.horizontal)
                    
                    if let joinError {
                        ErrorBanner(message: joinError)
                            .padding(.horizontal)
                    }
                    
                    if joinSuccess {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppTheme.indiaGreen)
                            Text("Successfully connected to group!")
                                .font(.subheadline)
                        }
                        .padding()
                        .background(AppTheme.indiaGreen.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    
                    GradientButton(title: isJoining ? "Joining..." : "Connect Group", systemImage: "link.circle.fill", isEnabled: !joinCode.trimmingCharacters(in: .whitespaces).isEmpty && !isJoining && !joinSuccess) {
                        Task {
                            isJoining = true
                            joinError = nil
                            do {
                                try await viewModel.joinOrganization(code: joinCode.trimmingCharacters(in: .whitespacesAndNewlines))
                                joinSuccess = true
                                try? await Task.sleep(for: .milliseconds(800))
                                isShowingJoinSheet = false
                                joinCode = ""
                                joinSuccess = false
                            } catch {
                                joinError = error.localizedDescription
                            }
                            isJoining = false
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("Join Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        isShowingJoinSheet = false
                        joinCode = ""
                        joinError = nil
                        joinSuccess = false
                    }
                }
            }
        }
    }
}
