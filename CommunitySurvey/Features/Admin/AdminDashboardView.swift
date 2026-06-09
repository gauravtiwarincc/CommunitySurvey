import SwiftUI

struct AdminDashboardView: View {
    @Environment(\.themeManager) private var themeManager
    @State private var showingCopyAlert = false
    @State private var viewModel: AdminDashboardViewModel
    let roleManager: RoleManager
    let sessionManager: SessionManager
    let router: AppRouter

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    init(viewModel: AdminDashboardViewModel, roleManager: RoleManager, sessionManager: SessionManager, router: AppRouter) {
        _viewModel = State(initialValue: viewModel)
        self.roleManager = roleManager
        self.sessionManager = sessionManager
        self.router = router
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 18) {
                header
                orgCodeCard
                content
                Spacer(minLength: 60) // Add bottom spacing to prevent clipping behind TabBar
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 10)
        }
        .refreshable { await viewModel.load() }
        .background(themeManager.softGradient.ignoresSafeArea())
        .navigationTitle("Admin")
        .task { await viewModel.load() }
    }

    private var header: some View {
        GradientBrandCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Admin Console")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    if roleManager.canAccessSuperAdminControls {
                        Text("Platform")
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.white.opacity(0.2), in: Capsule())
                            .foregroundStyle(.white)
                    }
                }
                Text(roleManager.canPerformAdminWrites
                    ? "Monitor users, surveys, completion, and rewards."
                    : "Read-only platform overview for super administrators.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.82))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.dashboardResponse == nil {
            LoadingView()
        } else if let errorMessage = viewModel.errorMessage, viewModel.dashboardResponse == nil {
            ErrorStateView(message: errorMessage) { Task { await viewModel.load() } }
        } else {
            if let response = viewModel.dashboardResponse {
                LazyVGrid(columns: columns, spacing: 14) {
                    DashboardStatCard(title: "Total Members", value: "\(response.stats.totalMembers)", systemImage: "person.2.fill", tint: AppTheme.indiaGreen)
                    DashboardStatCard(title: "Completed Surveys", value: "\(response.stats.totalCompleted)", systemImage: "checkmark.circle.fill", tint: AppTheme.indiaGreen)
                    DashboardStatCard(title: "Pending Surveys", value: "\(response.stats.totalPending)", systemImage: "clock.fill", tint: AppTheme.accent)
                    DashboardStatCard(title: "Total Points Paid", value: "\(response.stats.totalPointsPaid)", systemImage: "gift.fill", tint: AppTheme.saffron)
                }
                
                actions
                
                surveysSection(response.surveys)
                
                membersSection(response.members)
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                GradientButton(title: "All Users", systemImage: "person.3.fill") { router.navigate(to: .adminUsers) }
                if roleManager.canPerformAdminWrites {
                    GradientButton(title: "Create Survey", systemImage: "plus.circle.fill") { router.navigate(to: .createSurvey) }
                }
            }
            if roleManager.canPerformAdminWrites {
                GradientButton(title: "Customize Theme", systemImage: "paintbrush.fill") {
                    router.navigate(to: .adminThemeCustomization)
                }
            }
        }
    }

    private func surveysSection(_ surveys: [AdminSurvey]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Organization Surveys")
                .font(.title3.bold())
            
            if surveys.isEmpty {
                PremiumCard(padding: 16) {
                    Text("No surveys created yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ForEach(surveys) { survey in
                    PremiumCard(padding: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(survey.title)
                                    .font(.headline)
                                Spacer()
                                if survey.isGlobal {
                                    Text("Global")
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(AppTheme.accent.opacity(0.12), in: Capsule())
                                        .foregroundStyle(AppTheme.accent)
                                }
                            }
                            
                            HStack {
                                Label("\(survey.rewardPoints) pts", systemImage: "gift.fill")
                                Spacer()
                                Label("\(survey.completionCount) completions", systemImage: "checkmark.circle.fill")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private func membersSection(_ members: [AdminMember]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Organization Members")
                .font(.title3.bold())
            
            if members.isEmpty {
                PremiumCard(padding: 16) {
                    Text("No members registered under your organization yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ForEach(members) { member in
                    PremiumCard(padding: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(member.fullName)
                                    .font(.headline)
                                Spacer()
                                Text(member.mobile)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Divider()
                            
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Wallet")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.secondary)
                                    Text("₹\(member.walletBalance)")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(AppTheme.indiaGreen)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Points")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.secondary)
                                    Text("\(member.rewardPoints)")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(AppTheme.deepSaffron)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Completed")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.secondary)
                                    Text("\(member.completedCount)")
                                        .font(.subheadline.bold())
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Pending")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.secondary)
                                    Text("\(member.pendingCount)")
                                        .font(.subheadline.bold())
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var orgCodeCard: some View {
        if let org = sessionManager.currentUser?.organization,
           !org.organizationCode.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(org.organizationName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text("Invite members to map with your organization using the code below:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 12) {
                    Text(org.organizationCode)
                        .font(.system(.title2, design: .monospaced))
                        .bold()
                        .foregroundStyle(themeManager.primary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    // Copy Button
                    Button {
                        UIPasteboard.general.string = org.organizationCode
                        showingCopyAlert = true
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.body.bold())
                            .padding(10)
                            .background(themeManager.primary.opacity(0.1))
                            .foregroundStyle(themeManager.primary)
                            .clipShape(Circle())
                    }
                    .alert("Code Copied", isPresented: $showingCopyAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Organization code copied to clipboard!")
                    }
                    
                    // Share Button
                    Button {
                        shareOrgCode(code: org.organizationCode, name: org.organizationName)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.body.bold())
                            .padding(10)
                            .background(themeManager.primary.opacity(0.1))
                            .foregroundStyle(themeManager.primary)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(16)
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
    }

    private func shareOrgCode(code: String, name: String) {
        let message = "Hi! Please install our app from the App Store and register using our group organization code: \(code) to connect with our group."
        
        let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}
