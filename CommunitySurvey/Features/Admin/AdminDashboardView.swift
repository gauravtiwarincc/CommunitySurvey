import SwiftUI

struct AdminDashboardView: View {
    @State private var viewModel: AdminDashboardViewModel
    let roleManager: RoleManager
    let router: AppRouter

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    init(viewModel: AdminDashboardViewModel, roleManager: RoleManager, router: AppRouter) {
        _viewModel = State(initialValue: viewModel)
        self.roleManager = roleManager
        self.router = router
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 18) {
                header
                content
            }
            .padding(20)
        }
        .refreshable { await viewModel.load() }
        .background(AppTheme.softGradient.ignoresSafeArea())
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
        if viewModel.isLoading && viewModel.dashboard == nil {
            LoadingView()
        } else if let errorMessage = viewModel.errorMessage, viewModel.dashboard == nil {
            ErrorStateView(message: errorMessage) { Task { await viewModel.load() } }
        } else {
            if let dashboard = viewModel.dashboard {
                LazyVGrid(columns: columns, spacing: 14) {
                    DashboardStatCard(title: "Total Users", value: "\(dashboard.totalUsers)", systemImage: "person.2.fill", tint: AppTheme.indiaGreen)
                    DashboardStatCard(title: "Total Surveys", value: "\(dashboard.totalSurveys)", systemImage: "doc.text.fill", tint: AppTheme.saffron)
                    DashboardStatCard(title: "Completed", value: "\(dashboard.completedSurveys)", systemImage: "checkmark.circle.fill", tint: AppTheme.indiaGreen)
                    DashboardStatCard(title: "Pending", value: "\(dashboard.pendingSurveys)", systemImage: "clock.fill", tint: AppTheme.accent)
                    DashboardStatCard(title: "Rewards Distributed", value: "\(dashboard.totalRewardPointsDistributed)", systemImage: "gift.fill", tint: AppTheme.saffron)
                    DashboardStatCard(title: "Completion", value: "\(Int(dashboard.completionPercentage))%", systemImage: "chart.pie.fill", tint: AppTheme.indiaGreen)
                }
            }
            actions
            analyticsSection
        }
    }

    private var actions: some View {
        HStack(spacing: 12) {
            GradientButton(title: "Users", systemImage: "person.3.fill") { router.navigate(to: .adminUsers) }
            if roleManager.canPerformAdminWrites {
                GradientButton(title: "Create", systemImage: "plus.circle.fill") { router.navigate(to: .createSurvey) }
            }
        }
    }

    private var analyticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Survey Analytics")
                .font(.title3.bold())
            if viewModel.analytics.isEmpty {
                PremiumCard(padding: 16) {
                    Text("No analytics available yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ForEach(viewModel.analytics) { item in
                    PremiumCard(padding: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.title).font(.headline)
                            HStack {
                                Label("\(item.completionCount) completed", systemImage: "checkmark.circle.fill")
                                Spacer()
                                Label("\(item.pendingCount) pending", systemImage: "clock.fill")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}
