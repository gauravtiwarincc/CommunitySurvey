import SwiftUI

struct DashboardView: View {
    @Environment(\.themeManager) private var themeManager
    @State private var viewModel: DashboardViewModel
    let router: AppRouter

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    init(viewModel: DashboardViewModel, router: AppRouter) {
        _viewModel = State(initialValue: viewModel)
        self.router = router
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 18) {
                header
                content
            }
            .padding(20)
            .animation(.spring(response: 0.32, dampingFraction: 0.86), value: viewModel.availableSurveys)
            .animation(.spring(response: 0.32, dampingFraction: 0.86), value: viewModel.completedSurveys)
        }
        .refreshable { await viewModel.refresh() }
        .background(AppTheme.softGradient.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { router.navigate(to: .profile) } label: {
                    Image(systemName: "person.crop.circle")
                }
            }
        }
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.availableSurveys.isEmpty && viewModel.completedSurveys.isEmpty {
            loadingContent
        } else if let errorMessage = viewModel.errorMessage, viewModel.availableSurveys.isEmpty && viewModel.completedSurveys.isEmpty {
            ErrorStateView(message: errorMessage) {
                Task { await viewModel.refresh() }
            }
        } else if viewModel.isEmpty {
            EmptySurveyView()
        } else {
            statsGrid
            availableSection
            completedSection
        }
    }

    private var header: some View {
        GradientBrandCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(themeManager.organizationName)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(themeManager.welcomeMessage)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.82))
                    }
                    Spacer()
                    Image(systemName: "checkmark.shield.fill")
                        .font(.title)
                        .foregroundStyle(.white.opacity(0.92))
                        .accessibilityHidden(true)
                }

                HStack(spacing: 10) {
                    Label("\(viewModel.stats.rewardPoints) pts", systemImage: "gift.fill")
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.18), in: Capsule())
                    Spacer()
                    Button { router.navigate(to: .wallet) } label: {
                        Label("Wallet", systemImage: "wallet.pass.fill")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(.white.opacity(0.18), in: Capsule())
                    }
                }
                .foregroundStyle(.white)
            }
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            DashboardStatCard(title: "Wallet Balance", value: "₹\(viewModel.stats.walletBalance)", systemImage: "indianrupeesign.circle.fill", tint: AppTheme.indiaGreen)
            DashboardStatCard(title: "Reward Points", value: "\(viewModel.stats.rewardPoints)", systemImage: "gift.fill", tint: AppTheme.saffron)
            DashboardStatCard(title: "Available Surveys", value: "\(viewModel.stats.availableCount)", systemImage: "doc.text.fill", tint: AppTheme.deepSaffron)
            DashboardStatCard(title: "Completed Surveys", value: "\(viewModel.stats.completedCount)", systemImage: "checkmark.circle.fill", tint: AppTheme.indiaGreen)
        }
    }

    private var availableSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Available Surveys", count: viewModel.availableSurveys.count)
            if viewModel.availableSurveys.isEmpty {
                PremiumCard(padding: 16) {
                    Text("No available surveys right now. Pull to refresh for new opportunities.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ForEach(viewModel.availableSurveys) { survey in
                    AvailableSurveyCard(survey: survey) {
                        router.navigate(to: .surveyDetail(id: survey.id))
                    }
                }
            }
        }
    }

    private var completedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Completed Surveys", count: viewModel.completedSurveys.count)
            if viewModel.completedSurveys.isEmpty {
                PremiumCard(padding: 16) {
                    Text("Completed surveys will appear here after submission.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ForEach(viewModel.completedSurveys) { survey in
                    CompletedSurveyCard(survey: survey)
                }
            }
        }
    }

    private func sectionHeader(_ title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(.title3.bold())
            Spacer()
            Text("\(count)")
                .font(.caption.bold().monospacedDigit())
                .foregroundStyle(AppTheme.indiaGreen)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.indiaGreen.opacity(0.12), in: Capsule())
        }
    }

    private var loadingContent: some View {
        VStack(spacing: 14) {
            ShimmerView().frame(height: 160)
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(0..<4, id: \.self) { _ in
                    ShimmerView().frame(height: 132)
                }
            }
            ShimmerView().frame(height: 112)
            ShimmerView().frame(height: 112)
        }
    }
}
