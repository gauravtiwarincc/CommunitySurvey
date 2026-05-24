import SwiftUI

struct RewardsView: View {
    @State private var viewModel: RewardsViewModel

    init(viewModel: RewardsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                GradientBrandCard {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Wallet Balance")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.78))
                        Text("₹\(viewModel.walletBalance.description)")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        GradientButton(title: "Withdraw to UPI", systemImage: "arrow.down.to.line.compact") { }
                    }
                }
                PremiumCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Transaction History")
                            .font(.title3.bold())
                        ForEach(viewModel.transactions) { transaction in
                            transactionRow(transaction)
                            if transaction.id != viewModel.transactions.last?.id { Divider() }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(AppTheme.softGradient.ignoresSafeArea())
        .navigationTitle("Rewards")
        .task { await viewModel.load() }
        .loadingOverlay(viewModel.isLoading, message: "Loading rewards")
    }

    private func transactionRow(_ transaction: RewardTransaction) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon(for: transaction.kind))
                .foregroundStyle(transaction.amount >= 0 ? AppTheme.indiaGreen : AppTheme.saffron)
                .frame(width: 32, height: 32)
                .background(Color.secondary.opacity(0.10), in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.title).font(.subheadline.weight(.semibold))
                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("₹\(transaction.amount.description)")
                .font(.subheadline.monospacedDigit().weight(.bold))
        }
        .padding(.vertical, 6)
    }

    private func icon(for kind: RewardTransaction.Kind) -> String {
        switch kind {
        case .survey: return "doc.text.fill"
        case .referral: return "person.2.fill"
        case .withdrawal: return "arrow.down.circle.fill"
        }
    }
}
