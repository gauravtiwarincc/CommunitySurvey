import SwiftUI

struct SurveyListView: View {
    @Environment(\.themeManager) private var themeManager
    @State private var viewModel: SurveyListViewModel
    let router: AppRouter

    init(viewModel: SurveyListViewModel, router: AppRouter) {
        _viewModel = State(initialValue: viewModel)
        self.router = router
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                header
                content
            }
            .padding(20)
            .animation(.spring(response: 0.32, dampingFraction: 0.86), value: viewModel.availableSurveys)
            .animation(.spring(response: 0.32, dampingFraction: 0.86), value: viewModel.completedSurveys)
        }
        .refreshable { await viewModel.refresh() }
        .background(AppTheme.softGradient.ignoresSafeArea())
        .navigationTitle("Surveys")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { router.navigate(to: .wallet) } label: { Image(systemName: "wallet.pass.fill") }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button { router.navigate(to: .dashboard) } label: { Image(systemName: "square.grid.2x2") }
            }
        }
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.surveys.isEmpty {
            LoadingView()
        } else if let errorMessage = viewModel.errorMessage, viewModel.surveys.isEmpty {
            ErrorStateView(message: errorMessage) {
                Task { await viewModel.refresh() }
            }
        } else if viewModel.hasEmptyState {
            EmptySurveyView()
        } else {
            availableSection
            completedSection
        }
    }

    private var header: some View {
        GradientBrandCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(themeManager.organizationName)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                        Text("Answer verified surveys and earn reward points.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.82))
                    }
                    Spacer()
                    Image(systemName: "checkmark.shield.fill")
                        .font(.title)
                        .foregroundStyle(.white.opacity(0.9))
                        .accessibilityHidden(true)
                }
                HStack(spacing: 12) {
                    metric(title: "Available", value: "\(viewModel.stats.availableCount)")
                    metric(title: "Completed", value: "\(viewModel.stats.completedCount)")
                    metric(title: "Rewards", value: "\(viewModel.stats.rewardPoints) pts")
                }
            }
        }
    }

    private var availableSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Available Surveys", count: viewModel.availableSurveys.count)
            if viewModel.availableSurveys.isEmpty {
                PremiumCard(padding: 16) {
                    Text("No available surveys right now.")
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
            ForEach(viewModel.completedSurveys) { survey in
                CompletedSurveyCard(survey: survey)
            }
        }
    }

    private func metric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.72))
            Text(value)
                .font(.headline.monospacedDigit())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
}
