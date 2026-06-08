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
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.user == nil {
            LoadingView()
        } else if let errorMessage = viewModel.errorMessage, viewModel.user == nil {
            ErrorStateView(message: errorMessage) { Task { await viewModel.load() } }
        } else if let user = viewModel.user {
            profile(user)
            stats(user.statistics)
            progress(user.surveyProgress)
        }
    }

    private func profile(_ user: AdminUser) -> some View {
        PremiumCard(padding: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text(user.fullName).font(.title2.bold())
                detail("Mobile", user.mobile)
                detail("Registration Date", user.registrationDate?.formatted(date: .abbreviated, time: .omitted) ?? "-")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func stats(_ stats: UserStatistics) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
            DashboardStatCard(title: "Completed", value: "\(stats.completedSurveys)", systemImage: "checkmark.circle.fill", tint: AppTheme.indiaGreen)
            DashboardStatCard(title: "Pending", value: "\(stats.pendingSurveys)", systemImage: "clock.fill", tint: AppTheme.accent)
            DashboardStatCard(title: "Reward Points", value: "\(stats.rewardPoints)", systemImage: "gift.fill", tint: AppTheme.saffron)
            DashboardStatCard(title: "Wallet", value: "₹\(stats.walletBalance)", systemImage: "indianrupeesign.circle.fill", tint: AppTheme.indiaGreen)
        }
    }

    private func progress(_ progress: SurveyProgress?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Survey Progress").font(.title3.bold())
            progressList(title: "Completed", surveys: progress?.completedSurveys ?? [], badge: "checkmark.circle.fill")
            progressList(title: "Pending", surveys: progress?.pendingSurveys ?? [], badge: "clock.fill")
        }
    }

    private func progressList(title: String, surveys: [Survey], badge: String) -> some View {
        PremiumCard(padding: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Label(title, systemImage: badge).font(.headline)
                if surveys.isEmpty {
                    Text("No surveys")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(surveys) { survey in
                        Text(survey.title)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
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
