import SwiftUI

struct WalletView: View {
    @State private var viewModel: WalletViewModel

    init(viewModel: WalletViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                GradientBrandCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Wallet Balance")
                            .foregroundStyle(.white.opacity(0.78))
                        Text("₹\(viewModel.walletBalance)")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                PremiumCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Transactions")
                            .font(.title3.bold())
                        ForEach(viewModel.transactions) { transaction in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(transaction.description ?? transaction.type)
                                        .font(.subheadline.weight(.semibold))
                                    Text(transaction.createdAt?.formatted(date: .abbreviated, time: .shortened) ?? "Recent")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("₹\(transaction.amount)")
                                    .font(.subheadline.monospacedDigit().bold())
                            }
                            Divider()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let errorMessage = viewModel.errorMessage { ErrorBanner(message: errorMessage) }
            }
            .padding(20)
        }
        .background(AppTheme.softGradient.ignoresSafeArea())
        .navigationTitle("Wallet")
        .task { await viewModel.load() }
        .loadingOverlay(viewModel.isLoading, message: "Loading wallet")
    }
}
