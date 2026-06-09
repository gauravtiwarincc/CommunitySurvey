import SwiftUI

struct AdminUserDetailView: View {
    @State private var viewModel: AdminUserDetailViewModel

    init(viewModel: AdminUserDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                content
            }
            .padding(20)
        }
        .background(AppTheme.softGradient.ignoresSafeArea())
        .navigationTitle("User Detail")
        .task { await viewModel.load() }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil && viewModel.userProfile != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.errorMessage = nil
                }
            }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.userProfile == nil {
            LoadingView()
        } else if let errorMessage = viewModel.errorMessage, viewModel.userProfile == nil {
            ErrorStateView(message: errorMessage) { Task { await viewModel.load() } }
        } else if let userProfile = viewModel.userProfile {
            profile(userProfile)
            stats(userProfile)
            progressSection
        }
    }

    private func profile(_ user: UserProfileInfo) -> some View {
        PremiumCard(padding: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text(user.fullName).font(.title2.bold())
                detail("Mobile", user.mobile)
                
                let dateString: String = {
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    if let date = formatter.date(from: user.createdAt) {
                        return date.formatted(date: .abbreviated, time: .omitted)
                    }
                    let fallbackFormatter = ISO8601DateFormatter()
                    if let date = fallbackFormatter.date(from: user.createdAt) {
                        return date.formatted(date: .abbreviated, time: .omitted)
                    }
                    return "-"
                }()
                detail("Registration Date", dateString)
                
                if let state = user.state, !state.isEmpty {
                    detail("State", state)
                }
                if let district = user.district, !district.isEmpty {
                    detail("District", district)
                }
                if let city = user.city, !city.isEmpty {
                    detail("City", city)
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.isActive ? "Account Active" : "Account Deactivated")
                            .font(.subheadline.bold())
                            .foregroundStyle(user.isActive ? AppTheme.indiaGreen : .red)
                        Text(viewModel.isSelf ? "You cannot deactivate your own account" : "Toggle to change participant activation status")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { user.isActive },
                        set: { _ in
                            Task {
                                await viewModel.toggleUserStatus()
                            }
                        }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.indiaGreen))
                    .labelsHidden()
                    .disabled(viewModel.isSelf || viewModel.isLoading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func stats(_ profile: UserProfileInfo) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
            DashboardStatCard(title: "Completed", value: "\(viewModel.completedSurveys.count)", systemImage: "checkmark.circle.fill", tint: AppTheme.indiaGreen)
            DashboardStatCard(title: "Pending", value: "\(viewModel.pendingSurveys.count)", systemImage: "clock.fill", tint: AppTheme.accent)
            DashboardStatCard(title: "Reward Points", value: "\(profile.rewardPoints)", systemImage: "gift.fill", tint: AppTheme.saffron)
            DashboardStatCard(title: "Wallet", value: "₹\(profile.walletBalance)", systemImage: "indianrupeesign.circle.fill", tint: AppTheme.indiaGreen)
        }
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Survey Progress").font(.title3.bold())
            
            PremiumCard(padding: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Completed", systemImage: "checkmark.circle.fill").font(.headline)
                    if viewModel.completedSurveys.isEmpty {
                        Text("No surveys completed yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.completedSurveys) { item in
                            HStack {
                                Text(item.title)
                                    .font(.subheadline)
                                Spacer()
                                Text("\(item.rewardPoints) pts")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            
            PremiumCard(padding: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Pending", systemImage: "clock.fill").font(.headline)
                    if viewModel.pendingSurveys.isEmpty {
                        Text("No surveys pending")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.pendingSurveys) { item in
                            HStack {
                                Text(item.title)
                                    .font(.subheadline)
                                Spacer()
                                Text("\(item.rewardPoints) pts")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }

    private func detail(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline.weight(.semibold))
        }
    }
}
