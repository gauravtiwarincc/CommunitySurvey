import SwiftUI

struct AdminUsersView: View {
    @State private var viewModel: AdminUsersViewModel
    let router: AppRouter

    init(viewModel: AdminUsersViewModel, router: AppRouter) {
        _viewModel = State(initialValue: viewModel)
        self.router = router
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                header
                searchField
                content
            }
            .padding(20)
        }
        .refreshable { await viewModel.refresh() }
        .background(AppTheme.softGradient.ignoresSafeArea())
        .navigationTitle("Registered Users")
        .task { await viewModel.load() }
    }

    private var header: some View {
        PremiumCard(padding: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Users")
                        .font(.title2.bold())
                    Text("\(viewModel.totalCount) registered")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "person.3.fill")
                    .font(.title2)
                    .foregroundStyle(AppTheme.indiaGreen)
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search users", text: $viewModel.searchText)
                .textInputAutocapitalization(.words)
                .submitLabel(.search)
                .onSubmit { Task { await viewModel.refresh() } }
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.users.isEmpty {
            LoadingView()
        } else if let errorMessage = viewModel.errorMessage, viewModel.users.isEmpty {
            ErrorStateView(message: errorMessage) { Task { await viewModel.refresh() } }
        } else if viewModel.users.isEmpty {
            EmptySurveyView(title: "No users found", message: "Registered users will appear here when the admin API returns them.")
        } else {
            ForEach(viewModel.users) { user in
                Button { router.navigate(to: .adminUserDetail(id: user.id)) } label: {
                    userCard(user)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func userCard(_ user: AdminUserItem) -> some View {
        PremiumCard(padding: 16) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(user.fullName).font(.headline)
                        Text(user.mobile).font(.subheadline.monospacedDigit()).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.indiaGreen)
                }
                HStack {
                    metric("Rewards", user.rewardPoints)
                    metric("Wallet", "₹\(user.walletBalance)")
                    metric("Completed", user.completedSurveysCount)
                }
            }
        }
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.headline.monospacedDigit())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func metric(_ title: String, _ value: Int) -> some View {
        metric(title, "\(value)")
    }
}
